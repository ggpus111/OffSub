package com.example.offsub

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.offsub.app/system"
    private val smsPermissionRequestCode = 1001
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasSmsPermission" -> {
                    result.success(hasSmsPermission())
                }
                "openUsageAccessSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "requestSmsPermission" -> {
                    if (hasSmsPermission()) {
                        result.success(true)
                    } else {
                        pendingPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.READ_SMS),
                            smsPermissionRequestCode
                        )
                    }
                }

                "getSmsMessages" -> {
                    if (!hasSmsPermission()) {
                        result.success(emptyList<Map<String, Any?>>())
                        return@setMethodCallHandler
                    }

                    val limit = call.argument<Int>("limit") ?: 500
                    result.success(readSmsMessages(limit))
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun readSmsMessages(limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val uri = Uri.parse("content://sms/inbox")

        val projection = arrayOf(
            "_id",
            "address",
            "body",
            "date"
        )

        val cursor: Cursor? = contentResolver.query(
            uri,
            projection,
            null,
            null,
            "date DESC"
        )

        cursor?.use {
            val idIndex = it.getColumnIndex("_id")
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")

            var count = 0

            while (it.moveToNext() && count < limit) {
                messages.add(
                    mapOf(
                        "id" to it.getString(idIndex),
                        "address" to it.getString(addressIndex),
                        "body" to it.getString(bodyIndex),
                        "date" to it.getLong(dateIndex)
                    )
                )
                count++
            }
        }

        return messages
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == smsPermissionRequestCode) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED

            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}