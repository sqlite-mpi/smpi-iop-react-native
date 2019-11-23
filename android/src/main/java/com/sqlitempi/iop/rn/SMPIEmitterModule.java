package com.sqlitempi.iop.rn;

// @see https://facebook.github.io/react-native/docs/native-modules-android.html

import android.icu.util.Output;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;


import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;


import com.sqlitempi.iop.java.*;

import android.util.Log;

public class SMPIEmitterModule extends ReactContextBaseJavaModule implements OutputFn {
    private static ReactApplicationContext reactContext;
    private static IOP iop;


    SMPIEmitterModule(ReactApplicationContext context) {
        super(context);
        reactContext = context;
        iop = IOP.getNewInstance(this);
    }

    @Override
    public String getName() {
        return "SMPIEmitter";
    }

    @ReactMethod
    public void input(
            String iMsg,
            Promise promise) {

        promise.resolve(this.iop.rt_input(iMsg));
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           WritableMap params) {

        if (reactContext.hasActiveCatalystInstance()) {
            // When refreshing JS during RN development, prevent throwing error.
            reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        } else {
            Log.v("sqlitempi.java", "`reactContext` not active, not sending event.");
        }

    }

    public void outputCb(String oMsg) {
        WritableMap params = Arguments.createMap();
        params.putString("data", oMsg);
        sendEvent(this.reactContext, "onOutput", params);
    }
}
