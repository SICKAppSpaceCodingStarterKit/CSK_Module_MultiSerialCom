---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
-- local availableAPIs = require('Mainfolder/Subfolder/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiSerialCom'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiSerialComInstanceNumber = scriptParams:get('multiSerialComInstanceNumber') -- number of this instance
local multiSerialComInstanceNumberString = tostring(multiSerialComInstanceNumber) -- number of this instance as string
--local viewerId = scriptParams:get('viewerId')
--local viewer = View.create(viewerId) --> if needed
-- e.g. local object = MachineLearning.DeepNeuralNetwork.create() -- Use any AppEngine CROWN needed

-- Event to notify result of processing
Script.serveEvent("CSK_MultiSerialCom.OnNewResult" .. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewResult" .. multiSerialComInstanceNumberString, 'bool') -- Edit this accordingly
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiSerialCom.OnNewValueToForward".. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiSerialCom.OnNewValueUpdate" .. multiSerialComInstanceNumberString, "MultiSerialCom_OnNewValueUpdate" .. multiSerialComInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false
--processingParams.showImage = scriptParams:get('showImage') -- if needed

-- optionally
--[[
local function setAllProcessingParameters(paramContainer)
  processingParams.paramA = paramContainer:get('paramA')
  processingParams.paramB = paramContainer:get('paramB')
  processingParams.selectedObject = paramContainer:get('selectedObject')

  -- ...

  processingParams.internalObjects = helperFuncs.convertContainer2Table(paramContainer:get('internalObjects'))

end
setAllProcessingParameters(scriptParams)
]]

local function handleOnNewProcessing(object)

  _G.logger:info(nameOfModule .. ": Check object on instance No." .. multiSerialComInstanceNumberString)

  -- Insert processing part
  -- E.g.
  --[[

  local result = someProcessingFunctions(object)

  Script.notifyEvent("MultiSerialCom_OnNewValueUpdate" .. multiSerialComInstanceNumberString, multiSerialComInstanceNumber, 'valueName', result, processingParams.selectedObject)

  if processingParams.showImage and processingParams.activeInUI then
    viewer:addImage(image)
    viewer:present("LIVE")
  end
  ]]

  --_G.logger:info(nameOfModule .. ": Processing on MultiSerialCom" .. multiSerialComInstanceNumberString .. " was = " .. tostring(result))
  --Script.notifyEvent('MultiSerialCom_OnNewResult'.. multiSerialComInstanceNumberString, true)

  --Script.notifyEvent("MultiSerialCom_OnNewValueToForward" .. multiSerialComInstanceNumberString, 'MultiColorSelection_CustomEventName', 'content')

  Script.releaseObject(object)

end
Script.serveFunction("CSK_MultiSerialCom.processInstance"..multiSerialComInstanceNumberString, handleOnNewProcessing, 'object:?:Alias', 'bool:?') -- Edit this according to this function

--- Function to handle updates of processing parameters from Controller
---@param multiSerialComNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiSerialComNo, parameter, value, internalObjectNo)

  if multiSerialComNo == multiSerialComInstanceNumber then -- set parameter only in selected script
    _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiSerialComInstanceNo." .. tostring(multiSerialComNo) .. " to value = " .. tostring(value))

    --[[
    if internalObjectNo then
      _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiSerialComInstanceNo." .. tostring(multiSerialComNo) .. " of internalObject No." .. tostring(internalObjectNo) .. " to value = " .. tostring(value))
      processingParams.internalObjects[internalObjectNo][parameter] = value

    elseif parameter == 'FullSetup' then
      if type(value) == 'userdata' then
        if Object.getType(value) == 'Container' then
            setAllProcessingParameters(value)
        end
      end

    -- further checks
    --elseif parameter == 'chancelEditors' then
    end

    else
    ]]

    if parameter == 'registeredEvent' then
      _G.logger:info(nameOfModule .. ": Register instance " .. multiSerialComInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    -- elseif parameter == 'someSpecificParameter' then
    --   --Setting something special...
    --   processingParams.specificVariable = value
    --   --Do some more specific...

    else
      processingParams[parameter] = value
      --if  parameter == 'showImage' and value == false then
      --  viewer:clear()
      --  viewer:present()
      --end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiSerialCom.OnNewProcessingParameter", handleOnNewProcessingParameter)
