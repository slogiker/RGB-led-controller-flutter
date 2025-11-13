# Android IR Blaster Testing Guide

## Overview
This guide covers testing the IR blaster functionality across Android emulators and physical devices.

## Architecture Summary

### Dart Layer (`lib/services/ir_service.dart`)
- **`transmitIR(String command)`** - Main entry point with debouncing and error handling
- **`hasIrBlaster()`** - Check if device has IR capability
- **`getIrBlasterInfo()`** - Get device info (manufacturer, model, Android version, IR support)
- **`testIR(String command)`** - Dedicated test function with logging
- **Debug Functions** - `debugPrintInfo()`, `debugPrintSuccess()`, `debugPrintWarning()`, `debugPrintError()`

### Kotlin Layer (`android/app/src/main/kotlin/com/example/myapp/MainActivity.kt`)
- **`handleTransmitIR()`** - Core IR transmission logic using Android's `ConsumerIrManager`
- **`handleHasIrBlaster()`** - Check IR capability
- **`handleGetIrBlasterInfo()`** - Retrieve device information
- **`hexToPattern()`** - Convert hex codes to NEC protocol pulse patterns
- **Logging** - Comprehensive logcat logging with emojis for easy identification

### IR Protocol Details
- **Protocol**: NEC (most common for consumer IR)
- **Carrier Frequency**: 38,000 Hz (standard for IR remotes)
- **Timings**:
  - Header: 9000µs ON, 4500µs OFF
  - Bit 0: 560µs ON, 560µs OFF
  - Bit 1: 560µs ON, 1690µs OFF
  - Stop bit: 560µs ON
- **Data**: 32 bits per command (MSB first)

## Test Sequence

### Phase 1: Emulator Setup (No actual IR, but validates MethodChannel)

#### Step 1: Create a test emulator
```powershell
# List available emulators
emulator -list-avds

# Create Android 11+ emulator (IR support required for APIs)
# Use Android Studio Device Manager or:
# sdkmanager "system-images;android-33;google_apis;x86_64"
# avdmanager create avd -n "test_ir" -k "system-images;android-33;google_apis;x86_64"
```

#### Step 2: Start emulator
```powershell
emulator -avd test_ir
```

#### Step 3: Build and run app
```powershell
flutter clean
flutter pub get
flutter run -v
```

**Expected Logcat Output:**
```
I/RGBLedController: 📱 Device IR Blaster Support: ❌ NO
I/RGBLedController: Device: Google generic_x86_64
I/RGBLedController: Android Version: 33
```

*Note: Emulator won't have real IR hardware, but MethodChannel communication will work.*

#### Step 4: Test MethodChannel Communication
Open the Flutter Devtools console and test:

```dart
// Test hasIrBlaster
void testHasIrBlaster() async {
  final result = await IrService.hasIrBlaster();
  print('Has IR: $result');
}

// Test getIrBlasterInfo
void testGetIrBlasterInfo() async {
  final info = await IrService.getIrBlasterInfo();
  print('Device Info: $info');
}

// Test transmitIR (will fail on emulator but validates MethodChannel)
void testTransmitIR() async {
  final result = await IrService.transmitIR('RED');
  print('Transmit result: $result');
}
```

**Expected Emulator Behavior:**
- ✅ MethodChannel calls succeed
- ❌ IR transmission shows "NO_IR_BLASTER" error (expected)
- ✅ Device info retrieved successfully

### Phase 2: Physical Device Testing (Xiaomi)

#### Step 1: Prepare Device
```powershell
# Install app on connected Xiaomi device
adb devices
adb connect <xiaomi-ip>:5555  # if using wireless
flutter run
```

#### Step 2: Monitor Logs
```powershell
# In separate terminal, watch logcat
adb logcat | grep RGBLedController
```

**Expected Logcat Output (First Run):**
```
I/RGBLedController: 📱 Device IR Blaster Support: ✅ YES
I/RGBLedController: Device: Xiaomi <MODEL>
I/RGBLedController: Android Version: 33 (or higher)
```

#### Step 3: UI-Based Testing

1. **Open the app on Xiaomi device**
2. **Go to Settings screen**
3. **Check IR Blaster Indicator in UI** - Should show device info if available
4. **Return to Remote screen**

#### Step 4: Test Each IR Command

**Power Control:**
- Tap OFF button → Logcat should show:
  ```
  📤 Transmitting IR: OFF (0xF740BF)
  ✅ IR transmitted successfully: OFF, Frequency: 38000Hz, Pulses: 67
  ```
- Point at LED controller, should turn off
- Tap ON button, verify LED turns on

**Brightness Control:**
- Slide brightness to 50% → Should show:
  ```
  📤 Transmitting IR: BRIGHT_UP (0xF7C03F)
  ✅ IR transmitted successfully: BRIGHT_UP
  ```

**Color Selection:**
- Tap RED button → Should transmit:
  ```
  📤 Transmitting IR: RED (0xF720DF)
  ✅ IR transmitted successfully: RED
  ```
- Tap each color: GREEN, BLUE, WHITE, ORANGE, TURQUOISE, PURPLE, YELLOW_ORANGE, LIGHT_TURQUOISE, LIGHT_PURPLE, YELLOW, CYAN, PINK

**Effect Control:**
- Test each effect button:
  - FLASH: `📤 Transmitting IR: FLASH (0xF7D02F)`
  - STROBE: `📤 Transmitting IR: STROBE (0xF7F00F)`
  - FADE: `📤 Transmitting IR: FADE (0xF7C837)`
  - SMOOTH: `📤 Transmitting IR: SMOOTH (0xF7E817)`

**Expected Physical Response:**
- LED controller responds to each command
- No lag between button press and LED response
- All 21 commands work as expected

### Phase 3: Debounce and Error Handling Testing

#### Test 1: Rapid Command Spam
- Rapidly tap buttons in succession
- Monitor logcat for debounce messages:
  ```
  ⏱️  IR command debounced (too frequent): RED
  ```
- Verify app doesn't crash
- Verify LED controller only receives commands with minimum 100ms gap

#### Test 2: Invalid Command
- This would require code modification to test
- Current code validates all commands from the UI
- Error handling demonstrates graceful failure

#### Test 3: Device Without IR (if available)
- Test on non-IR Android device
- Verify app shows user-friendly error message
- Ensure app doesn't crash

### Phase 4: Performance Testing

#### Measure IR Response Time
- Use developer tools to measure frame rate during IR commands
- Expected: 60 FPS maintained (no lag)
- IR indicator light should flash for 500ms then reset

#### Memory Testing
- Monitor RAM usage while sending many IR commands
- Should not leak memory or accumulate garbage
- Verify GC pressure remains low

#### Thermal Testing
- Send 100+ commands in rapid succession
- Monitor CPU temperature
- Device should not overheat (acceptable temp < 45°C)

## Debugging Guide

### Enable Verbose Logging
All code includes comprehensive debug output. View in logcat:
```powershell
adb logcat | findstr RGBLedController
```

### Logcat Symbols Reference
```
ℹ️  = Info message (general information)
✅ = Success (operation completed)
⚠️  = Warning (potential issue, operation may still work)
❌ = Error (operation failed)
📱 = Device info
📤 = Data transmission
📊 = Data processing
🧪 = Testing operation
⏱️  = Timing-related message
```

### Common Issues and Solutions

#### Issue: "NO_IR_BLASTER" Error
**Cause**: Device doesn't have IR hardware
**Solution**: Test on IR-equipped device (Xiaomi, Samsung, etc.)

#### Issue: "DEBOUNCED" Error
**Cause**: Commands being sent too frequently
**Solution**: Add delay between commands or disable debounce for testing (edit `MainActivity.kt` MIN_TRANSMIT_INTERVAL)

#### Issue: "Invalid hex format" Error
**Cause**: Malformed hex code in irCodes map
**Solution**: Verify hex codes in `lib/services/ir_service.dart` match LED controller protocol

#### Issue: IR commands received but no LED response
**Cause 1**: Wrong protocol/frequency
**Solution**: Verify LED controller uses NEC protocol at 38kHz
**Cause 2**: Weak signal
**Solution**: Aim device directly at LED controller receiver

#### Issue: App crashes on IR transmission
**Cause**: Native exception in Kotlin code
**Solution**: Check logcat for exception details, ensure Android SDK >= 19

### Network Testing (if using remote Xiaomi via ADB)
```powershell
# Wireless ADB connection
adb tcpip 5555
adb connect <xiaomi-ip>:5555

# Monitor wireless connection
adb devices
```

## Build and Deployment

### Build APK for Xiaomi
```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install on Device
```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Build Bundle for Play Store
```powershell
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Success Criteria

✅ All tests pass if:
1. Emulator test shows proper MethodChannel communication
2. Xiaomi device recognizes IR blaster (logcat shows "✅ YES")
3. All 21 IR commands successfully transmit
4. LED controller responds to all commands
5. No UI lag during command transmission
6. Debounce prevents command spam (100ms minimum)
7. No crashes or unhandled exceptions
8. Memory usage remains stable
9. All error scenarios handled gracefully

## Next Steps

1. **Emulator Testing** - Validate MethodChannel communication
2. **Xiaomi Physical Testing** - Confirm all IR commands work
3. **Optimization** - Fine-tune delays and frequencies if needed
4. **Deployment** - Build release APK for production
5. **Documentation** - Update app store listing with IR requirements

## References

- [Android ConsumerIrManager Documentation](https://developer.android.com/reference/android/hardware/ConsumerIrManager)
- [NEC IR Protocol Specification](https://techdocs.altium.com/display/FPGA/NEC+Infrared+Transmission+Protocol)
- [Xiaomi IR Blaster Devices](https://www.mi.com/en) - Check device specifications for IR support
- [Flutter MethodChannel Documentation](https://flutter.dev/docs/development/platform-integration/platform-channels)

## Support

If you encounter issues:
1. Check logcat for detailed error messages
2. Verify device has IR blaster capability (`adb shell getprop ro.hardware | grep -i ir`)
3. Ensure IR codes match your LED controller's protocol
4. Test on multiple devices to isolate device-specific issues
5. Review the Android console output during build for warnings
