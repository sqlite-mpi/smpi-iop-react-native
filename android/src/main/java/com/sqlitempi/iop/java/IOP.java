package com.sqlitempi.iop.java;

import android.util.Log;

public class IOP {
    static {
        // Note: `lib` is prepended, and file extension appended depending on platform.
        System.loadLibrary("smpi_iop_ffi");
    }

    private static native void start(final IOP ins, final String fn_name);

    private static native void stop();

    private static native String input(final String s);


    private static IOP ins;


    private IOP(OutputFn o_fn) {
        this.rt_start(o_fn);
    }

    public static IOP getNewInstance(OutputFn o_fn) {
        if (ins != null) {
            // Stop previous; allow JS refresh in RN during dev.
            // @todo/low Issue In flight output messages are still delivered to the fresh JS instance which no longer has the i_msg_id.
            Log.v("sqlitempi.java", "Stopped previous IOP instance");
            ins.rt_stop();
        }

        Log.v("sqlitempi.java", "Created new IOP instance");
        ins = new IOP(o_fn);
        return ins;
    }


    private OutputFn o_fn;

    public void rt_start(OutputFn o_fn) {
        this.o_fn = o_fn;
        IOP.start(this, "rt_output");
    }

    public void rt_stop() {
        IOP.stop();
        this.o_fn = null;
    }

    public String rt_input(String s) {
        return IOP.input(s);
    }

    public void rt_output(String ret_o) {
        this.o_fn.outputCb(ret_o);
    }

}
