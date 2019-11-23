# SMPI IOP for React Native.

### Install

Considering a newly created React Native project:

- `npx react-native init TestProj`
- `yarn add sqlite-mpi-client-js`
- `yarn add smpi-iop-react-native`
- `cd ios; pod install`
    - [Autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md) should discover `smpi-iop-react-native`
    - `open TestProj.xcworkspace`
    - Add `$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)`  to `Target -> Build Settings -> Library Search Paths`.
          - Fixes `Could not find auto-linked library 'swiftCoreImage'`.


You may also need to install https://github.com/itinance/react-native-fs in order to get file paths to pass the SMPI JS client.


An example React Native project:
https://github.com/sqlite-mpi/SMPIDemoA



### Introduction 

See https://sqlitempi.com for a general overview.

A React Native app consists of the following "layers":

- A. JS application code.
- B. Host code (iOS/Android)
- C. Guest code (SQLite MPI binary that uses FFI)


The [SMPI JS client](https://github.com/sqlite-mpi/sqlite-mpi-client-js) provides a SQLite API to use in layer A.
- The client is pure JS, and allows you to provide it IOP (Input Output Providers).
- IOPs allow different implementations of sending and receiving data.
- This allows the client to run in any JS environment that can send/receive data.


### This repo

- Is a React Native module.
- Contains the code for layers B and C.
- Is an IOP implementation that is passed to the SMPI JS client constructor.
- Contains SQLite already compiled.
    - Compiled as a shared library that is linked to the host in layer B.
        - iOS uses a Universal Static Library (single binary that contains all architectures).
        - Android chooses the correct JNI binary to use at runtime (arm64-v8a, armeabi-v7a, x86).


 
### License note

The shared library binaries (.so, .a) included in this repo are MIT licensed, but the source code that produced them is closed and proprietary.

A perpetual license for the source code can be arranged for a small fee, please contact emadda.dev@gmail.com.
