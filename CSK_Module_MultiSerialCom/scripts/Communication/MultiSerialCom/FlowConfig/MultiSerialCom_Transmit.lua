-- Block namespace
local BLOCK_NAMESPACE = 'MultiSerialCom_FC.Transmit'
local nameOfModule = 'CSK_MultiSerialCom'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function transmit(handle, source)

  local instance = Container.get(handle, 'Instance')

  -- Check if amount of instances is valid
  -- if not: add multiple additional instances
  while true do
    local amount = CSK_MultiSerialCom.getInstancesAmount()
    if amount < instance then
      CSK_MultiSerialCom.addInstance()
    else
      CSK_MultiSerialCom.setSelectedInstance(instance)
      CSK_MultiSerialCom.setRegisterEvent(source)
      break
    end
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.transmit', transmit)

--*************************************************************
--*************************************************************

local function create(instance)

  -- Check if same instance is already configured
  if instance < 1 or nil ~= instanceTable[instance] then
    _G.logger:warning(nameOfModule .. ': Instance invalid or already in use, please choose another one')
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[instance] = instance
    Container.add(handle, 'Instance', instance)
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)