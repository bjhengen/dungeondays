# Dungeon Days - Build Instructions for App Stores

## Prerequisites

1. **Flutter SDK** - Latest stable version
2. **Android Studio** - For Android builds and signing
3. **Xcode** - For iOS builds (Mac only)
4. **Developer Accounts**:
   - Google Play Console account
   - Apple Developer Program membership

## Android Release Build

### 1. Create Signing Key (First time only)
```bash
# Generate upload keystore
keytool -genkey -v -keystore ~/dungeondays-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Create key.properties file
echo "storePassword=[YOUR_STORE_PASSWORD]" > android/key.properties
echo "keyPassword=[YOUR_KEY_PASSWORD]" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=/path/to/dungeondays-upload-key.jks" >> android/key.properties
```

### 2. Update build.gradle.kts for signing
Add to `android/app/build.gradle.kts`:
```kotlin
android {
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### 3. Build Android App Bundle (AAB)
```bash
# For Google Play Store (recommended)
flutter build appbundle --release

# For direct APK distribution
flutter build apk --release --split-per-abi
```

**Output locations:**
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## iOS Release Build

### 1. Configure Xcode Project
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set Bundle Identifier to: `com.dungeondays.game`
3. Set Team to your Apple Developer Team
4. Configure App Store Connect app record

### 2. Build iOS Archive
```bash
# Build for iOS App Store
flutter build ios --release

# Or build directly in Xcode:
# Product → Archive
```

### 3. Upload to App Store Connect
- Use Xcode Organizer to upload the archive
- Or use Application Loader / Transporter

## Pre-Release Checklist

### Testing
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Test all major features work
- [ ] Test app launches and doesn't crash
- [ ] Test save/load functionality
- [ ] Test different screen sizes

### Metadata
- [ ] Update version number in `pubspec.yaml`
- [ ] Create app icons (see requirements below)
- [ ] Create screenshots for both platforms
- [ ] Prepare store descriptions
- [ ] Have privacy policy URL ready

### Legal
- [ ] Customize privacy policy with your contact info
- [ ] Customize terms of service
- [ ] Ensure you have rights to all assets

## App Icon Requirements

### Android
- **Launcher icon**: 512x512 PNG (for Play Store)
- **App icons**: Multiple sizes in `android/app/src/main/res/mipmap-*` folders

### iOS
- **App Store icon**: 1024x1024 PNG
- **App icons**: Multiple sizes in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Screenshots Required

### Google Play Store
- **Phone**: At least 2 screenshots (minimum 320px, maximum 3840px)
- **Tablet**: At least 1 screenshot (recommended)

### Apple App Store
- **iPhone**: Screenshots for different screen sizes
- **iPad**: Screenshots (if supporting iPad)

## Store Listings

Use content from `/store/app_store_description.md` for:
- App title: "Dungeon Days"
- Short description: "An immersive ASCII roguelike adventure"
- Full description: Use provided marketing copy
- Keywords: roguelike, RPG, magic, dungeon, adventure

## Final Steps

1. **Google Play Store**:
   - Upload AAB file
   - Fill out store listing
   - Set content rating
   - Submit for review

2. **Apple App Store**:
   - Upload build via Xcode/Transporter
   - Complete App Store Connect listing
   - Submit for review

## Notes

- First app store submission can take 24-72 hours for review
- Keep signing keys secure and backed up
- Test thoroughly before submitting
- App store policies change frequently - review current guidelines