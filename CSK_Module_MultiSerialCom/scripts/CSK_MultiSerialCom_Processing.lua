---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Communication/MultiSerialCom/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiSerialCom'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiSerialComInstanceNumber = scriptParams:get('multiSerialComInstanceNumber') -- number of this instance
local multiSerialComInstanceNumberString = tostring(multiSerialComInstanceNumber) -- number of this instance as string

-- Event to notify new received data
Script.serveEvent("CSK_MultiSerialCom.OnNewData" .. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewData" .. multiSerialComInstanceNumberString, 'string, int:?')
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiSerialCom.OnNewValueToForward".. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiSerialCom.OnNewValueUpdate" .. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewValueUpdate" .. multiSerialComInstanceNumberString, 'int, string, auto, int:?')

local serialHandle = nil -- Handle of serial connection
local log = {} -- Log of Serial communication

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false

processingParams.active = scriptParams:get('active')
processingParams.interface = scriptParams:get('interface')
processingParams.type = scriptParams:get('type')
processingParams.baudrate = scriptParams:get('baudrate')
processingParams.framingRxStart = scriptParams:get('framingRxStart')
processingParams.framingRxStop = scriptParams:get('framingRxStop')
processingParams.framingTxStart = scriptParams:get('framingTxStart')
processingParams.framingTxStop = scriptParams:get('framingTxStop')

processingParams.framingBufferSizeRx = scriptParams:get('framingBufferSizeRx')
processingParams.framingBufferSizeTx = scriptParams:get('framingBufferSizeTx')

processingParams.parity = scriptParams:get('parity')
processingParams.handshake = scriptParams:get('handshake')

processingParams.receiveTimeout = scriptParams:get('receiveTimeout')
processingParams.receiveQueueSize = scriptParams:get('receiveQueueSize')
processingParams.discardIfFull = scriptParams:get('discardIfFull')
processingParams.warnOverruns = scriptParams:get('warnOverruns')

processingParams.dataBits = scriptParams:get('dataBits')
processingParams.flowControl = scriptParams:get('flowControl')
processingParams.stopBits = scriptParams:get('stopBits')
processingParams.termination = scriptParams:get('termination')

-- Framing bytes
local stx = '\x02'
local etx = '\x03'
local lf = '\x0A'
local cr = '\x0D'
local cr_lf = '\x0D\x0A'

--- Function to convert string setting to hex
---@param frame string Frame to use
---@return binary result frame as binary string
local function checkFraming(frame)
  if frame == 'None' then
    return ''
  elseif frame == 'STX' then
    return stx
  elseif frame == 'ETX' then
    return etx
  elseif frame == 'LF' then
    return lf
  elseif frame == 'CR' then
    return cr
  elseif frame == 'CR_LF' then
    return cr_lf
  else
    return ''
  end
end

--- Function to notify latest log messages, e.g. to show on UI
local function sendLog()
  local tempLog = ''
  for i=1, #log do
    tempLog = tempLog .. tostring(log[i]) .. '\n'
  end
  if processingParams.activeInUI then
    Script.notifyEvent("MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'MultiSerialCom_OnNewStatusLog', tostring(tempLog))
  end
end

local function handleOnNewTransmit(data)
  if serialHandle then
    _G.logger:info(nameOfModule .. ": Transmit on instance No." .. multiSerialComInstanceNumberString)
    local numberOfSendBytes = SerialCom.transmit(serialHandle, data)

    table.insert(log, 1, DateTime.getTime() .. ' - SENT = ' .. tostring(data))
    if #log == 100 then
      table.remove(log, 100)
    end
    sendLog()

    return numberOfSendBytes

  else
    _G.logger:info(nameOfModule .. ": No Serial connection active.")
    return 0
  end
end
Script.serveFunction("CSK_MultiSerialCom.transmitInstance"..multiSerialComInstanceNumberString, handleOnNewTransmit, 'string', 'int:1')

local function receive()
  if serialHandle then
    local data = serialHandle:receive(processingParams.receiveTimeout)
    if #data == 0 then
      _G.logger:info(nameOfModule .. ": No data received.")
    else
      Script.notifyEvent("MultiSerialCom_OnNewData" .. multiSerialComInstanceNumberString, data)      
    end
  else
    _G.logger:info(nameOfModule .. ": Serial connection not active.")
  end
end
Script.serveFunction("CSK_MultiSerialCom.receiveInstance"..multiSerialComInstanceNumberString, receive)

--- Function to receive incoming serial data
---@param data binary The received data
---@param timeOfReceive int The timestamp in microseconds at which the first bytes of the frame were received.
local function handleOnReceive(data, timeOfReceive)

  _G.logger:info(nameOfModule .. ": Received data = " .. data)
  Script.notifyEvent("MultiSerialCom_OnNewData" .. multiSerialComInstanceNumberString, data, timeOfReceive)

  table.insert(log, 1, DateTime.getTime() .. ' - RECV = ' .. tostring(data))
  if #log == 100 then
    table.remove(log, 100)
  end
  sendLog()
end

--- Function to update the serial connection with new setup
local function updateSetup()

  if serialHandle then
    if serialHandle:isOpened() then
      SerialCom.close(serialHandle)
    end

    serialHandle:setType(processingParams.type)
    serialHandle:setBaudRate(processingParams.baudrate)
    serialHandle:setFramingBufferSize(processingParams.framingBufferSizeRx, processingParams.framingBufferSizeTx)
    serialHandle:setDataBits(processingParams.dataBits)
    serialHandle:setFlowControl(processingParams.flowControl)
    serialHandle:setFraming(checkFraming(processingParams.framingRxStart), checkFraming(processingParams.framingRxStop), checkFraming(processingParams.framingTxStart), checkFraming(processingParams.framingTxStop))
    serialHandle:setHandshake(processingParams.handshake)
    serialHandle:setParity(processingParams.parity)
    serialHandle:setReceiveQueueSize(processingParams.receiveQueueSize, processingParams.discardIfFull, processingParams.warnOverruns)
    serialHandle:setStopBits(processingParams.stopBits)
    serialHandle:setTermination(processingParams.termination)
    serialHandle:setFlowControl(processingParams.flowControl)

    if processingParams.active then
      local status = serialHandle:open()
      Script.notifyEvent("MultiSerialCom_OnNewValueUpdate" .. multiSerialComInstanceNumberString, multiSerialComInstanceNumber, 'open', status)

      if processingParams.activeInUI then
        Script.notifyEvent("MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'MultiSerialCom_OnNewStatusConnected', status)
      end

      if status then
        SerialCom.deregister(serialHandle, 'OnReceive', handleOnReceive)
        SerialCom.register(serialHandle, 'OnReceive', handleOnReceive)
      else
        _G.logger:info(nameOfModule .. ": Not possible to open port.")
      end
    end
  end
end

--- Function to clear SerialCom handle
local function clearHandle()
  if serialHandle then
    SerialCom.deregister(serialHandle, 'OnReceive', handleOnReceive)
    SerialCom.close(serialHandle)
    Script.releaseObject(serialHandle)
    serialHandle = nil
    collectgarbage()
  end
end

--- Function to create a new serial connection
local function openConnection()
  clearHandle()
  serialHandle = SerialCom.create(processingParams.interface)
  updateSetup()
end

--- Function to close the serial connection
local function closeConnection()
  clearHandle()
  Script.notifyEvent("MultiSerialCom_OnNewValueUpdate" .. multiSerialComInstanceNumberString, multiSerialComInstanceNumber, 'open', false)

  if processingParams.activeInUI then
    Script.notifyEvent("MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'MultiSerialCom_OnNewStatusConnected', false)
  end
end

--- Function to handle updates of processing parameters from Controller
---@param multiSerialComNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto?* Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiSerialComNo, parameter, value, internalObjectNo)

  if multiSerialComNo == multiSerialComInstanceNumber then -- set parameter only in selected script
    if value ~= nil then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiSerialComInstanceNo." .. tostring(multiSerialComNo) .. " to value = " .. tostring(value))
    else
      _G.logger:fine(nameOfModule .. ": Update status of '" .. parameter .. "' of multiSerialComInstanceNo." .. tostring(multiSerialComNo))
    end

    if parameter == 'open' then
      processingParams.active = true
      openConnection()
      if serialHandle:isOpened() then
        _G.logger:info(nameOfModule .. ": SerialCOM opened.")
      else
        _G.logger:warning(nameOfModule .. ": Not able to open SerialCOM.")
      end

    elseif parameter == 'close' then
      processingParams.active = false
      closeConnection()
      _G.logger:info(nameOfModule .. ": SerialCOM closed.")

    elseif parameter == 'interface' then
      processingParams[parameter] = value
      if serialHandle then
        closeConnection()
        openConnection()
      end

    elseif parameter == 'transmit' then
      handleOnNewTransmit(value)

    elseif parameter == 'receive' then
      receive()

    elseif parameter == 'registeredEvent' then
      _G.logger:info(nameOfModule .. ": Register instance " .. multiSerialComInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    else
      processingParams[parameter] = value
      updateSetup()
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiSerialCom.OnNewProcessingParameter", handleOnNewProcessingParameter)
