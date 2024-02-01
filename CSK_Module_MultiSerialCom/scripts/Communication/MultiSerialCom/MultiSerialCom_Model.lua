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

  -- Optionally check if specific API was loaded via
  --[[
  if _G.availableAPIs.specific then
  -- ... doSomething ...
  end
  ]]

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

  --self.object = Image.create() -- Use any AppEngine CROWN
  --self.counter = 1 -- Short docu of variable
  --self.varA = 'value' -- Short docu of variable

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiSerialCom_Processing' -- which file to use for processing (will be started in own thread)
  --self.parameters.showImage = true -- Short docu of variable
  --self.parameters.paramA = 'paramA' -- Short docu of variable
  --self.parameters.paramB = 123 -- Short docu of variable

  self.parameters.internalObject = {} -- optionally
  --self.parameters.selectedObject = 1 -- Which object is currently selected
  --[[
    for i = 1, 10 do
    local obj = {}

    obj.objectName = 'Object' .. tostring(i) -- name of the object
    obj.active = false  -- is this object active
    -- ...

    table.insert(self.parameters.internalObject, obj)
  end

  local internalObjectContainer = self.helperFuncs.convertTable2Container(self.parameters.internalObject)
  ]]

  -- Parameters to give to the processing script
  self.multiSerialComProcessingParams = Container.create()
  self.multiSerialComProcessingParams:add('multiSerialComInstanceNumber', multiSerialComInstanceNo, "INT")
  self.multiSerialComProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")
  --self.multiSerialComProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  --self.multiSerialComProcessingParams:add('viewerId', 'multiSerialComViewer' .. self.multiSerialComInstanceNoString, "STRING")

  --self.multiSerialComProcessingParams:add('internalObjects', internalObjectContainer, "OBJECT") -- optionally
  --self.multiSerialComProcessingParams:add('selectedObject', self.parameters.selectedObject, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiSerialComProcessingParams)

  return self
end

--[[
--- Some internal code docu for local used function to do something
function multiSerialCom:doSomething()
  self.object:doSomething()
end

--- Some internal code docu for local used function to do something else
function multiSerialCom:doSomethingElse()
  self:doSomething() --> access internal function
end
]]

return multiSerialCom

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************