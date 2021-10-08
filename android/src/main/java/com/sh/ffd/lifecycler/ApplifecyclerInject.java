package com.sh.ffd.lifecycler;

import android.app.Application;

import com.sh.ffd.lifecycler.IApplifecycler;

import java.util.List;

public class ApplifecyclerInject {
    
    public static void onCreate(Application application) {
        List<IApplifecycler> applifecyclers = ManifestApplifecyclerParse.parse(application);
        for (IApplifecycler iApplifecycler : applifecyclers) {
            iApplifecycler.onCreate(application);
        }
    }

}
