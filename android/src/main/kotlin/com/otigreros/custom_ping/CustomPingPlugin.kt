package com.otigreros.custom_ping

import android.annotation.SuppressLint
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkCapabilities.TRANSPORT_WIFI
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result


/** CustomPingPlugin */
class CustomPingPlugin : FlutterPlugin {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var methodCallHandler: MethodCallHandlerImpl? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "custom_ping")
        val connectivityManager = flutterPluginBinding.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        methodCallHandler = MethodCallHandlerImpl(Connectivity(connectivityManager))
        channel.setMethodCallHandler(methodCallHandler)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(methodCallHandler)
    }
}

class MethodCallHandlerImpl(private val connectivity: Connectivity) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getNetworkType" -> {
                result.success(connectivity.networkType);
            }
            else -> {
                result.notImplemented()
            }
        }

    }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


/** Reports connectivity related information such as connectivity type and wifi information.  */
class Connectivity(private val connectivityManager: ConnectivityManager) {
    val networkType: String
        @SuppressLint("MissingPermission")
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                        ?: return "none"
                if (capabilities.hasTransport(TRANSPORT_WIFI)
                        || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    return "wifi"
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    return "mobile"
                }
            }
            return networkTypeLegacy
        }

    // handle type for Android versions less than Android 9
    private val networkTypeLegacy: String
        @SuppressLint("MissingPermission")
        get() {
            // handle type for Android versions less than Android 9
            val info = connectivityManager.activeNetworkInfo
            if (info == null || !info.isConnected) {
                return "none"
            }
            val type = info.type
            return when (type) {
                ConnectivityManager.TYPE_ETHERNET, ConnectivityManager.TYPE_WIFI, ConnectivityManager.TYPE_WIMAX -> "wifi"
                ConnectivityManager.TYPE_MOBILE, ConnectivityManager.TYPE_MOBILE_DUN, ConnectivityManager.TYPE_MOBILE_HIPRI -> "mobile"
                else -> "none"
            }
        }

}



