# Services-iOS

List of services:
- AppReachability - layer between reachability service and app. For now only able to do action if reachable
- CallService - getting info about system calls based on `CallKit`
- KeychainService - `KeychainAccess` wrapper
- NowPlayingInfoCenterService - `MPNowPlayingInfoCenter` wrapper
- PhoneFormatService - phone numbers formating based on `PhoneNumberKit`
- Player - `AVPlayer` wrapper
- ReachabilityService - network reachability info
- RemoteCommandCenterService - player `MPRemoteCommandCenter` buttons handling layer
- UndoService - `UndoManager` wrapper
- ServiceFactory - factory for declaring dependencies for injecting them via DI in future

Dependencies:
- Base
- Ion
- KeychainAccess
- PhoneNumberKit

## Ion usage

### CallService

```swift
    /// The source for call with changed state.
    var callEventSource: AnyEventSource<CXCall> { get }
```

### Player

```swift
    /// Player status change event source
    var playerStatusSource: AnyEventSource<PlayerStatus> { get }
    /// Playing time update source
    var timeEventSource: AnyEventSource<CFTimeInterval> { get }
    /// Player finished playing event source
    var playbackFinishedEventSource: AnyEventSource<Player> { get }
    /// Player interrupted playing event source
    var playbackInterruptionEventSource: AnyEventSource<Player> { get }
```

### ReachabilityService

```swift
    /// The source for reachability statuses. Sends statuses every time the connection status changes.
    var reachabilityStatusEventSource: AnyEventSource<Bool> { get }
```


## Installation

### Depo

[Depo](https://github.com/rosberry/depo) is a universal dependency manager that combines CocoaPods, Carthage and SPM.

You can use Depo to install Layout by adding it to your `Depofile`:
```yaml
carts:
  - kind: github
    identifier: rosberry/services-ios
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Layout into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "rosberry/services-ios"
```

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Core-iOS is available under the MIT license. See the LICENSE file for more info.
