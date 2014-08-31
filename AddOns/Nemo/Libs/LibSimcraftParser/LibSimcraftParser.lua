-- Nefigah's SimcraftParser library

local MAJOR = "LibSimcraftParser"
local MINOR = tonumber(("$Revision: 1 $"):match("%d+")) -- TODO: make this to be a simpler version e.g. v1
assert(LibStub, MAJOR.." requires LibStub")

local LibParser = LibStub:NewLibrary(MAJOR, MINOR)
if not LibParser then return end

--
-- Lua APIs
--
local sub, gsub, gmatch, reverse = string.sub, string.gsub, string.reverse, string.gmatch
local length, match, format = string.len, string.match, string.format
local tonumber, tostring, type = tonumber, tostring, type
local tinsert, tconcat = table.insert, table.concat
local select, pairs, ipairs, unpack = select, pairs, ipairs, unpack
local setmetatable, getmetatable = setmetatable, getmetatable

--
--Tokens
--
LibParser.Token = {
  Equals = function(t1, t2)
    return t1.tokenType == t2.tokenType and t1.value == t2.value
  end
}
function LibParser.Token:New()
  local token = { name = '', tokenType = {} }
  local prototype = {
    __index = self,
    __tostring = function(self)
      return self.name .. '[' .. (self.value or '') .. ']'
    end,
    -- Equality method cannot be defined here in New or the function pointers
    -- would differ for each instance, which makes Lua not even call __eq
    __eq = self.Equals
  }
  return setmetatable(token, prototype)
end

--
-- Lexer
--
local Lexer = {}
function Lexer:New(input)
  local input = input or ''
  local lexer = { input = input, position = 1, tokens = {} }
  local prototype = {
    __index = self,
    __tostring = self.ToString
  }
  return setmetatable(lexer, prototype)
end
function Lexer:Tokenize(token, value)
  -- abstract
end
function Lexer:ToString()
  local tokens = ''
  for i, t in ipairs(self.tokens) do
    tokens = tokens .. format( '%d.%s ', tostring(i), tostring(t) )
  end
  return tokens
end
function Lexer:Preprocess()
  -- abstract
end
function Lexer:Analyze(position, current)
  -- abstract
end
function Lexer:Lex()
  self:Preprocess()
  local err
  while self.position <= #self.input do
    local position = self.position
    local char = self.input:sub(self.position, self.position)
    self.position = self:Analyze(self.position, char)
    if self.position == position then
      err = "Error parsing token at position " .. position
      self.tokens = {}
      break
    end
  end
  return self.tokens, err
end
LibParser.Lexer = Lexer

--
-- A class encapsulating a list of tokens with bookkeeping.
--
local TokenStream = {}
function TokenStream:New(token, tokens)
  local tokens = tokens or {}
  local stream = { tokens = tokens, eos = #tokens + 1, position = 1 }
  stream.Token = token
  return setmetatable(stream, { __index = self })
end
function TokenStream:Peek()
  return self.tokens[self.position]
end
function TokenStream:CheckMatch(tokenType, value)
  local current = self:Peek()
  if not current or not tokenType then
    return nil
  end
  local token
  if type(value) == 'table' then
    for _, v in pairs(value) do
      token = self.Token:New(tokenType, v)
      if token == current then
        return current
      end
    end
  else
    -- If no value is passed, assume a type match is desired
    token = self.Token:New(tokenType, (value or current.value))
    if token == current then
      return current
    end
  end
  return nil, token
end
function TokenStream:GetMatch(tokenType, value)
  local token, attempted = self:CheckMatch(tokenType, value)
  if token then
    self.position = self.position + 1
  end
  return token, attempted
end
LibParser.TokenStream = TokenStream

--
-- A generic parser combinator class. Contains no grammar-specific logic.
-- Based largely on the excellent FParsec library for F# by Stephan Tolksdorf.
--
local Parser = { ParseOutcome = { SUCCESS = {}, FAIL = {} } }
function Parser:New()
  local parser = { TokenStream = TokenStream }
  return setmetatable(parser, { __index = self })
end
-- A class encapsulating a parser's result, including any errors encountered.
Parser.Reply = {}
function Parser.Reply:New(outcome, messages, parsed)
  local reply = {
    outcome = outcome or Parser.ParseOutcome.FAIL,
    messages = messages or {},
    parsed = parsed
  }
  return setmetatable(reply, { __index = self })
end
function Parser.Reply:Fail(stream, message)
  local failure =  "Parse failure at token #" .. stream.position ..  " " ..
    tostring( stream:Peek() ) .. ". "
  return self:New(Parser.ParseOutcome.FAIL, { failure .. message })
end
function Parser.Reply:FailUnexpected(stream, expected)
  local message = "Expected: " .. expected
  return self:Fail(stream, message)
end
function Parser.Reply:MergeMessages(otherReply)
end
-- We don't want to provide the default table.insert to the Parser environment,
-- since using mutable data structures in a closure-centric library can lead
-- to unexpected results. An efficiency tradeoff that can be looked at later.
Parser.table = {
  copyinsert = function(t, element)
    local copy = {}
    for i, e in ipairs(t) do
      copy[i] = e
    end
    tinsert(copy, element)
    return copy
  end,
  copyprepend = function(t, element)
    local copy = {}
    for i, e in ipairs(t) do
      copy[i + 1] = e
    end
    copy[1] = element
    return copy
  end
}
-- Wrap parsers in the Parser environment.
-- Note that for the purposes of this library, a "parser" or "parse function"
-- is one that accepts a stream of tokens and returns a Reply object.
function Parser:Register(parsers)
  for name, func in pairs(parsers) do
    setfenv(func, self)
    self[name] = func
  end
end
function Parser:Run(parser, stream)
  local reply = parser(stream)
  if reply.outcome == self.ParseOutcome.SUCCESS then
    return { result = reply.parsed, streamPosition = stream.position }
  else
    return nil, tconcat(reply.messages, "\n")
  end
end

--
-- Parsing Primitives
--
-- Chaining parsers together is central to the parser combinator approach.
-- 'Chain' creates a new parse function (a function(TokenStream) -> Reply).
-- This new parse function can be thought of as a conglomerate of the two
-- parsers you want to sequence together. If either parse fails, the whole
-- chain has failed.
-- Param 'initNext' is a function used to initialize the second parser in the
-- chain, assuming the first parser succeeds.
local primatives = {
  Chain = function(parser, initNext)
    return function(stream)
      local reply = parser(stream)
      if reply.outcome == ParseOutcome.SUCCESS then
        local nextParser = initNext(reply.parsed)
        -- Now note our place before running the next parser
        local position = stream.position
        local nextReply = nextParser(stream)
        if position == stream.position then -- No tokens were consumed
          nextReply:MergeMessages(reply.messages)
        end
        return nextReply
      else
        return Reply:New(reply.outcome, reply.messages)
      end
    end
  end,
  -- 'Either' is an alternative way to chain parsers. Whereas 'Chain' fails
  -- if its first parse fails, 'Either' runs a fallback parser in this case.
  -- (The fallback is not run if the initial parse succeeded.)
  Either = function(parser, fallback)
    return function(stream)
      local position = stream.position
      local reply = parser(stream)
      -- Note the first parser must fail without consuming input from stream
      if reply.outcome == ParseOutcome.FAIL and position == stream.position then
        local originalFail = reply.messages
        reply = fallback(stream)
        if position == stream.position then
          reply:MergeMessages(originalFail)
        end
      end
      return reply
    end
  end,
  -- Saves stream state before running a parse, and backtracks on failure.
  Attempt = function(parser)
    return function(stream)
      local position = stream.position
      local reply = parser(stream)
      if reply.outcome == ParseOutcome.FAIL then
        stream.position = position
        return Reply:Fail(stream, "Lookahead failed; backtracking.")
      end
      return reply
    end
  end,
  -- Checks what the result would be of a given parse, but does not change the
  -- stream state.
  Check = function(parser)
    return function(stream)
      local position = stream.position
      local reply = parser(stream)
      stream.position = position
      return reply
    end
  end,
  -- Create a new parse function that will succeed with a given result.
  -- This is useful when some intermediary action needs to be performed on the
  -- successful result of a previous parser before continuing a parse chain.
  -- This function allows us to "wrap" that result in a new parse function,
  -- so that we can continue chaining one parser into another.
  SucceedWith = function(result)
    return function(stream) -- Stream is untouched, but shown for clarity
      return Reply:New(ParseOutcome.SUCCESS, {}, result)
    end
  end,
  --
  -- Additional Parsers
  --
  -- Run a parser and then apply a function to its result on success.
  -- Can be thought of like the 'pipe' operator present in many shells.
  PipeResult = function(parser, func)
    return Chain(parser, function(result)
                           return SucceedWith( func(result) )
                         end)
  end,
  -- Generalize 'Either' to work on any number of potential parsers
  Choose = function(option, ...)
    if option then
      return Either(option, Choose(...))
    else
      local message = "No parsers given to Choose() were successful."
      return function(stream) return Reply:Fail(stream, message) end
    end
  end,
  -- Parse zero or more consecutive occurances of 'construct', returning results
  -- in a list. Can be thought of like '*' from regular expression syntax.
  Many = function(construct)
    local Parse, ParseAgain
    Parse = function(accumulated)
      return Either(Chain( construct, ParseAgain(accumulated) ),
                    SucceedWith(accumulated))
    end
    ParseAgain = function(accumulated)
      return function(result)
        local results = table.copyinsert(accumulated, result)
        return Parse(results)
      end
    end
    return Parse{}
  end,
  -- Chain together each given parser and run the chain, returning results in a
  -- list if the chain succeeds.
  InOrder = function(...)
    local function Parse(accumulated, nextParser, ...)
      if nextParser then
        local others = {...}
        return Chain(nextParser, function(result)
          local results = table.copyinsert(accumulated, result)
          -- We had to pack and unpack 'others' because ... can't be an upvalue
          return Parse( results, unpack(others) )
        end)
      else
        return SucceedWith(accumulated)
      end
    end
    return Parse({}, ...)
  end,
  -- The InOrder parser returns the results of all of its parses in a list. It
  -- happens that sometimes we only need one of those results; these are simple
  -- convenience parsers for that purpose.
  LastInOrder = function(...)
    return PipeResult(InOrder(...), function(list) return list[#list] end)
  end,
  FirstInOrder = function(...)
    return PipeResult(InOrder(...), function(list) return list[1] end)
  end,
}
Parser:Register(primatives)
LibParser.Parser = Parser

