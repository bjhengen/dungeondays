# Dungeon Days - Current Issues & Bug Tracker

*Last Updated: August 25, 2024*

## **🔥 Critical Bugs**

### **Issue #1: Android App Bundle Build Failure**
- **Status**: Fixed ✅ (August 25, 2024)
- **Priority**: High
- **Description**: `flutter build appbundle --release` fails with "failed to strip debug symbols from native libraries"
- **Solution**: Created release keystore and configured proper signing in build.gradle.kts
- **Impact**: AAB now builds successfully and uploads to Google Play Store
- **Files Changed**: `android/app/build.gradle.kts`, `android/key.properties`, created `android/app-release-key.jks`

### **Issue #2: Save Game Reliability**
- **Status**: Open
- **Priority**: Medium (lowered - not blocking beta deployment)
- **Description**: No multiple save slots, risk of save corruption
- **Impact**: Players can lose progress
- **Details**: Currently uses shared preferences, needs robust file-based saves
- **Next Steps**: Implement multiple save slots with backup/recovery (post-beta feedback)

### **Issue #22: iOS App Store Code Signing**
- **Status**: Fixed ✅ (August 25, 2024)
- **Priority**: Critical
- **Description**: Multiple iOS deployment issues: missing provisioning profile, invalid signatures, missing entitlements
- **Solution**: Created distribution certificate, App Store provisioning profile, proper entitlements file, signed all frameworks
- **Impact**: iOS app now successfully deployed to TestFlight
- **Files Changed**: Created `ios/Runner/Runner.entitlements`, `ios/Runner/ExportOptions.plist`, configured certificates

## **🐛 Confirmed Bugs**

### **Issue #3: Equipment Slot Visual Inconsistency**
- **Status**: Fixed ✅
- **Priority**: Medium
- **Description**: Bow and arrows were using main weapon slot instead of separate slots
- **Solution**: Added dedicated bow/arrows slots to inventory UI
- **Files Changed**: `lib/screens/inventory_screen.dart`

### **Issue #4: Light Spell Not Affecting Visibility**
- **Status**: Fixed ✅
- **Priority**: Medium
- **Description**: Light spell/scroll didn't increase vision range at night
- **Solution**: Added active effects system to Player model, integrated with visibility calculation
- **Files Changed**: `lib/models/player.dart`, `lib/models/world.dart`, `lib/services/spell_service.dart`

### **Issue #5: Mobile UI Button Positioning**
- **Status**: Fixed ✅
- **Priority**: Medium
- **Description**: Menu buttons overlapping with Android navigation bar
- **Solution**: Added responsive padding using MediaQuery
- **Files Changed**: `lib/widgets/ascii_display.dart`

### **Issue #6: Combat Navigation Issues**
- **Status**: Fixed ✅
- **Priority**: High
- **Description**: Using items/scrolls in combat would exit to main screen
- **Solution**: Fixed navigation flow in ItemSelectionDialog
- **Files Changed**: `lib/widgets/item_selection_dialog.dart`, `lib/screens/combat_screen.dart`

### **Issue #7: Identify Scrolls Not Interactive**
- **Status**: Fixed ✅
- **Priority**: Medium
- **Description**: Identify scrolls automatically identified first item instead of letting player choose
- **Solution**: Added item selection dialog for identify scrolls in combat
- **Files Changed**: `lib/screens/combat_screen.dart`

## **🎮 Gameplay Issues**

### **Issue #8: Combat Difficulty Balancing**
- **Status**: Open
- **Priority**: Medium
- **Description**: Combat may be too easy/hard for different character builds
- **Impact**: Affects game progression and player engagement
- **Next Steps**: Gather playtesting data, adjust monster stats and player progression
- **Related**: Need more diverse monster encounters

### **Issue #9: Magic School Balance**
- **Status**: Open
- **Priority**: Medium
- **Description**: Some spell schools may be significantly stronger than others
- **Impact**: Reduces build diversity and player choice meaning
- **Next Steps**: Analyze spell effectiveness, adjust damage/mana costs
- **Related**: Need more spells in under-represented schools

### **Issue #10: Limited Monster Variety**
- **Status**: Open
- **Priority**: Low
- **Description**: Currently only 5 monster types (hobgoblin, orc, bandit, wolf, spider)
- **Impact**: Combat becomes repetitive quickly
- **Next Steps**: Add 10-15 additional monster types with unique abilities
- **Files to Modify**: `lib/services/world_generator.dart`

## **📱 Mobile-Specific Issues**

### **Issue #11: Portrait Mode Optimization**
- **Status**: Open
- **Priority**: Medium
- **Description**: Game primarily designed for landscape, portrait mode cramped
- **Impact**: Limits usability on phones
- **Next Steps**: Redesign UI layout for portrait orientation
- **Files Affected**: `lib/widgets/ascii_display.dart`, `lib/screens/game_screen.dart`

### **Issue #12: Touch Target Sizes**
- **Status**: Partially Fixed
- **Priority**: Low
- **Description**: Some buttons too small for comfortable touch interaction
- **Progress**: Menu buttons resized, inventory needs work
- **Next Steps**: Audit all touch targets for minimum 44pt size
- **Files to Review**: All screen widgets

### **Issue #13: Gesture Controls Missing**
- **Status**: Open
- **Priority**: Medium
- **Description**: No swipe-to-move or pinch-to-zoom gestures
- **Impact**: Less intuitive than modern mobile games
- **Next Steps**: Implement gesture recognizers for movement and map interaction
- **Files to Modify**: `lib/screens/game_screen.dart`

## **⚙️ Technical Debt**

### **Issue #14: Settings System Missing**
- **Status**: Open
- **Priority**: High
- **Description**: No in-game settings menu for sound, graphics, controls
- **Impact**: Cannot customize game experience
- **Next Steps**: Create settings screen with persistent preferences
- **New Files**: `lib/screens/settings_screen.dart`, `lib/services/settings_service.dart`

### **Issue #15: Error Handling Inconsistent**
- **Status**: Open
- **Priority**: Medium
- **Description**: Inconsistent error handling across the app
- **Impact**: Poor user experience when errors occur
- **Next Steps**: Standardize error handling, add user-friendly error dialogs
- **Files to Review**: All service classes

### **Issue #16: Performance Optimization Needed**
- **Status**: Open
- **Priority**: Medium
- **Description**: Game may stutter on older devices
- **Impact**: Limits target audience
- **Next Steps**: Profile performance, optimize rendering and game state updates
- **Tools**: Flutter DevTools profiler

## **🎨 Polish & UX Issues**

### **Issue #17: Tutorial System Missing**
- **Status**: Open
- **Priority**: High
- **Description**: New players have no guidance on game mechanics
- **Impact**: High abandonment rate for new users
- **Next Steps**: Create interactive tutorial covering movement, combat, magic
- **New Files**: `lib/screens/tutorial_screen.dart`, `lib/services/tutorial_service.dart`

### **Issue #18: Loading States Missing**
- **Status**: Open
- **Priority**: Low
- **Description**: No loading indicators for world generation, save/load operations
- **Impact**: App feels unresponsive during long operations
- **Next Steps**: Add progress indicators and loading screens
- **Files to Modify**: All screens with async operations

### **Issue #19: Sound Effects Missing**
- **Status**: Open
- **Priority**: Low
- **Description**: Game is completely silent
- **Impact**: Less engaging experience
- **Next Steps**: Add audio system with UI sounds, combat effects, ambient audio
- **New Dependencies**: Add audio plugin to pubspec.yaml

## **🔮 Enhancement Ideas**

### **Issue #20: Cloud Save Integration**
- **Status**: Planned
- **Priority**: Low
- **Description**: Optional cloud backup for save games
- **Impact**: Reduces fear of losing progress
- **Considerations**: Privacy-focused, optional, platform integration
- **Timeline**: Post v1.0

### **Issue #21: Character Portraits**
- **Status**: Idea
- **Priority**: Very Low
- **Description**: Visual character representation beyond stats
- **Impact**: Increased immersion and personalization
- **Scope**: Significant art asset creation required

---

## **Issue Triage Guidelines**

### **Priority Levels:**
- **Critical**: Breaks core functionality, prevents app store submission
- **High**: Significantly impacts user experience or progression
- **Medium**: Quality of life improvements, minor functional issues
- **Low**: Polish, nice-to-have features

### **Status Definitions:**
- **Open**: Not yet started
- **In Progress**: Currently being worked on
- **Fixed**: Completed and tested
- **Blocked**: Waiting on external dependencies
- **Won't Fix**: Decided against implementing

---

*This document is maintained manually and should be updated as issues are resolved or discovered.*