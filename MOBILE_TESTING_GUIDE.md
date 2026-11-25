# Mobile Testing & Distribution Guide

This guide covers installing and testing **Chamber 3D: Cyber Protocol** on your Android device and iPhone.

---

## Part 1: Android Installation & Testing

Android allows direct installation of APK (Android Application Package) artifacts without needing paid developer accounts.

### Method A: Direct Phone Download (Easiest)
1. Go to your GitHub repository on your Android phone's web browser (e.g. Chrome).
2. Tap on the **Actions** tab.
3. Select the latest successful run under **Build Android APK (Godot 4)**.
4. Under the **Artifacts** section at the bottom, tap **Chamber-Android-APK** to download the zip file.
5. Extract `Chamber-Debug.apk` using your phone's File Manager.
6. Tap on `Chamber-Debug.apk` to install:
   - If prompted: *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings** and toggle **Allow from this source**.
7. Launch **Chamber 3D** from your app drawer.

### Method B: ADB (Android Debug Bridge via Mac)
If you prefer installing directly over USB:
```bash
# Connect Android device via USB and verify connection:
adb devices

# Install APK:
adb install -r export/Chamber-Debug.apk
```

---

## Part 2: iPhone Installation & TestFlight

> [!IMPORTANT]
> **Apple Signing Requirement**: Unlike Android, iOS will **never** allow an IPA to install on a physical iPhone unless it is signed with a valid Apple Developer Certificate and matching Provisioning Profile registered for your device's UDID or published through TestFlight.

### Option 1: Official TestFlight Distribution (Production / Beta Testing)
To distribute through Apple TestFlight, you need an active Apple Developer Program membership ($99/year).

#### Step 1: App Store Connect Setup
1. Log into [App Store Connect](https://appstoreconnect.apple.com).
2. Navigate to **Apps** -> **+** -> **New App**.
3. Fill in:
   - **Platforms**: iOS
   - **Name**: Chamber 3D
   - **Bundle ID**: `com.antigravity.chamber` (must match `export_presets.cfg`)
   - **SKU**: `chamber-3d-01`
4. Under the **TestFlight** tab, create an Internal or External Testing Group.

#### Step 2: Configure GitHub Secrets for Automated Signing
In your GitHub repository:
1. Go to **Settings** -> **Secrets and variables** -> **Actions**.
2. Add the following secrets:
   - `APPLE_CERTIFICATE_BASE64`: Base64-encoded `.p12` distribution certificate (`base64 -i distribution.p12`).
   - `APPLE_CERTIFICATE_PASSWORD`: Password for the `.p12` certificate.
   - `APPLE_PROVISIONING_PROFILE_BASE64`: Base64-encoded `.mobileprovision` file.
   - `APP_STORE_CONNECT_API_KEY_ID`: Key ID from App Store Connect.
   - `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID from App Store Connect.
   - `APP_STORE_CONNECT_API_KEY_BASE64`: The AuthKey `.p8` file in base64.

#### Step 3: Install via TestFlight App
1. Install the free **TestFlight** app from the App Store on your iPhone.
2. Accept the invite email sent from App Store Connect or open the public TestFlight link.
3. Tap **Install** and test the game directly on your iPhone with haptic feedback, 60fps Metal rendering, and full multi-touch controls.

---

### Option 2: Development Sideloading (Free Apple ID, No $99 Fee)
If you do not have a paid Apple Developer membership, you can sign and install development IPAs using your personal free Apple ID:

#### Using Sideloadly or AltStore:
1. Download [Sideloadly](https://sideloadly.io/) or [AltStore](https://altstore.io/) on your Mac.
2. Download the `Chamber-iOS-Artifacts` zip from GitHub Actions and extract `Chamber-Unsigned.ipa`.
3. Connect your iPhone to your Mac via USB / Wi-Fi.
4. Drag `Chamber-Unsigned.ipa` into Sideloadly.
5. Enter your standard Apple ID and click **Start**.
6. Once installed on your iPhone:
   - Go to **Settings** -> **General** -> **VPN & Device Management**.
   - Tap your Apple ID and tap **Trust "Apple Development: ..."**.
   - Launch **Chamber 3D**!
