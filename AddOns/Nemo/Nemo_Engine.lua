local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Locals
-------------------------------------------------------
local tremove = table.remove

Nemo.Engine 		= {}
Nemo.Engine.Queue 	= {}

Nemo.Engine.QueueSorter = function( a, b )
	if ( not a or not b ) then return end
    local aTimeUntilNeeded = a._nemo_time_until_needed or 0
    local bTimeUntilNeeded = b._nemo_time_until_needed or 0
    local aATK = a._nemo_action_tree_key	-- Action tree key or priority
    local bATK = b._nemo_action_tree_key	-- Action tree key or priority
	
	if ( aTimeUntilNeeded == bTimeUntilNeeded ) then
		return aATK < bATK
    -- elseif math.abs(aTimeUntilNeeded - bTimeUntilNeeded) < 1 then	-- smooth out sorting with 1 second
        -- return aTimeUntilNeeded < bTimeUntilNeeded
    else
        return aTimeUntilNeeded < bTimeUntilNeeded
    end
end

Nemo.Engine.GetQueueSlot = function( NemoSABFrame )
	for k, v in pairs(Nemo.Engine.Queue) do
		if ( v == NemoSABFrame ) then
			return k
		end
	end
	return 0
end

Nemo.Engine.ActionExistsInQueue = function( NemoSABFrame )
	for k, v in pairs(Nemo.Engine.Queue) do
		if ( v == NemoSABFrame ) then
-- print("  found NemoSABFrame "..NemoSABFrame._nemo_action_text..' in queue slot ['..k..'] already')
			return k
		-- elseif ( v._nemo_action_db.at == "spell" and v._nemo_action_db.att2 == NemoSABFrame._nemo_action_db.att2 ) then	-- Why did I do this? It is causing problems by blocking other actions that have same spell ID
-- print("  found spell att2 "..NemoSABFrame._nemo_action_text..' in queue slot ['..k..'] already')
			-- return k
		-- elseif ( v._nemo_action_db.at == "item" and v._nemo_action_db.att1 == NemoSABFrame._nemo_action_db.att1 ) then
-- print("  found item att1 "..NemoSABFrame._nemo_action_text..' in queue slot ['..k..'] already')
			-- return k
		end
	end
	return nil
end

Nemo.Engine.RemoveFromQueue = function( NemoSABFrame )
	local lQueueSlot	= Nemo.Engine.GetQueueSlot(NemoSABFrame)
	if ( lQueueSlot > 0 ) then
		table.remove( Nemo.Engine.Queue, lQueueSlot )
	end
end

Nemo.Engine.AddToQueue = function( NemoSABFrame )
	Nemo.Engine.Queue[#Nemo.Engine.Queue+1] = NemoSABFrame
end

Nemo.Engine.PrintQueue = function()
	for k, v in pairs(Nemo.Engine.Queue) do
		Nemo:dprint("[QSlot="..k.."][atk="..v._nemo_action_tree_key.."][TimeUntilNeeded="..tostring( v._nemo_time_until_needed ).."]="..v._nemo_action_text)
	end
end

Nemo.Engine.GetQueueSlotInfo = function( queue_slot )
	-- lQSSABFrame, lQSType, lQSGID, lQSTexture, lQSLink, lExternalFrame, lExternalSlot = Nemo.Engine.GetQueueSlotInfo(N)
	local lQSSABFrame    = nil	-- Queue slot SABFrame
	local lQSType        = nil
	local lQSGID         = nil
	local lQSTexture     = nil
	local lQSLink        = nil
	local lExternalFrame = nil
	local lExternalSlot  = nil
	if ( Nemo.Engine.Queue[queue_slot] ) then
		lQSSABFrame = Nemo.Engine.Queue[queue_slot]
		lQSType = lQSSABFrame._nemo_action_db.at
		lQSGID  = lQSSABFrame._nemo_gid
		lQSTexture = _G[lQSSABFrame:GetName().."Icon"]:GetTexture()		
		lQSLink = Nemo.UI.GetActionLink( lQSType, lQSSABFrame._nemo_action_db.att1, lQSSABFrame._nemo_action_db.att2 )
		lExternalFrame = lQSSABFrame._nemo_external_frame
		lExternalSlot = lQSSABFrame._nemo_external_slot
		
		return lQSSABFrame, lQSType, lQSGID, lQSTexture, lQSLink, lExternalFrame, lExternalSlot
	end
end

Nemo.Engine.Fire = function()
	--********************************************************************************************
	--	Finds the highest priority action with criteria that passes, called from Anchor frame OnUpdate
	--********************************************************************************************
	Nemo.D.P.AuditTrackedData() 												-- Cleanup expired tracked spells and units
	if ( not Nemo.AButtons.bInitComplete ) then Nemo.AButtons.Initialize() end 	-- Check if AButtons need to be initialized
	if ( Nemo.D.LDB ) then														-- Update lib databroker text
		if ( Nemo.DB.profile.options.sr ) then
			Nemo.D.LDB.text = L["common/nemo"].." "..tostring( Nemo.DB.profile.options.sr or "" )
		else
			Nemo.D.LDB.text = L["common/nemo"]
		end
	end
	
-- local startDTime = debugprofilestop()
	for rtk,rotation in pairs(Nemo.D.RTMC) do
		local bCurrentRotation = (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == rotation.text))
		if ( bCurrentRotation ) then
			for atk,action in pairs(Nemo.D.RTMC[rtk].children) do
				if ( Nemo.AButtons.Frames[rotation.text] and Nemo.AButtons.Frames[rotation.text][atk] ) then
					Nemo.AButtons.SetQueueInfo( Nemo.AButtons.Frames[rotation.text][atk] )
				end
			end
			table.sort(Nemo.Engine.Queue, Nemo.Engine.QueueSorter)
		end
-- local startDTime = debugprofilestop()
		for atk,action in pairs(Nemo.D.RTMC[rtk].children) do
			if ( Nemo.AButtons.Frames[rotation.text] and Nemo.AButtons.Frames[rotation.text][atk] ) then
-- Nemo:dprint("calling select behavior for "..action.text)
				Nemo.AButtons.SelectBehavior( Nemo.AButtons.Frames[rotation.text][atk] )
-- Nemo:eprint(" A1:"..action.text, startDTime, .20)	
			end
		end
	end
	
	if ( Nemo.DB.profile.options.printhp and Nemo.Engine.Queue[1] and Nemo.Engine.Queue[1] ~= Nemo.D.LastQueueSlot1 ) then
		print( Nemo.Engine.Queue[1]._nemo_action_text.." |cffF95C25T:|r"..GetTime() )
		Nemo.D.LastQueueSlot1 = Nemo.Engine.Queue[1]
	end
				
-- Nemo:eprint(" all rotations SelectBehavior elapsed:", startDTime, 0)	
	--Performance information
	-- print("Queue count="..#(Nemo.Engine.Queue))

	Nemo.UI.fAnchor.bEngineCanFire=true	-- Allow the anchor frame to fire the engine again
end