# mqtt-homekit-bridge
A simple MQTT to HAP (HomeKit Automation Protocol) bridge in Swift

## Building

### Linux

```
sudo apt install openssl libssl-dev libsodium-dev libcurl4-openssl-dev libmosquitto-dev
swift build -c release
```

### macOS

Since libmosquitto does not come with a `pkg-config` file, the library search path for [libmosquitto](https://mosquitto.org/) needs to be added manually.  E.g. to install libmosquitto via [Homebrew](https://brew.sh/) and then build, use

```
brew install libsodium mosquitto
swift build -c release -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib
```

To build using Xcode, use

```
brew install mosquitto
swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig
open Mosquitto.xcodeproj
```

## TODO
- [ ] customisable transformations between MQTT topics and HAP value updates
- [ ] access to non-default HAP Device Characteristics

