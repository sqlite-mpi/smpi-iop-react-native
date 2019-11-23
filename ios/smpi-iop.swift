import Foundation
import os.log

// @todo/low Add "os_signposts"/DTrace provider.
@available(iOS 10.0, *)
let customLog = OSLog(subsystem: "SMPI", category: "general")

func lg(_ s: String) {
    if #available(iOS 10.0, *) {
        os_log("%s", log: customLog, type: .debug, s)
    } else {
        NSLog(s)
    }
}

func lg_err(_ s: String) {
    if #available(iOS 10.0, *) {
        os_log("%s", log: customLog, type: .error, s)
    } else {
        NSLog(s)
    }
}

/*
 RN integration notes:
 @see https://teabreak.e-spres-oh.com/swift-in-react-native-the-ultimate-guide-part-1-modules-9bb8d054db03
 - RN interface documentation.

 - Sync functions are possible but are not recommended.
    - Cannot be serialized over JSON.
    - Use Promises/callbacks instead.

 @see https://gist.github.com/brennanMKE/1ebba84a0fd7c2e8b481e4f8a5349b99
 - A single global event emitter by using a singleton and overwriting the emitter with the last initialized.
 - Issue: with this approach, the code only uses the last initialized instance, but RN creates at least two.
 */

// @see https://developer.apple.com/documentation/swift/string/1641523-init
func copyString(_ ptr: UnsafePointer<CChar>?) -> String {
    let s = String(cString: ptr!)
    smpi_free_string(UnsafeMutablePointer(mutating: ptr))
    return s
}

/*
 Passing a C function pointer to a FFI function.
 - Swift closures are converted by the compiler to C function pointers.
 - Compiler will throw an error for for any closed over variables that are not global.

    - @see https://developer.apple.com/documentation/swift/swift_standard_library/manual_memory_management/calling_functions_with_pointer_parameters
    - @see https://stackoverflow.com/questions/33551191/swift-pass-data-to-a-closure-that-captures-context
    - @see https://stackoverflow.com/questions/33294620/how-to-cast-self-to-unsafemutablepointervoid-type-in-swift

    - @see https://stackoverflow.com/a/33262376/4949386
        - The C FFI takes `c_ffi_func(ptrA, funcPtr(ptrA, ...args))`, so the C guest code stores `ptrA` in a global.
        - Alternative: Store `ptrA` as a global in Swift, reference from the closure.
 */

func objToPtr<T: AnyObject>(_ obj: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func ptrToObj<T: AnyObject>(_ ptr: UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

var emitterIns: UnsafeRawPointer?

/*
 IOP = SMPI IO Provider
 - Convert FFI to a general Swift interface.
 - Should be re-usable outside of RN code.
 - @todo/low Move to own package.
 */
class IOP {
    static var global: IOP?

    static func reset_global() {
        global = Optional.none
        // Asssumption: `deinit` block completes.

        global = Optional.some(IOP())
    }

    deinit {
        lg("smpi_stop() called")
        smpi_stop()
    }


    private init() {
        lg("start() called")
        start()
    }

    private func start() {
        smpi_start { strPtr in
            let s = copyString(strPtr)

            if let emitterIns = emitterIns {
                // Closure state.
                let ei: SMPIEmitter = ptrToObj(emitterIns)

                // @todo/low Prevent dependency on RN Emitter interface. Allow passing a closure?
                ei.sendEvent(withName: "onOutput", body: ["data": s])
            } else {
                lg_err("Could not process output msg, RN `emitterIns` has not been set.")
                return
            }
        }
    }

    // This is like an `async` block in GCD.
    // - `input_json` will return very quickly with a pending/settled promise.
    func input(_ i_msg: String) -> String {
        let ptr = smpi_input(i_msg)
        return copyString(ptr)
    }
}

var eCount: Int = 0

@objc(SMPIEmitter)
class SMPIEmitter: RCTEventEmitter {
    override func constantsToExport() -> [AnyHashable: Any]! {
        return [:]
    }

    override init() {
        super.init()
        eCount += 1

        if eCount > 1 {
            lg_err("SMPIEmitter instantiated more than once (\(eCount) times) in a single process")
        }

        // Note: will overwrite with that latest instance.
        // Question: Why does RN instantiate many emitters of the same type?
        emitterIns = objToPtr(self)

        // During development on the simulator, Cmd-R refresh should clear any active write transactions.
        IOP.reset_global()
    }

     /*
     Note: Its possible the output event for this input request will reach the JS thread *before* the return value of this function.
     */
    @objc
    func input(_ i_msg: String, resolver resolve: RCTPromiseResolveBlock,
               rejecter _: RCTPromiseRejectBlock) {
        let ret_i = IOP.global!.input(i_msg)
        resolve(ret_i)
    }

    override func supportedEvents() -> [String]! {
        return ["onOutput"]
    }

    // @todo/medium define GCD queue.
    // Prevent "requires main queue" RN warning.
    // @see https://stackoverflow.com/questions/50773748/difference-requiresmainqueuesetup-and-dispatch-get-main-queue
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
