package com.sh.ffd.lifecycler;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import java.util.ArrayList;
import java.util.List;

class ManifestApplifecyclerParse {

    private static final String MODULE_VALUE = "Applifecycler";

    static List<IApplifecycler> parse(Context context) {
        List<IApplifecycler> applifecyers = new ArrayList<>();
        try {
            ApplicationInfo applicationInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);

            if (applicationInfo.metaData != null) {
                for (String key : applicationInfo.metaData.keySet()) {
                    if (MODULE_VALUE .equals( key)) {
                        IApplifecycler applifecyer = parseModule( applicationInfo.metaData.getString(key));
                        if (applifecyer != null) {
                            applifecyers.add(applifecyer);
                        }
                    }
                }
            }

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return applifecyers;
    }

    private static IApplifecycler parseModule(String className) {
        Class clazz;
        try {
            clazz = Class.forName(className);
            Object repository = clazz.newInstance();
            if (repository instanceof IApplifecycler) {
                return (IApplifecycler) repository;
            }
        } catch (Exception e) {

        }

        return null;
    }

}
