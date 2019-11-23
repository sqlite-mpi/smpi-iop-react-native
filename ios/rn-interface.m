#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(SMPIEmitter, RCTEventEmitter)

// @see https://medium.com/@andrei.pfeiffer/react-natives-rct-extern-method-c61c17bf17b2
// - `RCT_EXTERN_METHOD` syntax.

RCT_EXTERN_METHOD(input:(NSString)i_msg
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
