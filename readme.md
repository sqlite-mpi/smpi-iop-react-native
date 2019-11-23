# SMPI IOP for React Native.

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


This repo:

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
