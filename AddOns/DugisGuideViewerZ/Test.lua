local DGV = DugisGuideViewer

function DGV:PLAYER_LOGIN_Test(addon)
	local RunSuite
	local testEventSubscriptions
	if DGV.Debug then
		if not WoWUnit then
			WoWUnit = {}
			setmetatable(WoWUnit, 
			{	
				__index = function(t,i)
					if not wowUnitNagShown then
						DGV:DebugFormat(" enabled. WoWUnit not installed")
					end
					wowUnitNagShown = true
					return DGV.NoOp
				end
			})
			RunSuite = DGV.NoOp
		end
		function DGV:Shouldnt(value)
			assert(not value)
		end
		function DGV:Should(value)
			assert(value)
		end
		function DGV:ShouldEqual(expected, actual, message)
			return WoWUnit.CheckEquals(expected, actual, message)
		end
		function DGV:ShouldBeWithinTolerance(expected, actual, tolerance, message)
			local diff = math.abs(expected-actual)
			if diff<=tolerance then return end
			
			if (message) then
				message = message..": ";
			else
				message = "";
			end;
			message = message..string.format("expected:<%s> but <%s> was not within tolerance:<%s>", 
				tostring(expected), tostring(actual), tostring(tolerance));
			error(message, 2)
		end
		function DGV:ShouldBeGreaterThan(less, actual)
			assert(actual>less)
		end
		function DGV:ShouldBeLessThan(greater, actual)
			assert(actual<greater)
		end
		
		local 
		function _xpcallHandler(msg)
			return msg, debugstack();
		end
		
		function DGV:RunTestWithArgs(...)
			local test = WoWUnit.queue;
			if test == nil then return end;
			
			WoWUnit.queue = test.next;
			
			local result = {};
			result.suite = test.suite;
			result.test = test.name;
			
			local framework = {};

			WoWUnit:Mock({ 
				createMock = WoWUnit_CreateMock;
				replayMocks = WoWUnit_ReplayMocks;
				verifyMocks = WoWUnit_VerifyMocks;
				resetMocks = WoWUnit_ResetMocks;
			});

			if test.setUp then framework = test.setUp(...); end;
			
			if test.mocks then WoWUnit:Mock(test.mocks) end;
			WoWUnit:Mock(WoWUnit.assertFunctions);
			
			local varargs = DGV.GetCreateTable(...)
			result.pass, result.message, result.trace = xpcall(function() test.test(framework, varargs:Unpack()) end, _xpcallHandler);
			varargs:Pool()
			if result.pass == true then result.message = nil end;
			
			WoWUnit:RemoveMocks();
			
			if test.tearDown then test.tearDown(framework, ...) end;
			
			WoWUnit:AddResult(result);
		end
	
		local testEventArgs
		if not RunSuite then
			RunSuite = function(suiteName, ...)
				WoWUnit:QueueTestSuite(suiteName)
				DGV:DebugFormat("Running test suite", "suiteName", suiteName)
				while WoWUnit:GetRemainingTestCount()>0 do
					DGV:RunTestWithArgs(...)
				end
				WoWUnitConsole:PrintTestResults();
			end
		end
	
		testEventSubscriptions = {}
		function DGV:OnTestEvent(event, ...)
			for suiteName,eventSub in pairs(testEventSubscriptions) do
				if event==eventSub then
					RunSuite(suiteName, event, ...)
				end
			end
		end
	end

	function DGV:RegisterTest(initFunc, triggerEvent)
		if DGV.Debug then
			local suite = DGV.GetCreateTable()
			suite.mocks = {}
			suite.setUp = DGV.NoOp
			suite.tearDown = DGV.NoOp
			local suiteName = initFunc(suite)
			WoWUnit:AddTestSuite(suiteName, suite)
			if not triggerEvent then
				RunSuite(suiteName)
			else
				DGV:RegisterEvent(triggerEvent, "OnTestEvent")
				testEventSubscriptions[suiteName] = triggerEvent
			end
		end
	end

	--Tests for declarations previously appearing in the TOC go here
	--DugisGuideViewer Unit Tests
	DGV:RegisterTest(
		function(suite)
			suite.setUp = function()
				local state = DGV.GetCreateTable()
				state.TEST_EVENT_count = 0
				state.TEST_EVENT_Method2_count = 0
				DGV.TEST_EVENT = function()
					state.TEST_EVENT_count = state.TEST_EVENT_count + 1
				end
				DGV.TEST_EVENT_Method2 = function()
					state.TEST_EVENT_Method2_count = state.TEST_EVENT_Method2_count + 1
				end
				DGV:RegisterEvent("TEST_EVENT")
				DGV:RegisterEvent("TEST_EVENT", "TEST_EVENT_Method2")
				DGV.eventFrame:GetScript("OnEvent")(DGV.eventFrame, "TEST_EVENT")
				return state
			end
			suite.tearDown = function(state)
				state:Pool()
				DGV:UnregisterEvent("TEST_EVENT", "TEST_EVENT_Method2")
				DGV:UnregisterEvent("TEST_EVENT")
			end
			suite.testBothEventHandlersShouldBeCalledOnce = function(state)
				DGV:ShouldEqual(1, state.TEST_EVENT_count)
				DGV:ShouldEqual(1, state.TEST_EVENT_Method2_count)
			end
			return "GivenAnEventRegisteredTwiceAndFired"
		end)


	--Util Unit Tests
	DGV:RegisterTest(
		function(suite)
			suite.setUp = function()
				return DGV.GetCreateTable("one", nil, 3)
			end
			suite.tearDown = function(state)
				state:Pool()
			end
			suite.testIndex1ShouldEqualone = function(state)
				DGV:ShouldEqual("one", state[1])
			end
			suite.testIndex2Shouldnt = function(state)
				DGV:Shouldnt(state[2])
			end
			suite.testIndex3ShouldEqual3 = function(state)
				DGV:ShouldEqual(3, state[3])
			end
			suite.testConcatentatedIPairsShouldEqual_onenil3 = function(state)
				local concat = ""
				for _,value in state:IPairs() do
					if not value then concat = concat.."nil"
					else concat = concat..value end
				end
				DGV:ShouldEqual("onenil3", concat)
			end
			return "GivenATablePopulatedWithStateUsingDGV_GetCreateTable"
		end)

	DGV:RegisterTest(
		function(suite)
			suite.setUp = function()
				local state = DGV.GetCreateTable()
				state:Insert("one")
				state:Insert(nil)
				state:Insert(3)
				return state
			end
			suite.tearDown = function(state)
				state:Pool()
			end
			suite.testIndex1ShouldEqualone = function(state)
				DGV:ShouldEqual("one", state[1])
			end
			suite.testIndex2Shouldnt = function(state)
				DGV:Shouldnt(state[2])
			end
			suite.testIndex3ShouldEqual3 = function(state)
				DGV:ShouldEqual(3, state[3])
			end
			return "GivenATablePopulatedWithStateUsingDGV_tInsert"
		end)
end
DGV:RegisterEvent("PLAYER_LOGIN", "PLAYER_LOGIN_Test") --Init Test after WoWUnit will have been loaded