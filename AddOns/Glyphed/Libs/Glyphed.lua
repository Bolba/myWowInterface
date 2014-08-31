GetItemInfo(42954) -- bring this item into cache
local GLYPH_ITEM_TEXT,locale="Glyph of ([^\]]+)",GetLocale() -- needs localization
if locale=="deDE" then GLYPH_ITEM_TEXT="Glyphe '(.+)'" end
if locale=="esES" or locale=="esMX" then GLYPH_ITEM_TEXT="Glifo de ([^\]]+)" end
if locale=="frFR" then GLYPH_ITEM_TEXT="Glyphe de ([^\]]+)" end
local _,_,_,_,_,GLYPH=GetItemInfo(42954)

local realm,char,class,eclass=GetRealmName(),UnitName("player"),UnitClass("player")
UpdH=false
InitH=false

local ignore={"THE "}
local sanitize=function(str)
  if not str then return nil end
  str=string.upper(str)
  for k,v in pairs(ignore) do
   str=string.gsub(str,v,"")
  end
  return str
end

local TSF_T_Func=function(i)
   local skillIndex = i + FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
   local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex);
   if skillType=="header" or not skillName then return end
   local buttonIndex=i
   if TradeSkillFilterBar:IsShown() then buttonIndex = i+1 end
   skillButton = _G["TradeSkillSkill"..buttonIndex];
   local link=GetTradeSkillItemLink(skillIndex)
   if not link then return end
   local iname,ilink,_,_,_,itemType,iclass=GetItemInfo(link)
   if not iname or itemType~=GLYPH then return end
   local spellname=sanitize(iname:match(GLYPH_ITEM_TEXT))
   local cclass,eclass=GlyphedDB[realm][iclass],GlyphedDB["classes"][iclass]
   if not cclass then return end
   local c,out={}
   if eclass then
     c=RAID_CLASS_COLORS[eclass].colorStr
   else
     c="FFFFFFFF"
   end
   for char,glyphs in pairs(cclass) do
     if not glyphs[spellname] then out=(out and out..", " or "")..char end
   end
--   if not out then out="none" end --debug
   if out then
    skillButton:SetText(skillButton:GetText().." |c"..c..out.."|r");
   end
end

local myTradeSkillFrame_Update=function(d)
    if ( CURRENT_TRADESKILL ~= INSCRIPTION ) then
         return end
    local diplayedSkills = TRADE_SKILLS_DISPLAYED;
    if  TradeSkillFilterBar:IsShown() then
        diplayedSkills = TRADE_SKILLS_DISPLAYED - 1;
    end
    for i=1, diplayedSkills do
        TSF_T_Func(i)
    end
end

local glyphedtooltip=function(tooltip)
 local name,link=tooltip:GetItem()
 if not link then return end
 local _,_,_,_,_,itemType,iclass=GetItemInfo(link)
 local cclass,eclass=GlyphedDB[realm][iclass],GlyphedDB["classes"][iclass]
 if itemType~=GLYPH or not cclass then return end
 local spellname=sanitize(name:match(GLYPH_ITEM_TEXT))
 local c,out={}
 if eclass then c=RAID_CLASS_COLORS[eclass] end
 for char,glyphs in pairs(cclass) do
  if not glyphs[spellname] then out=(out and out..", " or "")..char end
  end
 if out then tooltip:AddLine("|cFFFFFFFFcan learn:|r "..out,c.r,c.g,c.b,true) end
 tooltip:Show()
 end

local frame=CreateFrame("FRAME")
frame.handler=function(self,event,...)
-- if event=="ADDON_LOADED" then
 if event=="LFG_LOCK_INFO_RECEIVED" then
   if not IsAddOnLoaded("Glyphed") then return end
   frame:UnregisterEvent("LFG_LOCK_INFO_RECEIVED")
   if not GlyphedDB then GlyphedDB={} end
   if not GlyphedDB["classes"] then GlyphedDB["classes"]={} end
   if not GlyphedDB["classes"][class] then GlyphedDB["classes"][class]=eclass end
   if not GlyphedDB[realm] then GlyphedDB[realm]={} end
   if not GlyphedDB[realm][class] then GlyphedDB[realm][class]={} end
--   hooksecurefunc("TradeSkillSetFilter",updateFilter)
--   hooksecurefunc("TradeSkillOnlyShowMakeable",updateFilter)
--   hooksecurefunc("TradeSkillOnlyShowSkillUps",updateFilter)
   local events={"GLYPH_ADDED","GLYPH_DISABLED","GLYPH_ENABLED","GLYPH_REMOVED","GLYPH_UPDATED","USE_GLYPH"}
   for i,e in pairs(events) do frame:RegisterEvent(e) end
   -- start hooking tooltips
   LibStub("LibTipHooker-1.1"):Hook(glyphedtooltip,"item")
 end
 if not UpdH and TradeSkillFrame_Update then
  if myTradeSkillFrame_Update then
   hooksecurefunc("TradeSkillFrame_Update",myTradeSkillFrame_Update)
   UpdH=1
  end
 end
 if not GetGlyphSocketInfo(1) then return end -- low level character, or too early, don't attempt to collect glyphs

 if not GlyphedDB[realm][class][char] then GlyphedDB[realm][class][char]={} end
 local search=GlyphFrameSearchBox:GetText()
 if search==SEARCH then search="" end
 SetGlyphNameFilter("")
 local types=(IsGlyphFlagSet(1) and 0 or 1)+(IsGlyphFlagSet(2) and 0 or 2) -- outdated, prime: +(IsGlyphFlagSet(4) and 0 or 4)
 local known=(IsGlyphFlagSet(8) and 0 or 8) -- apparently, can't add those...
 local unknown=(IsGlyphFlagSet(16) and 16 or 0)
 ToggleGlyphFilter(types)
 ToggleGlyphFilter(known)
 local name, glyphType, isKnown, icon, glyphId, glyphLink
 local learned
 for i=1,GetNumGlyphs() do
  name, glyphType, isKnown, icon, glyphId, glyphLink = GetGlyphInfo(i)
  if name~="header" and isKnown then
    -- extract glyph name from link, as the name field (for display in the glyph window) is sometimes slightly different than the item/spell name
    glyphLink=sanitize(glyphLink:match(GLYPH_ITEM_TEXT))
    if glyphLink and not GlyphedDB[realm][class][char][glyphLink] then
     GlyphedDB[realm][class][char][glyphLink]=1
     learned=(learned and (learned..", ") or "")..glyphLink
    end
  end
 end
 ToggleGlyphFilter(types)
 ToggleGlyphFilter(known)
 SetGlyphNameFilter(search)
 end
frame:SetScript("OnEvent",frame.handler)

frame:RegisterEvent("LFG_LOCK_INFO_RECEIVED")