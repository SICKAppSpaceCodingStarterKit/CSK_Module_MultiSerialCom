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

local tempDataToSend = '' -- Data to send via 'transmitDataViaUI'
local tempLog = '' -- Latest log messages

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiSerialCom.transmitInstanceNUM", emptyFunction)
Script.serveFunction("CSK_MultiSerialCom.receiveInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiSerialCom.OnNewDataNUM", "MultiSerialCom_OnNewDataNUM")
Script.serveEvent("CSK_MultiSerialCom.OnNewValueToForwardNUM", "MultiSerialCom_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiSerialCom.OnNewValueUpdateNUM", "MultiSerialCom_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_MultiSerialCom.OnNewStatusModuleIsActive', 'MultiSerialCom_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiSerialCom.OnNewStatusTempDataToSend', 'MultiSerialCom_OnNewStatusTempDataToSend')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusLog', 'MultiSerialCom_OnNewStatusLog')

Script.serveEvent('CSK_MultiSerialCom.OnNewStatusConnected', 'MultiSerialCom_OnNewStatusConnected')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusAvailableInterfaces', 'MultiSerialCom_OnNewStatusAvailableInterfaces')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusInterface', 'MultiSerialCom_OnNewStatusInterface')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusCommunicationActive', 'MultiSerialCom_OnNewStatusCommunicationActive')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusType', 'MultiSerialCom_OnNewStatusType')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusBaudrate', 'MultiSerialCom_OnNewStatusBaudrate')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusFrameRxStart', 'MultiSerialCom_OnNewStatusFrameRxStart')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusFrameRxStop', 'MultiSerialCom_OnNewStatusFrameRxStop')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusFrameTxStart', 'MultiSerialCom_OnNewStatusFrameTxStart')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusFrameTxStop', 'MultiSerialCom_OnNewStatusFrameTxStop')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusBufferSizeRx', 'MultiSerialCom_OnNewStatusBufferSizeRx')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusBufferSizeTx', 'MultiSerialCom_OnNewStatusBufferSizeTx')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusParity', 'MultiSerialCom_OnNewStatusParity')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusHandshake', 'MultiSerialCom_OnNewStatusHandshake')

Script.serveEvent('CSK_MultiSerialCom.OnNewStatusReceiveTimeout', 'MultiSerialCom_OnNewStatusReceiveTimeout')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusReceiveQueueSize', 'MultiSerialCom_OnNewStatusReceiveQueueSize')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusDiscardIfFull', 'MultiSerialCom_OnNewStatusDiscardIfFull')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusWarnOverruns', 'MultiSerialCom_OnNewStatusWarnOverruns')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusDataBits', 'MultiSerialCom_OnNewStatusDataBits')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusFlowControl', 'MultiSerialCom_OnNewStatusFlowControl')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusStopBits', 'MultiSerialCom_OnNewStatusStopBits')
Script.serveEvent('CSK_MultiSerialCom.OnNewStatusTermination', 'MultiSerialCom_OnNewStatusTermination')

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

-- ************************ UI Events End **********************************
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
  if eventname == 'MultiSerialCom_OnNewStatusLog' then
    tempLog = value -- Temporary save latest log
  elseif eventname == 'MultiSerialCom_OnNewStatusConnected' then
    multiSerialCom_Instances[selectedInstance].open = value
  end
  
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
  if parameter == 'open' then
    multiSerialCom_Instances[instance][parameter] = value
  else
    --multiSerialCom_Instances[instance]['parameters'][parameter] = value
  end
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
  if _G.availableAPIs.specific then
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
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiSerialCom()

  updateUserLevel()

  Script.notifyEvent('MultiSerialCom_OnNewStatusModuleIsActive', _G.availableAPIs.specific)

  if _G.availableAPIs.specific then

    Script.notifyEvent('MultiSerialCom_OnNewSelectedInstance', selectedInstance)

    Script.notifyEvent('MultiSerialCom_OnNewStatusLog', tempLog)
    Script.notifyEvent('MultiSerialCom_OnNewStatusTempDataToSend', tempDataToSend)

    Script.notifyEvent('MultiSerialCom_OnNewStatusConnected', multiSerialCom_Instances[selectedInstance].open)
    Script.notifyEvent('MultiSerialCom_OnNewStatusCommunicationActive',  multiSerialCom_Instances[selectedInstance].parameters.active)

    Script.notifyEvent("MultiSerialCom_OnNewInstanceList", helperFuncs.createStringListBySize(#multiSerialCom_Instances))
    Script.notifyEvent('MultiSerialCom_OnNewStatusAvailableInterfaces', multiSerialCom_Instances[selectedInstance].availableInterfacesList)

    Script.notifyEvent('MultiSerialCom_OnNewStatusInterface', multiSerialCom_Instances[selectedInstance].parameters.interface)
    Script.notifyEvent('MultiSerialCom_OnNewStatusType', multiSerialCom_Instances[selectedInstance].parameters.type)

    Script.notifyEvent('MultiSerialCom_OnNewStatusType', multiSerialCom_Instances[selectedInstance].parameters.type)
    Script.notifyEvent('MultiSerialCom_OnNewStatusBaudrate', multiSerialCom_Instances[selectedInstance].parameters.baudrate)

    Script.notifyEvent('MultiSerialCom_OnNewStatusParity', multiSerialCom_Instances[selectedInstance].parameters.parity)
    Script.notifyEvent('MultiSerialCom_OnNewStatusHandshake', multiSerialCom_Instances[selectedInstance].parameters.handshake)

    Script.notifyEvent('MultiSerialCom_OnNewStatusReceiveTimeout', multiSerialCom_Instances[selectedInstance].parameters.receiveTimeout)
    Script.notifyEvent('MultiSerialCom_OnNewStatusReceiveQueueSize', multiSerialCom_Instances[selectedInstance].parameters.receiveQueueSize)
    Script.notifyEvent('MultiSerialCom_OnNewStatusDiscardIfFull', multiSerialCom_Instances[selectedInstance].parameters.discardIfFull)
    Script.notifyEvent('MultiSerialCom_OnNewStatusWarnOverruns', multiSerialCom_Instances[selectedInstance].parameters.warnOverruns)

    Script.notifyEvent('MultiSerialCom_OnNewStatusDataBits', multiSerialCom_Instances[selectedInstance].parameters.dataBits)
    Script.notifyEvent('MultiSerialCom_OnNewStatusFlowControl', multiSerialCom_Instances[selectedInstance].parameters.flowControl)
    Script.notifyEvent('MultiSerialCom_OnNewStatusStopBits', multiSerialCom_Instances[selectedInstance].parameters.stopBits)
    Script.notifyEvent('MultiSerialCom_OnNewStatusTermination', multiSerialCom_Instances[selectedInstance].parameters.termination)

    Script.notifyEvent("MultiSerialCom_OnNewStatusFrameRxStart", multiSerialCom_Instances[selectedInstance].parameters.framingRxStart)
    Script.notifyEvent("MultiSerialCom_OnNewStatusFrameRxStop", multiSerialCom_Instances[selectedInstance].parameters.framingRxStop)
    Script.notifyEvent("MultiSerialCom_OnNewStatusFrameTxStart", multiSerialCom_Instances[selectedInstance].parameters.framingTxStart)
    Script.notifyEvent("MultiSerialCom_OnNewStatusFrameTxStop", multiSerialCom_Instances[selectedInstance].parameters.framingTxStop)

    Script.notifyEvent("MultiSerialCom_OnNewStatusBufferSizeRx", multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeRx)
    Script.notifyEvent("MultiSerialCom_OnNewStatusBufferSizeTx", multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeTx)

    Script.notifyEvent("MultiSerialCom_OnNewStatusRegisteredEvent", multiSerialCom_Instances[selectedInstance].parameters.registeredEvent)

    Script.notifyEvent("MultiSerialCom_OnNewStatusLoadParameterOnReboot", multiSerialCom_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiSerialCom_OnPersistentDataModuleAvailable", multiSerialCom_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiSerialCom_OnNewParameterName", multiSerialCom_Instances[selectedInstance].parametersName)
  end
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
  _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
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
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiSerialCom_Instances, multiSerialCom_Model.create(#multiSerialCom_Instances+1))
  Script.deregister("CSK_MultiSerialCom.OnNewValueToForward" .. tostring(#multiSerialCom_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiSerialCom.OnNewValueToForward" .. tostring(#multiSerialCom_Instances) , handleOnNewValueToForward)
  Script.deregister("CSK_MultiSerialCom.OnNewValueUpdate" .. tostring(#multiSerialCom_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiSerialCom.OnNewValueUpdate" .. tostring(#multiSerialCom_Instances) , handleOnNewValueUpdate)
  handleOnExpiredTmrMultiSerialCom()
end
Script.serveFunction('CSK_MultiSerialCom.addInstance', addInstance)

local function resetInstances()
  _G.logger:fine(nameOfModule .. ": Reset instances.")
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

local function transmitDataViaUI()
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'transmit', tempDataToSend)
end
Script.serveFunction('CSK_MultiSerialCom.transmitDataViaUI', transmitDataViaUI)

local function setTempDataToSend(data)
  tempDataToSend = data
end
Script.serveFunction('CSK_MultiSerialCom.setTempDataToSend', setTempDataToSend)

local function setInterface(interface)
  -- First check if interface is already in use
  local check = true
  for i = 1, #multiSerialCom_Instances do
    if i ~=  selectedInstance then
      if multiSerialCom_Instances[i].parameters.interface == interface then
        check = false
      end
    end
  end

  if check == true then
    _G.logger:fine(nameOfModule .. ": Set interface to = " .. tostring(interface))
    multiSerialCom_Instances[selectedInstance].parameters.interface = interface
    Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'interface', interface)
  else
    _G.logger:info(nameOfModule .. ": Interface already used by another instance.")
    Script.notifyEvent('MultiSerialCom_OnNewStatusInterface', multiSerialCom_Instances[selectedInstance].parameters.interface)
  end
end
Script.serveFunction('CSK_MultiSerialCom.setInterface', setInterface)

local function setActive(status)
  if status == true then

    -- First check if interface is already in use in another instance
    local interface = multiSerialCom_Instances[selectedInstance].parameters.interface
    local check = true
    for i = 1, #multiSerialCom_Instances do
      if i ~=  selectedInstance then
        if multiSerialCom_Instances[i].parameters.interface == interface then
          check = false
        end
      end
    end

    if check == true then
      _G.logger:fine(nameOfModule .. ": Set activation status to = " .. tostring(status))
      multiSerialCom_Instances[selectedInstance].parameters.active = true
      Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'open')
    else
      _G.logger:info(nameOfModule .. ": Interface already used by another instance.")
      Script.notifyEvent('MultiSerialCom_OnNewStatusCommunicationActive',  false)
    end
  else
    Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'close')
  end
end
Script.serveFunction('CSK_MultiSerialCom.setActive', setActive)

local function setType(comType)
  _G.logger:fine(nameOfModule .. ": Set serial communication type to = " .. tostring(comType))
  multiSerialCom_Instances[selectedInstance].parameters.type = comType
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'type', comType)
end
Script.serveFunction('CSK_MultiSerialCom.setType', setType)

local function setBaudrate(baudrate)
  _G.logger:fine(nameOfModule .. ": Set baudrate to = " .. tostring(baudrate))
  multiSerialCom_Instances[selectedInstance].parameters.baudrate = baudrate
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'baudrate', baudrate)
end
Script.serveFunction('CSK_MultiSerialCom.setBaudrate', setBaudrate)

local function receive()
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'receive')
end
Script.serveFunction('CSK_MultiSerialCom.receive', receive)

local function setFramingRxStart(frame)
  _G.logger:fine(nameOfModule .. ": Set frame of RxStart to = " .. tostring(frame))
  multiSerialCom_Instances[selectedInstance].parameters.framingRxStart = frame
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingRxStart', frame)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingRxStart', setFramingRxStart)

local function setFramingRxStop(frame)
  _G.logger:fine(nameOfModule .. ": Set frame of RxStop to = " .. tostring(frame))
  multiSerialCom_Instances[selectedInstance].parameters.framingRxStop = frame
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingRxStop', frame)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingRxStop', setFramingRxStop)

local function setFramingTxStart(frame)
  _G.logger:fine(nameOfModule .. ": Set frame of TxStart to = " .. tostring(frame))
  multiSerialCom_Instances[selectedInstance].parameters.framingTxStart = frame
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingTxStart', frame)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingTxStart', setFramingTxStart)

local function setFramingTxStop(frame)
  _G.logger:fine(nameOfModule .. ": Set frame of TxStop to = " .. tostring(frame))
  multiSerialCom_Instances[selectedInstance].parameters.framingTxStop = frame
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingTxStop', frame)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingTxStop', setFramingTxStop)

local function setFramingBufferSizeRx(size)
  _G.logger:fine(nameOfModule .. ": Set framing buffer size of Rx to = " .. tostring(size))
  multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeRx = size
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingBufferSizeRx', size)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingBufferSizeRx', setFramingBufferSizeRx)

local function setFramingBufferSizeTx(size)
  _G.logger:fine(nameOfModule .. ": Set framing buffer size of Tx to = " .. tostring(size))
  multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeTx = size
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingBufferSizeTx', size)
end
Script.serveFunction('CSK_MultiSerialCom.setFramingBufferSizeTx', setFramingBufferSizeTx)

local function setParity(mode)
  _G.logger:fine(nameOfModule .. ": Set parity to = " .. tostring(mode))
  multiSerialCom_Instances[selectedInstance].parameters.parity = mode
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'parity', mode)
end
Script.serveFunction('CSK_MultiSerialCom.setParity', setParity)

local function setHandshake(status)
  _G.logger:fine(nameOfModule .. ": Set handshake mode to = " .. tostring(status))
  multiSerialCom_Instances[selectedInstance].parameters.handshake = status
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'handshake', status)
end
Script.serveFunction('CSK_MultiSerialCom.setHandshake', setHandshake)

local function setReceiveTimeout(time)
  _G.logger:fine(nameOfModule .. ": Set timeout of receive function to = " .. tostring(time))
  multiSerialCom_Instances[selectedInstance].parameters.receiveTimeout = time
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'receiveTimeout', time)
end
Script.serveFunction('CSK_MultiSerialCom.setReceiveTimeout', setReceiveTimeout)

local function setReceiveQueueSize(size)
  _G.logger:fine(nameOfModule .. ": Set size of receive function to = " .. tostring(size))
  multiSerialCom_Instances[selectedInstance].parameters.receiveQueueSize = size
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'receiveQueueSize', size)
end
Script.serveFunction('CSK_MultiSerialCom.setReceiveQueueSize', setReceiveQueueSize)

local function setDiscardIfFull(status)
  _G.logger:fine(nameOfModule .. ": Set mode of 'discard if full' to = " .. tostring(status))
  multiSerialCom_Instances[selectedInstance].parameters.discardIfFull = status
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'discardIfFull', status)
end
Script.serveFunction('CSK_MultiSerialCom.setDiscardIfFull', setDiscardIfFull)

local function setWarnOnOverruns(status)
  _G.logger:fine(nameOfModule .. ": Set status to warn on overruns of receive function to = " .. tostring(status))
  multiSerialCom_Instances[selectedInstance].parameters.warnOverruns = status
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'warnOverruns', status)
end
Script.serveFunction('CSK_MultiSerialCom.setWarnOnOverruns', setWarnOnOverruns)

local function setDataBits(bits)
  _G.logger:fine(nameOfModule .. ": Set size of dataBits to = " .. tostring(bits))
  multiSerialCom_Instances[selectedInstance].parameters.dataBits = bits
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'dataBits', bits)
end
Script.serveFunction('CSK_MultiSerialCom.setDataBits', setDataBits)

local function setFlowControl(status)
  _G.logger:fine(nameOfModule .. ": Set status of flow control to = " .. tostring(status))
  multiSerialCom_Instances[selectedInstance].parameters.flowControl = status
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'flowControl', status)
end
Script.serveFunction('CSK_MultiSerialCom.setFlowControl', setFlowControl)

local function setStopBits(bits)
  _G.logger:fine(nameOfModule .. ": Set stopBits to = " .. tostring(bits))
  multiSerialCom_Instances[selectedInstance].parameters.stopBits = bits
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'stopBits', bits)
end
Script.serveFunction('CSK_MultiSerialCom.setStopBits', setStopBits)

local function setTermination(status)
  _G.logger:fine(nameOfModule .. ": Set status of internal termination to = " .. tostring(status))
  multiSerialCom_Instances[selectedInstance].parameters.termination = status
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'termination', status)
end
Script.serveFunction('CSK_MultiSerialCom.setTermination', setTermination)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiSerialCom_Instances[selectedInstance].parameters.registeredEvent)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'interface', multiSerialCom_Instances[selectedInstance].parameters.interface)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'type', multiSerialCom_Instances[selectedInstance].parameters.type)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'baudrate', multiSerialCom_Instances[selectedInstance].parameters.baudrate)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingRxStart', multiSerialCom_Instances[selectedInstance].parameters.framingRxStart)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingRxStop', multiSerialCom_Instances[selectedInstance].parameters.framingRxStop)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingTxStart', multiSerialCom_Instances[selectedInstance].parameters.framingTxStart)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingTxStop', multiSerialCom_Instances[selectedInstance].parameters.framingTxStop)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingBufferSizeRx', multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeRx)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'framingBufferSizeTx', multiSerialCom_Instances[selectedInstance].parameters.framingBufferSizeTx)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'parity', multiSerialCom_Instances[selectedInstance].parameters.parity)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'handshake', multiSerialCom_Instances[selectedInstance].parameters.handshake)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'receiveTimeout', multiSerialCom_Instances[selectedInstance].parameters.receiveTimeout)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'receiveQueueSize', multiSerialCom_Instances[selectedInstance].parameters.receiveQueueSize)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'discardIfFull', multiSerialCom_Instances[selectedInstance].parameters.discardIfFull)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'warnOverruns', multiSerialCom_Instances[selectedInstance].parameters.warnOverruns)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'dataBits', multiSerialCom_Instances[selectedInstance].parameters.dataBits)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'flowControl', multiSerialCom_Instances[selectedInstance].parameters.flowControl)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'stopBits', multiSerialCom_Instances[selectedInstance].parameters.stopBits)
  Script.notifyEvent('MultiSerialCom_OnNewProcessingParameter', selectedInstance, 'termination', multiSerialCom_Instances[selectedInstance].parameters.termination)

  setActive(multiSerialCom_Instances[selectedInstance].parameters.active)
end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
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
    _G.logger:fine(nameOfModule .. ": Send MultiSerialCom parameters with name '" .. multiSerialCom_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
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
      _G.logger:fine(nameOfModule .. ": Loaded parameters for multiSerialComObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiSerialCom_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      if multiSerialCom_Instances[selectedInstance].parameters.active then
        
      end
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
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiSerialCom.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
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
if _G.availableAPIs.specific then
  Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)
end

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

