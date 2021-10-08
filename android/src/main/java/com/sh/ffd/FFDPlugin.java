package com.sh.ffd;

import android.app.Activity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class FFDPlugin implements MethodChannel.MethodCallHandler, FlutterPlugin, ActivityAware {


    private Activity hostActivity;
    private MethodChannel channel;




    private void setupChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "com.sh.ffd");
        channel.setMethodCallHandler(this);
    }

    private void setHostActivity(Activity activity) {
        hostActivity = activity;
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if ("moveToTask".equals(methodCall.method)) {
            if (hostActivity != null && !hostActivity.isFinishing()) {
                hostActivity.moveTaskToBack(true);
            }
            result.success(true);
        }
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        setupChannel(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        teardownChannel();
    }

    private void teardownChannel() {
        channel.setMethodCallHandler(null);
        channel = null;
        hostActivity = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        setHostActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        hostActivity = null;
    }
}
