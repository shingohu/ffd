package com.sh.ffd;

import android.app.Activity;
import android.os.Bundle;

import com.sh.ffd.lifecycler.ApplifecyclerInject;
import com.sh.ffd.lifecycler.SimpleActivityLifecycleCallbacks;

import io.flutter.app.FlutterApplication;


public class FsdApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();

        ApplifecyclerInject.onCreate(this);
        registerActivityLifecycleCallbacks(new SimpleActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                StatusBarUtil.addTranslycentStatusFlag(activity);
            }

            @Override
            public void onActivityStarted(Activity activity) {
                StatusBarUtil.makeStatusBarTranslucent(activity);
            }
        });
    }
}
