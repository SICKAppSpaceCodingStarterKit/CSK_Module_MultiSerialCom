--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communication.MultiSerialCom.FlowConfig.MultiSerialCom_OnNewData')
require('Communication.MultiSerialCom.FlowConfig.MultiSerialCom_Transmit')

-- Reference to the multiSerialCom_Instances handle
local multiSerialComImageEdgeMatcher_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiSerialCom.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
