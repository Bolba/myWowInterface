-- Nefigah's SimcraftParser library
-- GetSimcraftAST return a simcraft AST table

local LibParser = LibStub:GetLibrary("LibSimcraftParser")
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
local TokenType = {
  IDENTIFIER = {},
  NUMBER = {},
  SYMBOL = {},
  OPERATOR = {},
  NEWLINE = {}
}
local Token = LibParser.Token:New()
function Token:New(tokenType, value)
  local name
  for n, t in pairs(TokenType) do
    if t == tokenType then
      name = n
      break
    end
  end
  local token = { name = name, tokenType = tokenType, value = value }
  return setmetatable(token, getmetatable(self))
end
function Token.Pronounce(op)
  if op == '-' then
    return 'Subtract'
  elseif op == 'negate' then
    return 'Negate'
  elseif op == '+' then
    return 'Add'
  elseif op == '*' then
    return 'Multiply'
  elseif op == '%' then
    return 'Divide'
  elseif op == '<' then
    return 'Less'
  elseif op == '>' then
    return 'Greater'
  elseif op == '<=' then
    return 'LessEq'
  elseif op == '>=' then
    return 'GreaterEq'
  elseif op == '=' then
    return 'Equals'
  elseif op == '!' then
    return 'Not'
  elseif op == '!=' then
    return 'NotEq'
  elseif op == '|' then
    return 'Or'
  elseif op == '&' then
    return 'And'
  elseif op == 'floor' then
    return 'Floor'
  elseif op == 'ceil' then
    return 'Ceiling'
  elseif op == '@' then
    return 'Abs'
  elseif op == '~' then
    return 'In'
  elseif op == '!~' then
    return 'NotIn'
  end
  return op
end

--
-- Lexer
--
local Lexer = LibParser.Lexer:New()
function Lexer:Tokenize(token, value)
  local tokenized = Token:New(token, value)
  tinsert(self.tokens, tokenized)
end
function Lexer:Identifier(position)
  local identifier = self.input:match('^[%w_]+', position)
  -- Sometimes simc identifiers can have dots in them
  local endsNumeric = identifier:match('%d$')
  if endsNumeric then
    local suffix = self.input:match('^%.%d', position + length(identifier))
    if suffix then
      identifier = self.input:match('^[%w%._]+', position)
    end
  end
  if identifier == 'floor' or identifier == 'ceil' then
    self:Tokenize(TokenType.OPERATOR, identifier)
  else
    self:Tokenize(TokenType.IDENTIFIER, identifier)
  end
  return position + length(identifier)
end
function Lexer:Symbol(position, symbol)
  if symbol == ',' then
    self:Tokenize(TokenType.SYMBOL, 'comma')
  elseif symbol == '.' then
    self:Tokenize(TokenType.SYMBOL, 'dot')
  elseif symbol == ':' then
    self:Tokenize(TokenType.SYMBOL, 'colon')
  elseif symbol == '(' then
    self:Tokenize(TokenType.SYMBOL, 'bracket')
  elseif symbol == ')' then
    self:Tokenize(TokenType.SYMBOL, 'closebracket')
  elseif symbol == '!' then
    local operator = self.input:match('^![=~]', position)
    if operator then 
      self:Tokenize(TokenType.OPERATOR, operator)
      return position + 2
    else
      self:Tokenize(TokenType.OPERATOR, '!')
    end
  elseif symbol == '<' or symbol == '>' then
    local caret = self.input:match('^[<>][^=]', position)
    if caret then
      self:Tokenize(TokenType.OPERATOR, symbol)
    else
      local operator = self.input:match('^[<>]=', position)
      self:Tokenize(TokenType.OPERATOR, operator)
      return position + length(operator)
    end
  elseif symbol == '+' then
    if #self.tokens == 0 or
       self.tokens[#self.tokens].tokenType == TokenType.OPERATOR or
       (self.tokens[#self.tokens].tokenType == TokenType.SYMBOL and
       self.tokens[#self.tokens].value == 'bracket') 
    then
      -- Unary plus is a no-op
    elseif self.input:match('^%+=', position) then
      self:Tokenize(TokenType.OPERATOR, '+=')
      return position + 2
    else
      self:Tokenize(TokenType.OPERATOR, '+')
    end
  elseif symbol == '-' then
    if #self.tokens == 0 or
       self.tokens[#self.tokens].tokenType == TokenType.OPERATOR or
       (self.tokens[#self.tokens].tokenType == TokenType.SYMBOL and
        self.tokens[#self.tokens].value == 'bracket') 
    then
      self:Tokenize(TokenType.OPERATOR, 'negate')
    else
      self:Tokenize(TokenType.OPERATOR, '-')
    end
  else
    local operator = self.input:match('^[@%*%%=~&|]', position)
    self:Tokenize(TokenType.OPERATOR, operator)
  end
  return position + 1
end
function Lexer:Number(position)
  local number = self.input:match('^%d+%.?%d*', position)
  self:Tokenize(TokenType.NUMBER, number)
  return position + length(number)
end
function Lexer:Newline(position)
  self:Tokenize(TokenType.NEWLINE)
  return position + 1
end
-- There are a couple annoyances in parsing simc input. One is that a slash can
-- appear anywhere in a string to separate/signify a new command. Another is
-- string substitution templates using $()
function Lexer:Preprocess()
  local replacements = {}
  -- Remove templates and replace them with their substitutions
  -- Also, sequences aren't supported yet, so prune them out for now
  for s in self.input:gmatch('%S+') do -- for each line in input
    local template, substitute = s:match('^(%$%([%w_]+%))=(.+)')
    if s:match(':') or template then
      if template then
        replacements[template] = substitute
      end
      replacements[s:gsub('(%W)', '%%%1')] = '' -- Escape magic chars
    end
  end
  for search, replacement in pairs(replacements) do
    self.input = self.input:gsub(search, replacement)
  end
  replacements = {}
  -- Replace slash command separators with equivalent syntax
  for s in self.input:gmatch('%S+') do
    local split = {} 
    -- find all slash commands
    for action in s:gmatch('/([^/]+)') do tinsert(split, action) end
    if #split > 0 then
      -- Save the line's prefix and first command
      local property, op, noslash = s:match('^([^%+=]+)(%+?=)([^/]+)/')
      local replacement = property .. op .. noslash
      for _, action in ipairs(split) do
        -- Put the split commands back in as their own lines
        replacement = replacement .. '\n' .. property .. '+=' .. action
      end
      replacements[s:gsub('(%W)', '%%%1')] = replacement -- Escape magic chars
    end
  end
  for search, replacement in pairs(replacements) do
    self.input = self.input:gsub(search, replacement)
  end
  self.input = self.input:gsub('^%s+', '') -- Remove leading whitespace
                         :gsub('$', '\n') -- Ensure ending newline
                         :gsub('%s%s+', '\n') -- Remove blank lines
end
function Lexer:Analyze(position, current)
  if current:match('%a') then
    return self:Identifier(position)
  elseif current:match('%d') then
    return self:Number(position)
  elseif current:match('%p') then
    return self:Symbol(position, current)
  elseif current == '\n' then
    return self:Newline(position)
  else
    return position + 1
  end
end

--
-- Parser
--
local Parser = LibParser.Parser:New()
-- Parsers are put in the Parser environment to avoid having to qualify names
-- all the time, so some aliases are needed.
Parser.TokenType = TokenType
Parser.Token = Token
Parser.unpack = unpack
-- Special parser class for handling infix binary operators with precedences
-- TODO: Make this more generic and move to main lib
Parser.OperatorPrecedenceParser = {}
function Parser.OperatorPrecedenceParser:New(ops, params, values, terminators)
  local opp = { operators = ops, values = values, terminators = terminators }
  opp.RightAssociative = params.rightAssociative or (function() return nil end)
  opp.Unary = params.unary or (function() return nil end)
  return setmetatable(opp, { __index = self })
end
function Parser.OperatorPrecedenceParser:Parse(stream)
  local P = Parser
  local start = stream.position
  local results = {}
  local stack = {}
  local errors = {}
  local function Peek(stack)
    return stack[#stack]
  end
  local function Pop(stack)
    local t = Peek(stack)
    stack[#stack] = nil
    return t
  end
  local function Preceeds(op1, op2)
    local p1 = self.operators[op1.value] or -1
    local p2 = self.operators[op2.value] or 0
    return (not self.RightAssociative(op2.value) and p1 == p2) or p2 < p1
  end
  while self.terminators(stream).outcome ~= P.ParseOutcome.SUCCESS do
    local bracket = stream:GetMatch(TokenType.SYMBOL, 'bracket')
    if bracket then
      tinsert(stack, bracket)
    else -- not an opening paren
      local close = stream:GetMatch(TokenType.SYMBOL, 'closebracket')
      if close then
        local foundOpenBracket = false
        while Peek(stack) do
          if Peek(stack).value == 'bracket' then
            foundOpenBracket = true
            Pop(stack)
            break
          end
          tinsert(results, Pop(stack))
        end
        if not foundOpenBracket then
          tinsert(errors, "Mismatched parentheses in operator expression")
          break
        end
      else -- not a closing paren
        local op = stream:GetMatch(TokenType.OPERATOR)
        if op then
          while Peek(stack) and Preceeds(Peek(stack), op) do
            tinsert(results, Pop(stack))
          end
          tinsert(stack, op)
        else
          local val = self.values(stream)
          if val.outcome ~= P.ParseOutcome.SUCCESS then
            tinsert(errors, val.messages[1] or "Unable to parse value")
            break
          else
            tinsert(results, val.parsed)
          end -- val success check
        end -- operator check
      end -- close paren check
    end -- open paren check
  end -- while
  while Peek(stack) do
    if Peek(stack).tokenType ~= TokenType.OPERATOR then
      tinsert(errors, "Mismatched parentheses in operator expression")
      break
    end
    tinsert(results, Pop(stack))
  end
  local outcome = P.ParseOutcome.SUCCESS
  if #errors > 0 then
    stream.position = start
    outcome = P.ParseOutcome.FAIL
  end
  return P.Reply:New(outcome, errors, #errors == 0 and self:FromRPN(results))
end
function Parser.OperatorPrecedenceParser:FromRPN(tokens)
  local reversed = {}
  for i = #tokens, 1, -1 do
    tinsert(reversed, tokens[i])
  end
  local function Parse(input, position)
    local head = input[position]
    if head.name == 'Value' then
      return head, position + 1
    elseif self.Unary(head.value) then
      local arg, rest = Parse(input, position + 1)
      return { name = Token.Pronounce(head.value), arg = arg }, rest
    else
      local left, rest = Parse(input, position + 1)
      local right, e = Parse(input, rest)
      return { name = Token.Pronounce(head.value), lhs = right, rhs = left }, e
    end
  end
  return Parse(reversed, 1)
end
--
-- SimCraft Parsers
--
local simcraftParsers = {
  Literal = function(tokenType, value)
    return function(stream)
      local t, attempt = stream:GetMatch(tokenType, value)
      if t then
        return Reply:New(ParseOutcome.SUCCESS, nil, t.value or tostring(t))
      else
        return Reply:FailUnexpected(stream, tostring(attempt))
      end
    end
  end,
  Symbol = function(symbol)
    return Literal(TokenType.SYMBOL, symbol)
  end,
  Operator = function(op)
    return Literal(TokenType.OPERATOR, op)
  end,
  Identifier = function()
    return Literal(TokenType.IDENTIFIER)
  end,
  Newline = function()
    return Literal(TokenType.NEWLINE)
  end,
  Number = function()
    return Literal(TokenType.NUMBER)
  end,
  Property = function()
    local children = LastInOrder(Symbol('dot'), Identifier())
    local property = InOrder(Identifier(), Many(children))
    return PipeResult(property, NewProperty)
  end,
  Specification = function()
    local ops = {'=', '+=', '<', '<=', '>', '>='}
    local spec = InOrder(Property(), Operator(ops), Expression())
    return PipeResult(spec, NewSpecification)
  end,
  CriteriaList = function()
    local list = Many( LastInOrder(Symbol('comma'), Specification()) )
    return PipeResult(list, NewCriteriaList)
  end,
  Statement = function()
    local statement = InOrder(Specification(), CriteriaList(), Newline())
    return PipeResult(statement, NewStatement)
  end,
  Expression = function()
    return function(stream)
      local ops = {
        ['|'] = 2, ['&'] = 2, ['='] = 3, ['!='] = 3, ['<'] = 4, ['>'] = 4, 
        ['<='] = 4, ['>='] = 4, ['~'] = 4, ['!~'] = 4, ['+'] = 5, ['-'] = 5, 
        ['*'] = 6,  ['%'] = 6, ['!'] = 7, ['negate'] = 7, ['@'] = 7,
        ['floor'] = 8, ['ceil'] = 8
      }
      local isOddball = function(op) return ops[op] >= 7 end
      local params = { unary = isOddball, associateRight = isOddball }
      local stopAt = Check( Choose(Symbol('comma'), Newline()) )
      local opp = OperatorPrecedenceParser:New(ops, params, Value(), stopAt)
      return opp:Parse(stream)
    end
  end,
  Value = function()
    local val = Choose(Number(), Property())
    return PipeResult(val, NewValue)
  end,
  APL = function()
    local statements = InOrder( Statement(), Many(Statement()) )
    local apl = FirstInOrder( statements, Many(Newline()) )
    return PipeResult(apl, NewAPL)
  end,
}
Parser:Register(simcraftParsers)
--
-- SimCraft Types
--
local simcraftTypes = {
  NewAPL = function(parsed)
    local first, rest = unpack(parsed)
    return { name = 'APL', statements = table.copyprepend(rest, first) }
  end,
  NewProperty = function(parsed)
    local id, subproperties = unpack(parsed)
    return { name = 'Property', id = id, subproperties = subproperties }
  end,
  NewStatement = function(parsed)
    local spec, criteria, _ = unpack(parsed)
    return { name = 'Statement', specification = spec, criteria = criteria }
  end,
  NewSpecification = function(parsed)
    local prop, op, exp = unpack(parsed)
    return { name = 'Specification', to = prop, from = exp, operator = op }
  end,
  NewCriteriaList = function(parsed)
    local specs = {}
    for _, spec in ipairs(parsed) do
      specs[spec.to.id] = spec
    end
    return { name = 'Criteria', specifications = specs }
  end,
  NewValue = function(parsed)
    return { name = 'Value', value = parsed }
  end
}
Parser:Register(simcraftTypes)

--
-- External interface
--
-- Get Abstract syntax tree from simcraft APL (rotation) input string
function LibParser.GetSimcraftAST(simcraftAPL)
  local function CleanString(input)
    return input:gsub('"?https?://[^\n]*\n', 'StringOmitted\n') -- Remove URLs
                :gsub('"[^"]*"', 'StringOmitted') -- Remove string literals
                :gsub('||', '|')                  -- Remove escaped pipes
                :gsub('=/', '=')                  -- Remove implied slashes
                :gsub('#[^\n]*\n', '\n')          -- Remove comments
                :gsub('[ \t\r]', '')              -- Remove extra whitespace
  end
  Lexer.input = CleanString(simcraftAPL)
  local tokens, err = Lexer:Lex()
  if err then
    return nil, err
  end
  return Parser:Run( simcraftParsers.APL(), 
                     LibParser.TokenStream:New(Token, tokens) )
end
