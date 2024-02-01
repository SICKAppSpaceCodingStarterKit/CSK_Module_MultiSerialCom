---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiSerialCom_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiSerialCom'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiSerialCom = Timer.create()
tmrMultiSerialCom:setExpirationTime(300)
tmrMultiSerialCom:setPeriodic(false)

local multiSerialCom_Model -- Reference to model handle
local multiSerialCom_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiSerialCom/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiSerialCom.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiSerialCom.OnNewResultNUM", "MultiSerialCom_OnNewResultNUM")
Script.serveEvent("CSK_MultiSerialCom.OnNewValueToForwardNUM", "MultiSerialCom_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiSerialCom.OnNewValueUpdateNUM", "MultiSerialCom_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiSerialCom.OnNewEvent", "MultiSerialCom_OnNewEvent")
Script.serveEvent('CSK_MultiSerialCom.OnNewResult', 'MultiSerialCom_OnNewResult')

Script.serveEvent('CSK_MultiSerialCom.OnNewStatusRegisteredEvent', 'MultiSerialCom_OnNewStatusRegisteredEvent')

Script.serveEvent("CSK_MultiSerialCom.OnNewStatusLoadParameterOnReboot", "MultiSerialCom_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiSerialCom.OnPersistentDataModuleAvailable", "MultiSerialCom_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiSerialCom.OnNewParameterName", "MultiSerialCom_OnNewParameterName")

Script.serveEvent("CSK_MultiSerialCom.OnNewInstanceList", "MultiSerialCom_OnNewInstanceList")
Script.serveEvent("CSK_MultiSerialCom.OnNewProcessingParameter", "MultiSerialCom_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiSerialCom.OnNewSelectedInstance", "MultiSerialCom_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiSerialCom.OnDataLoadedOnReboot", "MultiSerialCom_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiSerialCom.OnUserLevelOperatorActive", "MultiSerialCom_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiSerialCom.OnUserLevelMaintenanceActive", "MultiSerialCom_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiSerialCom.OnUserLevelServiceActive", "MultiSerialCom_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiSerialCom.OnUserLevelAdminActive", "MultiSerialCom_OnUserLevelAdminActive")

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiSerialCom_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiSerialCom_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiSerialCom_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiSerialCom_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiSerialCom_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
end

--- Function to get access to the multiSerialCom_Model object
---@param handle handle Handle of multiSerialCom_Model object
local function setMultiSerialCom_Model_Handle(handle)
  multiSerialCom_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiSerialCom_Model_Handle = setMultiSerialCom_Model_Handle

--- Function to get access to the multiSerialCom_Instances object
---@param handle handle Handle of multiSerialCom_Instances object
local function setMultiSerialCom_Instances_Handle(handle)
  multiSerialCom_Instances = handle
  if multiSerialCom_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiSerialCom_Instances do
    Script.register("CSK_MultiSerialCom.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiSerialCom_Instances do
    Script.register("CSK_MultiSerialCom.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiSerialCom_Instances_Handle = setMultiSerialCom_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiSerialCom_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiSerialCom_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiSerialCom_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiSerialCom_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiSerialCom_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiSerialCom()
  -- Script.notifyEvent("MultiSerialCom_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiSerialCom_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiSerialCom_OnNewInstanceList", helperFuncs.createStringListBySize(#multiSerialCom_Instances))

  Script.notifyEvent("MultiSerialCom_OnNewStatusRegisteredEvent", multiSerialCom_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent("MultiSerialCom_OnNewStatusLoadParameterOnReboot", multiSerialCom_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiSerialCom_OnPersistentDataModuleAvailable", multiSerialCom_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiSerialCom_OnNewParameterName", multiSerialCom_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiSerialCom, "OnExpired", handleOnExpiredTmrMultiSerialCom)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiSerialCom:start()
  return ''
end
Script.serveFunction("CSK_MultiSerialCom.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiSerialCom_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiSerialCom:start()
end
Script.serveFunction("CSK_MultiSerialCom.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiSerialCom_Instances
end
Script.serveFunction("CSK_MultiSerialCom.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiSerialCom_Instances, multiSerialCom_Model.create(#multiSerialCom_Instances+1))
  Script.deregister("CSK_MultiSerialCom.OnNewValueToForward" .. tostring(#multiSerialCom_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiSerialCom.OnNewValueToForward" .. tostring(#multiSerialCom_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiSerialCom()
end
Script.serveFunction('CSK_MultiSerialCom.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiSerialCom_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiSerialCom_Instances[totalAmount])
    multiSerialCom_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiSerialCom()
end
Script.serveFunction('CSK_MultiSerialCom.resetInstances', resetInstances)

local function setRegisterEvent(event)
  multiSerialCom_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiSerialCom.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiSerialCom_Instances[selectedInstance].parameters.registeredEvent)

  --Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'value', multiSerialCom_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiSerialCom_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiSerialCom_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiSerialCom.setParameterName", setParameterName)

local function sendParameters()
  if multiSerialCom_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiSerialCom_Instances[selectedInstance].parameters), multiSerialCom_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiSerialCom_Instances[selectedInstance].parametersName, multiSerialCom_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiSerialCom_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiSerialCom_Instances[selectedInstance].parametersName, multiSerialCom_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiSerialCom parameters with name '" .. multiSerialCom_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiSerialCom.sendParameters", sendParameters)

local function loadParameters()
  if multiSerialCom_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiSerialCom_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiSerialComObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiSerialCom_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      CSK_MultiSerialCom.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiSerialCom:start()
end
Script.serveFunction("CSK_MultiSerialCom.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiSerialCom_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiSerialCom.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    for j = 1, #multiSerialCom_Instances do
      multiSerialCom_Instances[j].persistentModuleAvailable = false
    end
  else
    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
      -- Check for amount if instances to create
      if totalInstances then
        local c = 2
        while c <= totalInstances do
          addInstance()
          c = c+1
        end
      end
    end

    for i = 1, #multiSerialCom_Instances do
      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

      if parameterName then
        multiSerialCom_Instances[i].parametersName = parameterName
        multiSerialCom_Instances[i].parameterLoadOnReboot = loadOnReboot
      end

      if multiSerialCom_Instances[i].parameterLoadOnReboot then
        setSelectedInstance(i)
        loadParameters()
      end
    end
    Script.notifyEvent('MultiSerialCom_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

