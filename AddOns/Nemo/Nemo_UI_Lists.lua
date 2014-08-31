local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Lists Utility functions
--*****************************************************
function Nemo.AddList( ListName, ForceRename, ShowError )
	if ( Nemo.UI.EntryHasErrors( ListName ) ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], ListName) ) end
		return nil
	end
	local lListExists   = Nemo:SearchTable(Nemo.D.LTMC, "text", ListName)
	local lNewListValue = 'Nemo.UI:CreateListPanel([=['..ListName..']=])'
	local lNewListText  = ListName
	if ( ForceRename and lListExists ) then
		local iSuffix = 0
		lNewListText = lNewListText..'_'
		while lListExists do
			iSuffix = iSuffix+1
			lListExists = Nemo:SearchTable(Nemo.D.LTMC, "text", lNewListText..iSuffix)
		end
		lNewListValue = 'Nemo.UI:CreateListPanel([=['..lNewListText..iSuffix..']=])'
		lNewListText = lNewListText..iSuffix
	end
	local lNewList = { value = lNewListValue, text = lNewListText, entrytree={} }
	if ( Nemo:SearchTable(Nemo.D.LTMC, "text", lNewListText) ) then
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lNewListText) ) end
	else
		table.insert( Nemo.D.LTMC, lNewList)
		if ( Nemo.UI.sgMain ) then
			Nemo.UI.fMain:SetStatusText( '' )-- Clear any previous errors
		end
		lListExists = Nemo:SearchTable(Nemo.D.LTMC, "text", lNewListText)
	end
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	-- Nemo.AButtons.bInitComplete = false		-- List was added
	return lNewListText, lListExists
end
function Nemo.AddListEntry( ListName, ShowError, ID, Type )

	if ( Nemo.UI.EntryHasErrors( ListName ) ) then
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], ListName) ) end
		return
	end
	-- Create the list if needed
	local _, lListKey = Nemo.AddList( ListName, false, false )
	-- Create the list entry
	local lEntryExists   = Nemo:SearchTable(Nemo.D.LTMC[lListKey].entrytree, "value", 'Nemo.UI:CreateListEntryPanel("'..ID..'","'..Type..'")')
	local lNewEntryValue = 'Nemo.UI:CreateListEntryPanel("'..ID..'","'..Type..'")'					
	local lNewEntryText  = ''
	if ( Type == 's' ) then
		lNewEntryText = Nemo.GetSpellName(ID)
	elseif ( Type == 'i' ) then
		lNewEntryText = Nemo.GetItemName(ID)
	end
	local lNewEntry = { value = lNewEntryValue, text = lNewEntryText}
	lEntryExists = Nemo:SearchTable(Nemo.D.LTMC[lListKey].entrytree, "value", 'Nemo.UI:CreateListEntryPanel("'..ID..'","'..Type..'")')
	if ( lEntryExists ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lNewEntryText) ) end	
		if ( Nemo.D.UpdateMode==3 ) then return lNewEntryText, lEntryExists end --do not update or create new object if they exist
	else
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( '' ) end -- Clear any previous errors
		table.insert( Nemo.D.LTMC[lListKey].entrytree, lNewEntry)
	end
	lEntryExists = Nemo:SearchTable(Nemo.D.LTMC[lListKey].entrytree, "value", 'Nemo.UI:CreateListEntryPanel("'..ID..'","'..Type..'")')
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	return lNewEntryText, lEntryExists
end
function Nemo.GetListEntryExportString( ListKey, EntryKey )
	local EntryDB = Nemo.D.LTMC[ListKey].entrytree[EntryKey]
	local lID, lType = strmatch( EntryDB.value, 'CreateListEntryPanel%("([^"]+)","(%a)"%)' )
	return 'Nemo.AddListEntry([=['..Nemo.D.LTMC[ListKey].text..']=],false,"'..lID..'","'..lType..'");'.."\n"
end
--*****************************************************
--Lists Panel
--*****************************************************
function Nemo.UI:CreateListsPanel()
	-- Pause or resume the rightsgPanel fill layout if you need it or not
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()
	
	-- new list name edit box
	local ebListName = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebListName )
	ebListName:SetLabel( L["lists/ebListName/l"] )
	ebListName:SetWidth(480)
	ebListName:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 5, 0);
	ebListName:SetCallback( "OnEnterPressed", Nemo.UI.ebListNameOnEnterPressed )
end
--Lists Panel Callbacks----------------------------
function Nemo.UI.ebListNameOnEnterPressed(...)
	local lNewListName = select(3,...)
	local _,lNewListKey = Nemo.AddList( lNewListName, false, true )
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..Nemo.D.LTMC[lNewListKey].value)
end
--*****************************************************
--Specific List Panel
--*****************************************************
function Nemo.UI:CreateListPanel(ListName)
	Nemo.UI.DB = {}
	Nemo.UI.DB = Nemo.D.LTMC[Nemo.UI.STL[2]]
	
	-- Pause or resume the rightsgPanel fill layout if you need it or not
	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()

	-- List of spells tree goes in the sgPanel on right
	Nemo.UI.sgMain.tgMain.sgPanel.tgList = Nemo.UI:Create("TreeGroup")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.tgList )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetTree( Nemo.UI.DB.entrytree )

	Nemo.UI.sgMain.tgMain.sgPanel:SetHeight(400)
	--Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetHeight( 50 )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetTreeWidth( 350, true )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetFullWidth(true)

	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetCallback( "OnGroupSelected", Nemo.UI.tgListOnGroupSelected )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:EnableButtonTooltips( false )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetCallback( "OnButtonEnter", function(self, path, frame)
		local _,_,spellID = string.find(frame, '"(.*)","s"')
		local _,_,itemID = string.find(frame, '"(.*)","i"')
		if ( itemID ) then
			Nemo.UI.ShowTooltip(Nemo.UI.sgMain.tgMain.frame, select(2,GetItemInfo( itemID )), "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "link")
		elseif ( spellID ) then

			Nemo.UI.ShowTooltip(Nemo.UI.sgMain.tgMain.frame, GetSpellLink( spellID ), "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "link")
		end
	end )
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:SetCallback( "OnButtonLeave", Nemo.UI.HideTooltip )

	-- Create the Entry panel on the right
	Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel = Nemo.UI:Create("SimpleGroup")
	Nemo.UI.sgMain.tgMain.sgPanel.tgList:AddChild(Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel)
	Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel:SetLayout("List")
	Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel:SetFullWidth(true)


	-- New spell list entry edit box
	Nemo.UI.sgMain.tgMain.sgPanel.ebAddSpellEntry = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebAddSpellEntry )
	local ebAddSpellEntry = Nemo.UI.sgMain.tgMain.sgPanel.ebAddSpellEntry
	ebAddSpellEntry:SetLabel( L["list/ebAddSpellEntry/l"] )
	ebAddSpellEntry:SetWidth(497)
	ebAddSpellEntry:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.tgList.frame, "BOTTOMLEFT", -4, 5);
	ebAddSpellEntry:SetCallback( "OnEnterPressed", Nemo.UI.ebAddSpellEntryOnEnterPressed )
	ebAddSpellEntry:SetCallback( "OnTextChanged", Nemo.UI.ebAddSpellEntryOnTextChanged )
	ebAddSpellEntry:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ebAddSpellEntry/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 5, "text") end )
	ebAddSpellEntry:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Spell Link interactive label
	Nemo.UI.sgMain.tgMain.sgPanel.ilSpellLink = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ilSpellLink )
	local ilSpellLink = Nemo.UI.sgMain.tgMain.sgPanel.ilSpellLink
	ilSpellLink:SetWidth(250)
	ilSpellLink.Tooltip=nil
	ilSpellLink:SetPoint("TOPRIGHT", ebAddSpellEntry.frame, "TOPRIGHT", 0, -5);
	ilSpellLink:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, self.Tooltip, "LEFT", "RIGHT", 0, 0, "link") end )
	ilSpellLink:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- New item list entry edit box
	Nemo.UI.sgMain.tgMain.sgPanel.ebAddItemEntry = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebAddItemEntry )
	local ebAddItemEntry = Nemo.UI.sgMain.tgMain.sgPanel.ebAddItemEntry
	ebAddItemEntry:SetLabel( L["list/ebAddItemEntry/l"] )
	ebAddItemEntry:SetWidth(497)
	ebAddItemEntry:SetPoint("TOPLEFT", ebAddSpellEntry.frame, "BOTTOMLEFT", 0, 6);
	ebAddItemEntry:SetCallback( "OnEnterPressed", Nemo.UI.ebAddItemEntryOnEnterPressed )
	ebAddItemEntry:SetCallback( "OnTextChanged", Nemo.UI.ebAddItemEntryOnTextChanged )
	ebAddItemEntry:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ebAddItemEntry/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 5, "text") end )
	ebAddItemEntry:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Item Link interactive label
	Nemo.UI.sgMain.tgMain.sgPanel.ilItemLink = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ilItemLink )
	local ilItemLink = Nemo.UI.sgMain.tgMain.sgPanel.ilItemLink
	ilItemLink:SetWidth(250)
	ilItemLink.Tooltip=nil
	ilItemLink:SetPoint("TOPRIGHT", ebAddItemEntry.frame, "TOPRIGHT", 0, -5);
	ilItemLink:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, self.Tooltip, "LEFT", "RIGHT", 0, 0, "link") end )
	ilItemLink:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	
	-- Rename List edit box
	local ebRenameList = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebRenameList )
	ebRenameList:SetLabel( L["list/ebRenameList/l"] )
	ebRenameList:SetWidth(497)
	ebRenameList:SetPoint("TOPLEFT", ebAddItemEntry.frame, "BOTTOMLEFT", 0, 6)
	ebRenameList:SetCallback( "OnEnterPressed", Nemo.UI.ebRenameListOnEnterPressed )
	ebRenameList:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ebRenameList/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebRenameList:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebRenameList:SetText( Nemo.UI.DB.text )
	


	-- Copy List edit box
	local ebCopyList = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebCopyList )
	ebCopyList:SetLabel( L["list/ebCopyList/l"] )
	ebCopyList:SetWidth(497)
	ebCopyList:SetPoint("TOPLEFT", ebRenameList.frame, "BOTTOMLEFT", 0, 6);
	ebCopyList:SetCallback( "OnEnterPressed", Nemo.UI.ebCopyListOnEnterPressed )
	ebCopyList:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ebCopyList/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebCopyList:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	
	
	-- Move up interactive label
	local ilLMoveUp = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilLMoveUp )
	ilLMoveUp:SetWidth(40);ilLMoveUp:SetHeight(40)
	ilLMoveUp:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up")
	ilLMoveUp:SetImageSize(40, 40)
	ilLMoveUp:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Highlight")
	ilLMoveUp:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", -5, -545);
	ilLMoveUp:SetCallback( "OnClick", function() Nemo.UI.bMoveList(-1) end )
	ilLMoveUp:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ilLMoveUp/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilLMoveUp:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Move down interactive label
	local ilLMoveDown = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilLMoveDown )
	ilLMoveDown:SetWidth(40);ilLMoveDown:SetHeight(40)
	ilLMoveDown:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up")
	ilLMoveDown:SetImageSize(40, 40)
	ilLMoveDown:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Highlight")
	ilLMoveDown:SetPoint("TOPLEFT", ilLMoveUp.frame, "BOTTOMLEFT", 0, 5);
	ilLMoveDown:SetCallback( "OnClick", function() Nemo.UI.bMoveList(1) end )
	ilLMoveDown:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/ilLMoveDown/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilLMoveDown:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Delete List button
	local bListDelete = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bListDelete )
	bListDelete:SetWidth(100)
	bListDelete:SetText(L["common/delete"])
	bListDelete:SetPoint("TOPLEFT", ilLMoveDown.frame, "TOPRIGHT", 0, -10);
	bListDelete:SetCallback( "OnClick", Nemo.UI.bListDeleteOnClick )
	bListDelete:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/bListDelete/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bListDelete:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )



end
--List Panel Callbacks-----------------------------
function Nemo.UI.tgListOnGroupSelected(self)
	self:RefreshTree()														--Refresh the tree so .selected gets updated
	Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel:ReleaseChildren()		--Clears the right panel in the list Entry tree
	Nemo.UI.SelectedListEntryKey=nil										--Save the selected list entry for global scope
	Nemo.UI.SelectedListEntryTable=nil
	for k,v in pairs(self.buttons) do
		if ( v.selected ) then
			if ( Nemo:SearchTable( Nemo.D.LTMC[Nemo.UI.STL[2]].entrytree, "value", v.value ) ) then
				Nemo.UI.SelectedListEntryKey = k
				Nemo.UI.SelectedListEntryTable = v
			end
		end
	end
	if( not Nemo.UI.SelectedListEntryKey ) then
		--Nemo:dprint("Error: tgListOnGroupSelected called without a button selection")
	else
		Nemo.D.RunCode( Nemo.UI.SelectedListEntryTable.value, '', "error pcall:", false, true  )

		-- local func, errorMessage = loadstring(Nemo.UI.SelectedListEntryTable.value)	-- Use the .value field to create a function specific to the button
		-- if( not func ) then	Nemo:dprint("Error: tgListOnGroupSelected loadingstring:"..Nemo.UI.SelectedListEntryTable.value.." Error:"..errorMessage) return end
		-- local success, errorMessage = pcall(func);								-- Call the button specific function we loaded
		-- if( not success ) then
			-- Nemo:dprint("error pcall:"..errorMessage)
		-- end
	end
end
function Nemo.UI:CreateListEntryPanel()
	-- Delete List Entry button
	local bEntryDelete = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel:AddChild( bEntryDelete )
	bEntryDelete:SetText( L["common/delete"] )
	bEntryDelete:SetFullWidth(true)
	bEntryDelete:SetPoint("BOTTOMRIGHT", Nemo.UI.sgMain.tgMain.sgPanel.tgList.sgEntryPanel.frame, "BOTTOMRIGHT", 0, 0);
	bEntryDelete:SetCallback( "OnClick", function() Nemo.UI.bEntryDeleteOnClick() end )
	bEntryDelete:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["list/bEntryDelete/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bEntryDelete:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
end
function Nemo.UI.bEntryDeleteOnClick()
	if ( Nemo:isblank(Nemo.UI.SelectedListEntryKey) ) then return end

	local SavedValue	= Nemo.D.LTMC[Nemo.UI.STL[2]].value
	tremove(Nemo.D.LTMC[Nemo.UI.STL[2]].entrytree, Nemo.UI.SelectedListEntryKey)
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..SavedValue)
end
function Nemo.UI.ebRenameListOnEnterPressed(...)
	local lListName = select(3, ...)
	if ( Nemo.UI.EntryHasErrors( lListName ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], lListName) )
		return
	end

	local NewListText = lListName
	local NewListValue = 'Nemo.UI:CreateListPanel([=['..lListName..']=])'
	if ( Nemo:SearchTable(Nemo.D.LTMC, "text", lListName) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lListName) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) 														-- Clear any previous errors
		Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].text = NewListText
		Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].value = NewListValue	
		Nemo.UI.sgMain.tgMain:RefreshTree() 													-- Refresh the tree
		-- Nemo.AButtons.bInitComplete = false														-- List was renamed
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..NewListValue)
	end
end
function Nemo.UI.ebAddSpellEntryOnEnterPressed(...)
	local lEntryID = select(3,...)
	Nemo.AddListEntry( Nemo.D.LTMC[Nemo.UI.STL[2]].text, true, lEntryID, 's' )
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..Nemo.D.LTMC[Nemo.UI.STL[2]].value)
end
function Nemo.UI.ebAddSpellEntryOnTextChanged(...)
	local spell = select(3, ...)
	Nemo.UI.sgMain.tgMain.sgPanel.ilSpellLink:SetText( GetSpellLink( spell ) )
	Nemo.UI.sgMain.tgMain.sgPanel.ilSpellLink.Tooltip = GetSpellLink( spell)
end
function Nemo.UI.ebAddItemEntryOnEnterPressed(...)
	local lEntryID = select(3,...)
	Nemo.AddListEntry( Nemo.D.LTMC[Nemo.UI.STL[2]].text, true, lEntryID, 'i' )
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..Nemo.D.LTMC[Nemo.UI.STL[2]].value)
end
function Nemo.UI.ebAddItemEntryOnTextChanged(...)
	local itemID = Nemo.GetItemId( select(3, ...) )
	if ( itemID ) then
		Nemo.UI.sgMain.tgMain.sgPanel.ilItemLink:SetText( (select(2,GetItemInfo( itemID )) or "")..' '..(itemID or "") )
		Nemo.UI.sgMain.tgMain.sgPanel.ilItemLink.Tooltip = select(2,GetItemInfo( itemID ))
	end
end
function Nemo.UI.ebCopyListOnEnterPressed(...)
	local lListName = select(3, ...)
	if ( Nemo.UI.EntryHasErrors( lListName ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], lListName) )
		return
	end
	local NewList = Nemo:CopyTable( Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]] )
	NewList.text = lListName
	NewList.value = 'Nemo.UI:CreateListPanel([=['..lListName..']=])'
	if ( Nemo:SearchTable(Nemo.D.LTMC, "text", lListName) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lListName) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) 											-- Clear any previous errors
		table.insert( Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children, NewList)
		Nemo.UI.sgMain.tgMain:RefreshTree()
	end
end
function Nemo.UI.bListDeleteOnClick(...)
	local deleteKey = Nemo.UI.STL[2]
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value)
	tremove(Nemo.D.LTMC, deleteKey)
	Nemo.UI.sgMain.tgMain:RefreshTree() 										-- Gets rid of the rotation from the tree
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
	-- Nemo.AButtons.bInitComplete = false											-- List was deleted
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value)						-- Select the list main tree
	Nemo.UI.HideTooltip()
end
function Nemo.UI.bMoveList(movevalue)
	local SavedValue	= Nemo.D.LTMC[Nemo.UI.STL[2]].value
	local SavedList		= Nemo:CopyTable(Nemo.UI.DB)							-- Deepcopy the list from the profile db
	local maxKey		= #(Nemo.D.LTMC)
	tremove(Nemo.D.LTMC, Nemo.UI.STL[2])
	Nemo.UI.STL[2] = Nemo.UI.STL[2]+movevalue											-- Now change the key value to up or down
	if ( Nemo.UI.STL[2] < 1) then Nemo.UI.STL[2] = 1 end
	if ( Nemo.UI.STL[2] > maxKey ) then Nemo.UI.STL[2] = maxKey end
	tinsert(Nemo.D.LTMC, Nemo.UI.STL[2], SavedList)
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.LTM.value.."\001"..SavedValue)
end