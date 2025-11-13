package com.example.myapp

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ir_service"
    private val TAG = "RGBLedController"
    private var irManager: ConsumerIrManager? = null
    private var lastTransmitTime = 0L
    private val MIN_TRANSMIT_INTERVAL = 100L // milliseconds

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize IR manager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as ConsumerIrManager
            val hasIr = irManager?.hasIrEmitter() ?: false
            Log.i(TAG, "📱 Device IR Blaster Support: ${if (hasIr) "✅ YES" else "❌ NO"}")
            Log.i(TAG, "Device: ${Build.MANUFACTURER} ${Build.MODEL}")
            Log.i(TAG, "Android Version: ${Build.VERSION.SDK_INT}")
        } else {
            Log.w(TAG, "⚠️  Android SDK version too old (${Build.VERSION.SDK_INT}), IR may not work")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "transmitIR" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        handleTransmitIR(args as Map<String, String>, result)
                    } else {
                        result.error("INVALID_ARGS", "Arguments must be a map", null)
                    }
                }
                "hasIrBlaster" -> handleHasIrBlaster(result)
                "getIrBlasterInfo" -> handleGetIrBlasterInfo(result)
                else -> result.notImplemented()
            }
        }
    }

    /// Handle IR transmission request
    private fun handleTransmitIR(args: Map<String, String>, result: MethodChannel.Result) {
        val hexCode = args["code"]
        val command = args["command"] ?: "UNKNOWN"

        Log.i(TAG, "📤 IR Transmit Request - Command: $command, Code: $hexCode")

        // Check if device has IR blaster
        if (irManager == null) {
            Log.e(TAG, "❌ IR Manager not available")
            result.error("IR_UNAVAILABLE", "IR Manager not available on this device", null)
            return
        }

        if (!irManager!!.hasIrEmitter()) {
            Log.e(TAG, "❌ Device does not have IR blaster capability")
            result.error("NO_IR_BLASTER", "This device does not have IR blaster capability", null)
            return
        }

        // Validate hex code
        if (hexCode == null || hexCode.isEmpty()) {
            Log.e(TAG, "❌ Invalid IR code: null or empty")
            result.error("INVALID_CODE", "IR code cannot be null or empty", null)
            return
        }

        // Debounce check
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastTransmitTime < MIN_TRANSMIT_INTERVAL) {
            Log.w(TAG, "⏱️  IR command debounced (too frequent): $command")
            result.error("DEBOUNCED", "Commands are too frequent, please wait", null)
            return
        }
        lastTransmitTime = currentTime

        try {
            Log.d(TAG, "🧪 Converting hex code to pattern: $hexCode")
            val frequency = 38000 // Standard carrier frequency for IR remotes
            val pattern = hexToPattern(hexCode)

            Log.d(TAG, "📊 IR Pattern: ${pattern.size} pulses, first 5: ${pattern.take(5)}")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                irManager!!.transmit(frequency, pattern)
                Log.i(TAG, "✅ IR transmitted successfully - Command: $command, Frequency: ${frequency}Hz, Pulses: ${pattern.size}")
                result.success(mapOf("success" to true, "command" to command, "pulses" to pattern.size))
            } else {
                Log.e(TAG, "❌ SDK version too old for IR transmission")
                result.error("SDK_TOO_OLD", "IR transmission requires Android 4.4+", null)
            }
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "❌ Invalid pattern for IR transmission: ${e.message}")
            result.error("INVALID_PATTERN", "Failed to create IR pattern: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error transmitting IR: ${e.message}", e)
            result.error("TRANSMIT_FAILED", "Failed to transmit IR code: ${e.message}", null)
        }
    }

    /// Check if device has IR blaster
    private fun handleHasIrBlaster(result: MethodChannel.Result) {
        try {
            val hasIr = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                irManager?.hasIrEmitter() ?: false
            } else {
                false
            }
            Log.i(TAG, "✅ IR Blaster Check Result: $hasIr")
            result.success(hasIr)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking IR capability: ${e.message}")
            result.error("CHECK_FAILED", "Failed to check IR capability: ${e.message}", null)
        }
    }

    /// Get IR blaster information
    private fun handleGetIrBlasterInfo(result: MethodChannel.Result) {
        try {
            val info = mutableMapOf<String, Any>()
            info["manufacturer"] = Build.MANUFACTURER
            info["model"] = Build.MODEL
            info["device"] = Build.DEVICE
            info["android_version"] = Build.VERSION.SDK_INT
            info["has_ir"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                irManager?.hasIrEmitter() ?: false
            } else {
                false
            }

            // Get max carrier frequency ranges if available
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    val ranges = irManager?.carrierFrequencies
                    info["carrier_frequencies"] = "${ranges?.minFrequency}-${ranges?.maxFrequency}Hz"
                } catch (e: Exception) {
                    Log.w(TAG, "Could not get carrier frequency ranges: ${e.message}")
                }
            }

            Log.i(TAG, "📱 Device Info: $info")
            result.success(info)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting device info: ${e.message}")
            result.error("INFO_FAILED", "Failed to get device info: ${e.message}", null)
        }
    }

    /// Convert hex code to IR pulse pattern (NEC protocol)
    /// NEC is the most common protocol for consumer IR remotes
    /// Format: 9000µs leader ON, 4500µs leader OFF, then 32 data bits
    /// Each bit: 560µs ON, then 560µs (0) or 1690µs (1) OFF
    private fun hexToPattern(hex: String): IntArray {
        val pulses = mutableListOf<Int>()
        
        // Clean up hex string
        var cleanHex = hex.replace("0x", "", ignoreCase = true)
            .replace("0X", "")
            .trim()

        // Pad to 8 characters if needed
        if (cleanHex.length < 8) {
            cleanHex = cleanHex.padStart(8, '0')
        }

        Log.d(TAG, "🔄 Converting hex: $hex -> cleaned: $cleanHex (${cleanHex.length} chars)")

        try {
            val longValue = cleanHex.toLong(16)
            Log.d(TAG, "📊 Hex value: 0x${cleanHex.uppercase()} = $longValue (binary: ${longValue.toString(2).padStart(32, '0')})")

            // NEC protocol timings in microseconds
            val headerOn = 9000
            val headerOff = 4500
            val bitOn = 560
            val zeroOff = 560
            val oneOff = 1690

            // Build NEC frame
            pulses.add(headerOn)
            pulses.add(headerOff)

            // 32-bit data (MSB first)
            for (i in 31 downTo 0) {
                pulses.add(bitOn)
                if ((longValue shr i) and 1L == 1L) {
                    pulses.add(oneOff)
                } else {
                    pulses.add(zeroOff)
                }
            }

            // Final mark (end of transmission)
            pulses.add(bitOn)

            Log.d(TAG, "✅ Pattern created: ${pulses.size} pulses")
            return pulses.toIntArray()

        } catch (e: NumberFormatException) {
            Log.e(TAG, "❌ Invalid hex format: $hex")
            throw IllegalArgumentException("Invalid hex code format: $hex", e)
        }
    }
}