---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiSerialComParameters = {}

  multiSerialComParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiSerialComParameters.showLog = true -- Status to show log data on UI

  multiSerialComParameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  multiSerialComParameters.processingFile = 'CSK_MultiSerialCom_Processing' -- which file to use for processing (will be started in own thread)
  multiSerialComParameters.active = false -- Status if connection should be active
  multiSerialComParameters.type = 'RS232' -- Type of serial interface, like 'RS232', 'RS422', 'RS485'
  multiSerialComParameters.baudrate = 115200 -- Used baudrate, like 1200,2400,4800,9600,19200,38400,57600,115200
  multiSerialComParameters.framingRxStart = 'None' -- Start framing for receiving, like 'None', 'STX', 'ETX', 'CR', 'LF', 'CR_LF'
  multiSerialComParameters.framingRxStop = 'None' -- Stop framing for receiving
  multiSerialComParameters.framingTxStart = 'None' -- Start framing for sending
  multiSerialComParameters.framingTxStop = 'None' -- Stop framing for sending

  multiSerialComParameters.framingBufferSizeRx = 10240 -- Maximum size of a packet which can be parsed by the received framing.
  multiSerialComParameters.framingBufferSizeTx = 10240 -- Maximum size of a packet which can be parsed by the transmitted framing.
  multiSerialComParameters.parity = 'N' -- Parity, like "N", "O", "E", "M", "S" (None, Odd, Even, Mark, Space)
  multiSerialComParameters.handshake = false -- true to enable Xon/Xoff handshake, false to disable

  multiSerialComParameters.receiveTimeout = 0 -- Timeout in ms to wait for received data. 0 is default and means directly return
  multiSerialComParameters.receiveQueueSize = 10 -- Internal queue size for the receive()-function
  multiSerialComParameters.discardIfFull = false -- Set to TRUE to discard the newest item which is currently added instead of discarding the oldest element
  multiSerialComParameters.warnOverruns = true -- Set to false to disable warning on overruns when using the receive()-function

  multiSerialComParameters.dataBits = 8 -- Number of data bits (8 or 7)
  multiSerialComParameters.flowControl = false -- Hardware flow control
  multiSerialComParameters.stopBits = 1 -- Number of stop bits (1 or 2)
  multiSerialComParameters.termination = false -- Internal termination

  multiSerialComParameters.interface = '' -- Interface to use

  return multiSerialComParameters
end
functions.getParameters = getParameters

return functions