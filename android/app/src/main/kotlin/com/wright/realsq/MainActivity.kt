package com.wright.realsq

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            requestPermissions(arrayOf(android.Manifest.permission.MANAGE_EXTERNAL_STORAGE), 1)
        }
    }
}