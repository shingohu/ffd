package com.sh.ffd;

import android.app.Activity;
import android.os.Bundle;

public abstract class FsdLaunchActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            finish();
            return;
        }
        startMainActivity();
    }


    //跳转到主界面中
    public abstract void startMainActivity();


    @Override
    public void onBackPressed() {

    }

    @Override
    public void overridePendingTransition(int enterAnim, int exitAnim) {
        super.overridePendingTransition(0, 0);
    }
}
