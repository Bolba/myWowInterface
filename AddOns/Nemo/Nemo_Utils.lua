local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

function Nemo:CreateDebugFrame()
	if ( Nemo.UI.fDebug and Nemo.UI.fDebug:IsVisible() ) then
		Nemo.UI.fDebug.frame:Show()
		return
	end
	-- frame Debug
	Nemo.UI.fDebug = Nemo.UI:Create("Frame")
	Nemo.UI.fDebug:SetTitle("Debug")
	Nemo.UI.fDebug:SetCallback("OnClose", function(widget)
		Nemo.UI:Release(widget)
		Nemo.UI.fDebug = nil
	end)
	Nemo.UI.fDebug:SetLayout("Fill")
	Nemo.UI.fDebug:SetWidth(475)
	Nemo.UI.fDebug:SetHeight(600)
	Nemo.UI.fDebug:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
	Nemo.UI.fDebug:PauseLayout()

	-- simplegroup to hold the editbox
	Nemo.UI.sgDebug = Nemo.UI:Create("SimpleGroup")
	Nemo.UI.sgDebug:SetLayout("Fill")
	Nemo.UI.fDebug:AddChild(Nemo.UI.sgDebug)
	Nemo.UI.sgDebug:SetPoint("TOPLEFT", Nemo.UI.fDebug.frame, "TOPLEFT", 10, -10);
	Nemo.UI.sgDebug:SetWidth(450)
	Nemo.UI.sgDebug:SetHeight(450)

	Nemo.UI.sgDebug.mlebDebug = Nemo.UI:Create("MultiLineEditBox")
	Nemo.UI.sgDebug:AddChild( Nemo.UI.sgDebug.mlebDebug )
	Nemo.UI.sgDebug.mlebDebug:SetLabel( L["utils/debug/mlebDebug/l"] )
	Nemo.UI.sgDebug.mlebDebug:SetPoint("TOPLEFT", Nemo.UI.sgDebug.frame, "TOPLEFT", 0, 0);
	Nemo.UI.sgDebug.mlebDebug:SetWidth(450)
	Nemo.UI.sgDebug.mlebDebug:DisableButton(true)

	-- Code box
	Nemo.UI.sgDebug.mlebCode = Nemo.UI:Create("MultiLineEditBox")
	Nemo.UI.sgDebug:AddChild( Nemo.UI.sgDebug.mlebCode )
	Nemo.UI.sgDebug.mlebCode:SetLabel( L["utils/debug/lua/l"] )
	Nemo.UI.sgDebug.mlebCode:SetPoint("TOPLEFT", Nemo.UI.sgDebug.mlebDebug.frame, "BOTTOMLEFT", 0, 5);
	Nemo.UI.sgDebug.mlebCode:SetWidth(450)
	Nemo.UI.sgDebug.mlebCode:SetCallback( "OnEnterPressed" , Nemo.UI.mlebCodeOnEnterPressed )

	-- Clear button
	Nemo.UI.sgDebug.bClear = Nemo.UI:Create("Button")
	Nemo.UI.sgDebug:AddChild( Nemo.UI.sgDebug.bClear )
	Nemo.UI.sgDebug.bClear:SetText( "Clear" )
	Nemo.UI.sgDebug.bClear:SetWidth(100)
	Nemo.UI.sgDebug.bClear:SetPoint("BOTTOMRIGHT", Nemo.UI.sgDebug.frame, "BOTTOMRIGHT", 0, -100);
	Nemo.UI.sgDebug.bClear:SetCallback( "OnClick", function() Nemo.UI.sgDebug.mlebDebug:SetText("") end )

	-- Test2 button
	Nemo.UI.sgDebug.bTest2 = Nemo.UI:Create("Button")
	Nemo.UI.sgDebug:AddChild( Nemo.UI.sgDebug.bTest2 )
	Nemo.UI.sgDebug.bTest2:SetText( "Test2" )
	Nemo.UI.sgDebug.bTest2:SetWidth(100)
	Nemo.UI.sgDebug.bTest2:SetPoint("BOTTOMRIGHT", Nemo.UI.sgDebug.bClear.frame, "BOTTOMLEFT", 0, 0);
	Nemo.UI.sgDebug.bTest2:SetCallback( "OnClick", function()
--DEBUG2 START-----------------------------------------------
Nemo.UI.sgDebug.mlebDebug:SetText("")
Nemo.Engine.PrintQueue()
--DEBUG2 END-------------------------------------------------
	end )

	-- Test1 button
	Nemo.UI.sgDebug.bTest1 = Nemo.UI:Create("Button")
	Nemo.UI.sgDebug:AddChild( Nemo.UI.sgDebug.bTest1 )
	Nemo.UI.sgDebug.bTest1:SetText( "Test1" )
	Nemo.UI.sgDebug.bTest1:SetWidth(100)
	Nemo.UI.sgDebug.bTest1:SetPoint("BOTTOMRIGHT", Nemo.UI.sgDebug.bTest2.frame, "BOTTOMLEFT", 0, 0);
	Nemo.UI.sgDebug.bTest1:SetCallback( "OnClick", function()
--DEBUG1 START-----------------------------------------------

--DEBUG1 END-------------------------------------------------
	end )
end
function Nemo.UI.mlebCodeOnEnterPressed(...)
	--********************************************************************************************
	-- lua parser in debug window
	--********************************************************************************************
	local fCode = loadstring(select(3,...) or "")
	local success, errorMessage = pcall(fCode)
	Nemo:dprint("DebugCompile:"..tostring(success))
	Nemo:dprint("DebugError:"..tostring(errorMessage))
end
function Nemo:eprint(suffix, startTime, minElapsed)
	--********************************************************************************************
	-- Elapsed print for cpu profiling
	--********************************************************************************************
	local elapsedTime = debugprofilestop()-startTime
	if ( elapsedTime > (minElapsed or 0) ) then
		print(format(" E: %f ms:", elapsedTime)..tostring(suffix) )
	end
end
function Nemo:dprint(value, cleardebug)
	--********************************************************************************************
	-- Debug print
	--********************************************************************************************
	Nemo:CreateDebugFrame()
	if ( cleardebug==true ) then Nemo.UI.sgDebug.mlebDebug:SetText("") end
	if ( Nemo:isblank(value) ) then
		Nemo.UI.sgDebug.mlebDebug:SetText(L["utils/debug/prefix"].."Error: Value is blank".."\n"..Nemo.UI.sgDebug.mlebDebug:GetText())
		return
	end
	if type(value) == "table" then
		Nemo:tprint(value)
	else
		--Nemo.UI.sgDebug.mlebDebug:SetText(L["utils/debug/prefix"]..value.."\n"..Nemo.UI.sgDebug.mlebDebug:GetText()) -- reverse scroll
		Nemo.UI.sgDebug.mlebDebug:SetText(Nemo.UI.sgDebug.mlebDebug:GetText().."\n".. L["utils/debug/prefix"]..value)
	end
end
function Nemo:doprint(value, cleardebug)
	--********************************************************************************************
	-- Debug open print
	-- Prints debug only if the debug window is open, used in COMBAT_LOG_EVENT_UNFILTERED
	--********************************************************************************************
	if ( Nemo.UI.fDebug and Nemo.UI.fDebug:IsVisible() ) then
		Nemo:dprint(value, cleardebug)
	end
end
function Nemo:tprint(ttable)
	--********************************************************************************************
	-- Prints a table without recursion
	--********************************************************************************************
	Nemo:CreateDebugFrame()
	if ( Nemo:isblank(ttable) ) then
		Nemo.UI.sgDebug.mlebDebug:SetText(Nemo.UI.sgDebug.mlebDebug:GetText().."\n"..L["utils/debug/prefix"].."Error: ttable is blank")
	else
		for k,v in pairs(ttable) do Nemo.UI.sgDebug.mlebDebug:SetText(Nemo.UI.sgDebug.mlebDebug:GetText().."\n"..L["utils/debug/prefix"]..k,v) end
	end
end
function Nemo:rtprint(ttable, indent, done)	-- recursive table print
	--********************************************************************************************
	-- recursive table print
	--********************************************************************************************
	Nemo:CreateDebugFrame()
	if ( Nemo:isblank(ttable) ) then
		print(L["utils/debug/prefix"].."Error: ttable is blank");
		return
	end
	done = done or {}
	indent = indent or 0
	if type(ttable) == "table" then
		for key, value in pairs (ttable) do
			formatting = strrep("  ", indent) .. tostring(key) .. ":"
			if type (value) == "table" and not done [value] then
				done [value] = true
				Nemo.UI.sgDebug.mlebDebug:SetText(Nemo.UI.sgDebug.mlebDebug:GetText().."\n"..formatting)

				Nemo:rtprint(value, indent+1, done)
			else
				Nemo.UI.sgDebug.mlebDebug:SetText(Nemo.UI.sgDebug.mlebDebug:GetText().."\n"..formatting..tostring(value))
			end
		end
	else
		Nemo.UI.sgDebug.mlebDebug:SetText( Nemo.UI.sgDebug.mlebDebug:GetText().."\n"..tostring(ttable) )
	end
end
function Nemo:IsNumeric(a)
    return type(tonumber(a)) == "number";
end
function Nemo:NilToNumeric(a, default)
	if ( Nemo:isblank(a) ) then
		if ( Nemo:IsNumeric(default) ) then
			return tonumber(default)
		else
			return 0
		end
	elseif ( Nemo:IsNumeric(a) ) then
		return tonumber(a)
	else
		return 0
	end
end
function Nemo:SearchTable(ttable, fieldname, value)
	if ( Nemo:isblank(ttable) ) then return nil end
	for k,v in pairs(ttable) do
		if ( ttable[k][fieldname] == value ) then return k end
	end
	return nil
end
function Nemo:isblank(value)
	if ( value == nil ) then return true end
	if ( value == "" ) then return true end
	return false
end
function Nemo:CopyTable( src )
    local copy = {}
    for k,v in pairs(src) do
        if ( type(v) == "table" ) then
            copy[k]=Nemo:CopyTable(v)
        else
            copy[k]=v
        end
    end
    return copy
end
function Nemo:TableCount( tTable )
  local count = 0
  for _ in pairs(tTable) do count = count + 1 end
  return count
end
function Nemo:Round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function Nemo:CreateDebugFrame1()
end

--
-- Aliases
--
function Nemo.DebugPrint(value, cleardebug)
	return Nemo:dprint(value, cleardebug)
end
function Nemo.DebugOpenPrint(value, cleardebug)
	return Nemo:doprint(value, cleardebug)
end
function Nemo.TablePrint(ttable)
	return Nemo:tprint(ttable)
end
function Nemo.TablePrintRec(ttable, indent, done)
	return Nemo:rtprint(ttable, indent, done)
end
function Nemo.IsValNumeric(a)
	return Nemo:IsNumeric(a)
end
function Nemo.TableSearch(ttable, fieldname, value)
	return Nemo:SearchTable(ttable, fieldname, value)
end
function Nemo.IsBlank(value)
	return Nemo:isblank(value)
end
function Nemo.DeepCopyTable( src )
	return Nemo:CopyTable( src )
end
function Nemo.CountTable( tTable )
	return Nemo:TableCount( tTable )
end
function Nemo.Truncate(number, decimals)
	return Nemo:Round(number, decimals)
end

function Nemo.EnumerateTable(tab, f, recurse, callback)
	local seen = {}
	local function Enumerate(name, t)
		if seen[t] then
			return
		end
		f(name, t)
		seen[t] = true
		for k, v in pairs(t) do
			if type(v) == "table" then
				if recurse then
					Enumerate(string.format("%s[%s]", name, k), v)
				elseif callback then
					local count = 0
					for i, _ in pairs(v) do
						count = count + 1
					end
					callback(k, count)
				end
			end
		end
	end
	Enumerate('<root>', tab)
end
function Nemo.DebugTableMemory(tab, recurse, printer)
	local p = printer or Nemo.DebugPrint
	local function PrintRec(name, t)
		local contents = {}
		local counts = {}
		for k, v in pairs(t) do
			local obj = type(v)
			counts[obj] = (counts[obj] or 0) + 1
		end
		for k, v in pairs(counts) do
			contents[#contents+1] = string.format("%s=>%d", k, v)
		end
		local summary = table.concat(contents, ' ')
		p(string.format("Table %s: {%s}", name, summary))
		coroutine.yield()
	end
	local function PrintSummary(name, count)
		p(string.format("<subtable> %s: %d", name, count))
		coroutine.yield()
	end

	table.insert( Nemo.D.Threads, coroutine.create( Nemo.EnumerateTable ) )
	coroutine.resume( Nemo.D.Threads[1], tab, PrintRec, recurse, PrintSummary )
end
