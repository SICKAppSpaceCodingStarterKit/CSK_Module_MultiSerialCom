---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiSerialCom'

-- Create kind of "class"
local multiSerialCom = {}
multiSerialCom.__index = multiSerialCom

multiSerialCom.styleForUI = 'None' -- Optional parameter to set UI style
multiSerialCom.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiSerialCom.styleForUI = theme
  Script.notifyEvent("MultiSerialCom_OnNewStatusCSKStyle", multiSerialCom.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiSerialComInstanceNo int Number of instance
---@return table[] self Instance of multiSerialCom
function multiSerialCom.create(multiSerialComInstanceNo)

  local self = {}
  setmetatable(self, multiSerialCom)

  self.multiSerialComInstanceNo = multiSerialComInstanceNo -- Number of this instance
  self.multiSerialComInstanceNoString = tostring(self.multiSerialComInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('Communication/MultiSerialCom/helper/funcs') -- Load helper functions

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiSerialCom_Parameter' .. self.multiSerialComInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  self.serialComHandle = nil -- Handle of serial communication
  self.open = false -- Status of serial connection
  self.availableInterfaces = Engine.getEnumValues('SerialPorts') or '' -- Available SerialCom interfaces
  self.availableInterfacesList = self.helperFuncs.createStringListBySimpleTable(self.availableInterfaces) -- List of available SerialCom interfaces

  self.availableTypes = Engine.getEnumValues('SerialComTypes') or ''

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  self.parameters.interface = self.availableInterfaces[1] -- Interface to use

  -- Parameters to give to the processing script
  self.multiSerialComProcessingParams = Container.create()
  self.multiSerialComProcessingParams:add('multiSerialComInstanceNumber', multiSerialComInstanceNo, "INT")
  self.multiSerialComProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")

  self.multiSerialComProcessingParams:add('showLog', self.parameters.showLog, "BOOL")
  self.multiSerialComProcessingParams:add('active', self.parameters.active, "BOOL")
  self.multiSerialComProcessingParams:add('interface', self.parameters.interface, "STRING")
  self.multiSerialComProcessingParams:add('type', self.parameters.type, "STRING")
  self.multiSerialComProcessingParams:add('baudrate', self.parameters.baudrate, "INT")
  self.multiSerialComProcessingParams:add('framingRxStart', self.parameters.framingRxStart, "STRING")
  self.multiSerialComProcessingParams:add('framingRxStop', self.parameters.framingRxStop, "STRING")
  self.multiSerialComProcessingParams:add('framingTxStart', self.parameters.framingTxStart, "STRING")
  self.multiSerialComProcessingParams:add('framingTxStop', self.parameters.framingTxStop, "STRING")
  self.multiSerialComProcessingParams:add('framingBufferSizeRx', self.parameters.framingBufferSizeRx, "INT")
  self.multiSerialComProcessingParams:add('framingBufferSizeTx', self.parameters.framingBufferSizeTx, "INT")
  self.multiSerialComProcessingParams:add('parity', self.parameters.parity, "STRING")
  self.multiSerialComProcessingParams:add('handshake', self.parameters.handshake, "BOOL")
  self.multiSerialComProcessingParams:add('receiveTimeout', self.parameters.receiveTimeout, "INT")
  self.multiSerialComProcessingParams:add('receiveQueueSize', self.parameters.receiveQueueSize, "INT")
  self.multiSerialComProcessingParams:add('discardIfFull', self.parameters.discardIfFull, "BOOL")
  self.multiSerialComProcessingParams:add('warnOverruns', self.parameters.warnOverruns, "BOOL")

  self.multiSerialComProcessingParams:add('dataBits', self.parameters.dataBits, "INT")
  self.multiSerialComProcessingParams:add('flowControl', self.parameters.flowControl, "BOOL")
  self.multiSerialComProcessingParams:add('stopBits', self.parameters.stopBits, "INT")
  self.multiSerialComProcessingParams:add('termination', self.parameters.termination, "BOOL")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiSerialComProcessingParams)

  return self
end

return multiSerialCom

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************