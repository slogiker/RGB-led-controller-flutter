# Quick Start: Deploy to Xiaomi Device

## Prerequisites
- Xiaomi device with IR blaster (POCO, Mi, Redmi series)
- USB cable
- Android SDK tools installed
- Flutter installed

## Build Release APK

```powershell
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

## Deploy to Device

### Via USB
```powershell
# Enable USB debugging on Xiaomi:
# Settings → About phone → Developer options → USB Debugging

# Connect device
adb devices

# Install app
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Via Wireless (ADB over Network)
```powershell
# Enable developer options on device
# Enable "Wireless debugging"
# Get device IP from: Settings → About phone → Status

# Connect wirelessly
adb connect <xiaomi-ip>:5555

# Install app
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Monitor App Execution

```powershell
# In PowerShell, open two terminals:

# Terminal 1: Watch logs
adb logcat | findstr RGBLedController

# Terminal 2: Run app
flutter run
```

## Verify IR Blaster

### Check Device Has IR Blaster
```powershell
adb shell getprop ro.hardware | findstr "ir\|consumerir"
```

**Expected output for Xiaomi with IR:**
```
ro.hardware.ir=...
```

### Check Permissions
```powershell
adb shell pm dump com.example.myapp | findstr TRANSMIT_IR
```

## First Launch Testing

1. **Open App** - Should show main remote screen
2. **Go to Settings** - Check if device info shows IR blaster
3. **Return to Remote** - Press OFF button while pointing at LED controller
4. **Watch Logcat** - Should see:
   ```
   I/RGBLedController: 📱 Device IR Blaster Support: ✅ YES
   I/RGBLedController: 📤 IR Transmit Request - Command: OFF
   I/RGBLedController: ✅ IR transmitted successfully
   ```
5. **Check LED Controller** - Should respond (turn off/dim)

## Test All Commands

Run through each button systematically:

| Button | Expected Logcat |
|--------|-----------------|
| OFF | `📤 Transmitting IR: OFF (0xF740BF)` |
| ON | `📤 Transmitting IR: ON (0xF7C03F)` |
| BRIGHT ↑ | `📤 Transmitting IR: BRIGHT_UP (0xF7C03F)` |
| BRIGHT ↓ | `📤 Transmitting IR: BRIGHT_DOWN (0xF7E01F)` |
| RED | `📤 Transmitting IR: RED (0xF720DF)` |
| GREEN | `📤 Transmitting IR: GREEN (0xF7A05F)` |
| BLUE | `📤 Transmitting IR: BLUE (0xF7609F)` |
| (continue for all colors) | (watch for all logcat outputs) |

## Troubleshooting

### App Won't Install
```powershell
# Check USB debugging enabled
adb devices

# If device shows "unauthorized":
# 1. Unplug USB cable
# 2. Go to Settings → Wireless debugging → Unpair all devices
# 3. Reconnect and accept authorization prompt
```

### No IR Blaster Detected
```powershell
# Check if device has IR hardware
adb shell cat /system/build.prop | findstr "ir"

# If no IR found:
# - Device may not have IR blaster
# - Try different Xiaomi model (POCO, Mi 11 series usually have IR)
```

### IR Commands Not Working
1. **Check LED Controller**
   - Point iPhone flashlight at LED receiver to verify it works
   - Try original remote if available

2. **Check IR Protocol**
   - Some LED controllers may use different protocol
   - Verify with LED controller manual

3. **Check Aim**
   - Point Xiaomi directly at LED controller receiver
   - Distance should be within 3 meters

### Logcat Shows "DEBOUNCED"
- Buttons are being pressed too rapidly
- Wait ~100ms between commands
- This is intentional to prevent command flooding

## Performance Testing

### Rapid Command Test
```powershell
# Open app and rapidly tap buttons for 10 seconds
# Monitor logcat for:
# ✅ Commands successfully transmit
# ⏱️  Debounce messages appear
# ❌ No errors or crashes
```

### Memory Test
```powershell
# Send 50+ IR commands
# Monitor logcat for:
# ✅ Consistent success messages
# ❌ No memory-related errors
# ⚠️  Device doesn't overheat
```

## Build for Play Store

### Increment Version
```yaml
# pubspec.yaml
version: 1.0.0+1  # Change to 1.0.1+2, etc.
```

### Build Bundle
```powershell
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Upload to Play Store
1. Create app listing in Google Play Console
2. Add IR blaster requirement to device compatibility
3. Upload build/app/outputs/bundle/release/app-release.aab
4. Set release notes: "RGB LED Controller with IR blaster support"

## Success Checklist

- [ ] APK built successfully in release mode
- [ ] App installs on Xiaomi device without errors
- [ ] Logcat shows "✅ Device IR Blaster Support: YES"
- [ ] OFF button turns off LED controller
- [ ] All 21 IR commands work correctly
- [ ] No crashes or unhandled exceptions
- [ ] App remains responsive while sending commands
- [ ] Debouncing prevents command spam
- [ ] Device doesn't overheat during testing

## Getting Help

### Check Logcat for Errors
```powershell
adb logcat | findstr RGBLedController | findstr "❌\|⚠️"
```

### Common Error Messages

| Error | Solution |
|-------|----------|
| `NO_IR_BLASTER` | Device doesn't have IR. Test on different Xiaomi model |
| `INVALID_ARGUMENTS` | Code issue. Rebuild and reinstall |
| `TRANSMIT_FAILED` | Check LED controller is on and receiver is not blocked |
| `DEBOUNCED` | Wait 100ms before sending next command |

### Contact Developer
- Check GitHub issues: [your-github-repo]
- Review ANDROID_IR_TESTING.md for detailed troubleshooting
- Check IR_IMPLEMENTATION_SUMMARY.md for architecture details

## What's Next

✅ **After successful Xiaomi testing:**
1. Build release APK for distribution
2. Create Play Store listing
3. Upload APK/bundle to Play Store
4. Gather user feedback
5. Optimize based on real-world usage

**Expected Result:** Full-featured RGB LED remote controller working seamlessly on your Xiaomi device! 🚀
