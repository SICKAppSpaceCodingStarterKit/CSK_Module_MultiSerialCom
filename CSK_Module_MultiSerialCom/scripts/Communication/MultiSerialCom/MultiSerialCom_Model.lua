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

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

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
  self.parameters.interface = self.availableInterfaces[1] -- Interface to use
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiSerialCom_Processing' -- which file to use for processing (will be started in own thread)
  self.parameters.active = false -- Status if connection should be active
  self.parameters.type = 'RS232' -- Type of serial interface, like 'RS232', 'RS422', 'RS485'
  self.parameters.baudrate = 115200 -- Used baudrate, like 1200,2400,4800,9600,19200,38400,57600,115200
  self.parameters.framingRxStart = 'None' -- Start framing for receiving, like 'None', 'STX', 'ETX', 'CR', 'LF', 'CR_LF'
  self.parameters.framingRxStop = 'None' -- Stop framing for receiving
  self.parameters.framingTxStart = 'None' -- Start framing for sending
  self.parameters.framingTxStop = 'None' -- Stop framing for sending

  self.parameters.framingBufferSizeRx = 10240 -- Maximum size of a packet which can be parsed by the received framing.
  self.parameters.framingBufferSizeTx = 10240 -- Maximum size of a packet which can be parsed by the transmitted framing.
  self.parameters.parity = 'N' -- Parity, like "N", "O", "E", "M", "S" (None, Odd, Even, Mark, Space)
  self.parameters.handshake = false -- true to enable Xon/Xoff handshake, false to disable

  self.parameters.receiveTimeout = 0 -- Timeout in ms to wait for received data. 0 is default and means directly return
  self.parameters.receiveQueueSize = 10 -- Internal queue size for the receive()-function
  self.parameters.discardIfFull = false -- Set to TRUE to discard the newest item which is currently added instead of discarding the oldest element
  self.parameters.warnOverruns = true -- Set to false to disable warning on overruns when using the receive()-function

  self.parameters.dataBits = 8 -- Number of data bits (8 or 7)
  self.parameters.flowControl = false -- Hardware flow control
  self.parameters.stopBits = 1 -- Number of stop bits (1 or 2)
  self.parameters.termination = false -- Internal termination

  -- Parameters to give to the processing script
  self.multiSerialComProcessingParams = Container.create()
  self.multiSerialComProcessingParams:add('multiSerialComInstanceNumber', multiSerialComInstanceNo, "INT")
  self.multiSerialComProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")

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