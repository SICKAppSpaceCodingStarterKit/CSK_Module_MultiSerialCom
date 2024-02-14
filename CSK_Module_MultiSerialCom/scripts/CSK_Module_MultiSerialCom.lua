--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- CreationTemplateVersion: 3.6.0
--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
 _G.availableAPIs = require('Communication/MultiSerialCom/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiSerialCom_Model
-- Check this script regarding MultiSerialCom_Model parameters and functions
local multiSerialCom_Model = require('Communication/MultiSerialCom/MultiSerialCom_Model')

local multiSerialCom_Instances = {} -- Handle all instances

-- Load script to communicate with the MultiSerialCom_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiSerialComController = require('Communication/MultiSerialCom/MultiSerialCom_Controller')

-- Check if specific APIs are available on device
if availableAPIs.specific then
  table.insert(multiSerialCom_Instances, multiSerialCom_Model.create(1)) -- Create at least 1 instance
  multiSerialComController.setMultiSerialCom_Instances_Handle(multiSerialCom_Instances) -- share handle of instances
else
  _G.logger:warning("CSK_SerialCom : Features of this module are not supported on this device. Missing APIs/interfaces.")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  multiSerialComController.setMultiSerialCom_Model_Handle(multiSerialCom_Model) -- share handle of Model

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.multiSerialCom_Model.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  --
  --[[
  CSK_MultiSerialCom.setSelectedInstance(1)
  CSK_MultiSerialCom.setInterface('SER1')
  CSK_MultiSerialCom.setType('RS232')
  CSK_MultiSerialCom.setBaudrate(9600)
  CSK_MultiSerialCom.setParity('N')
  CSK_MultiSerialCom.setHandshake(false)
  CSK_MultiSerialCom.setDataBits(8)
  CSK_MultiSerialCom.setStopBits(1)
  CSK_MultiSerialCom.setTermination(false)

  CSK_MultiSerialCom.setActive(true)

  CSK_MultiSerialCom.transmitInstance1('Test') -- Send data on instance 1
  CSK_MultiSerialCom.receiveInstance1() -- Receive data on instance 1

  --Register on event 'CSK_MultiSerialCom.OnNewData1' to get incoming data
  ]]

  ----------------------------------------------------------------------------------------

  if availableAPIs.specific then
    CSK_MultiSerialCom.setSelectedInstance(1)
  end
  CSK_MultiSerialCom.pageCalled() -- Update UI

end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************