# TODO List

## Completed Features ✅
- [x] Add one button for ON/OFF
- [x] Add slider for brightness
- [x] Add Vibration hardness (slider instead of toggle)
- [x] Default dark mode, allow changing to light mode

## Need implementation asap
- [ ] Add Icon
- [ ] Add clean version certificates (no virues aka safe for android)

## Fixes after first testing
- [ ] Brightness changes leds to white (does not change acctual brightness)
- [ ] Implement more deafult colors OR remove some of default colors and add color wheel

## Critical: IR Functionality Fixes 🔴

### Priority 1: Debug & Fix IR Issues
- [ ] **Add IR debug button/functionality** - Verify device IR capability on startup
  - Add debug button in AppBar that shows device IR info
  - Check `hasIrBlaster()` on app startup
  - Display warning if device lacks IR capability

- [ ] **Handle IR command results** - Show error messages when commands fail
  - Currently `IrService.transmitIR()` returns `bool` but UI doesn't handle failures
  - Add error feedback in UI when IR transmission fails
  - Show user-friendly error messages

- [ ] **Fix brightness slider debouncing** - Only send IR on release
  - Currently sends IR commands during slider drag
  - Change to send only on release or with 300ms+ debounce
  - Reduces IR command spam

- [ ] **Add IR capability check on startup** - Warn users without IR blaster
  - Check `IrService.hasIrBlaster()` in `initState()`
  - Show SnackBar warning if device doesn't support IR
  - Prevent confusion when IR doesn't work

### Priority 2: IR Testing & Verification
- [ ] **Test IR functionality on physical device** - Verify logcat shows successful transmission
  - Monitor `adb logcat | findstr RGBLedController`
  - Verify all 21 commands transmit successfully
  - Check for any error messages in logcat

- [ ] **Verify IR codes match LED controller** - May need to update hex codes
  - Current codes assume NEC protocol at 38kHz
  - Verify with LED controller documentation
  - Test frequency variations (36kHz, 40kHz) if needed

## Code Optimizations 🔧

- [ ] **Consider state management migration** - From setState to Riverpod/Provider
  - Current: Using `setState` in `RemoteScreen`
  - Better: Use Riverpod or Provider for cleaner state management
  - Will improve code organization and testability

- [ ] **Add retry logic for failed IR commands** - Exponential backoff
  - Retry failed commands automatically
  - Use exponential backoff (100ms, 200ms, 400ms)
  - Maximum 3 retries before showing error

## Future Features 🚀

### Phase 1: Core Improvements
- [ ] Add slider for effects speed (after brightness works)
- [ ] IR code learning - Capture codes from original remote
- [ ] Macro commands - Sequences of IR commands
- [ ] Favorite colors - Save frequently used colors

### Phase 2: Advanced Features
- [ ] Automation - Scheduled color changes
- [ ] Scene presets - Save color/effect combinations
- [ ] Remote backup/restore - Sync IR codes via cloud
- [ ] Multi-device support - Control multiple LED controllers
