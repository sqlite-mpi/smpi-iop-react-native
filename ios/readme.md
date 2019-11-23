### Note

#### XCode GUI files not used but must exist

`./ios/SMPIEmitter.xcodeproj` and `./ios/SMPIEmitter.xcworkspace` do not have all the iOS files added and are not used via the Xcode GUI.


`use_native_modules!` seems to need those directories to exist to find them when [Autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md) is used.

`use_native_modules!` is a React Native Ruby function that is called in the `Podfile` of the parent app on `pod install`.


The `s.source_files` and `s.ios.vendored_library` keys of `rn-module.podspec` seem to be used to copy files to the parent on `pod install` (not the Xcode GUI project files). 
