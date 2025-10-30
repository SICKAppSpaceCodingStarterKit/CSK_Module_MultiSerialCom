# Changelog
All notable changes to this project will be documented in this file.

## Release 2.0.1

### Improvements
- Better instance handling regarding FlowConfig

### Bugfix
- Wrong ENUM check within checkAPI
- Legacy bindings of ValueDisplay elements within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon of iFrame was visible

## Release 2.0.0

Major change: Handles serial data as binary (was string before)

### New features
- Supports FlowConfig feature to handle received data / transmit data
- Optionally deactivate logging of serial communication to reduce CPU load
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup
- Check if persistent data to load provides all relevant parameters. Otherwise add default values.

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Added UI icon and browser tab information

## Release 1.0.1

### Bugfix
- Registering to external function did not work

## Release 1.0.0
- Initial commit