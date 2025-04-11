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
    for i = 1, #multiSerialCom_Instances do
      if multiSerialCom_Instances[i].parameters.flowConfigPriority then
        CSK_MultiSerialCom.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiSerialCom_Instances
---@param handle handle Handle of multiSerialCom_Instances object
local function setMultiSerialCom_Instances_Handle(handle)
  multiSerialCom_Instances = handle
end
return setMultiSerialCom_Instances_Handle