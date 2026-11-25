# Chamber 3D: Cyber Protocol

A complete 3D mobile arena combat game engineered in **Godot 4** with **GDScript**, tailored for **zero local storage footprint** on Mac mini and automated cloud CI/CD on **GitHub Actions**.

---

## 🎮 Game Architecture & Features

- **3D Mobile Action Arena**: Real-time combat with player kinematics, laser projectiles, and wave-based AI drone spawners.
- **Multi-Touch Mobile Controls**:
  - **Dynamic Virtual Joystick**: Responsive analog movement supporting multi-touch fingers and screen clamps.
  - **Touch Look Zone**: Multi-touch orbital camera aiming and swipe gesture controls on the right half of the display.
  - **Dedicated Mobile Action Buttons**: Instant touch triggers for Fire, Dash/Dodge, and Pause.
- **Mobile-Optimized Rendering**:
  - Configured for Godot 4 `mobile` renderer (Vulkan Mobile / Metal).
  - Procedural low-poly meshes and PBR materials with bloom/glow emission.
  - Zero heavy textures or multi-gigabyte external packages.
- **Procedural Audio Synthesizer**:
  - `AudioStreamGenerator` procedural sound effects for lasers, explosions, and dash without consuming local disk space.

---

## 💾 Zero-Storage Footprint Strategy

The local project files use **under 150 KB** of internal storage!
Heavy dependencies like Godot export templates (1.1 GB+) and Android SDK / Xcode tools are offloaded completely to GitHub Actions cloud runners (`ubuntu-latest` for Android and `macos-14` for iOS).

---

## 🚀 Setting Up Your GitHub Repository

To connect this local project to your GitHub account:

```bash
cd "/Users/spine/StudioProjects/Test project/Chamber"

# 1. Initialize git
git init
git branch -M main

# 2. Stage and commit files
git add .
git commit -m "feat: complete 3D Godot 4 mobile game with cloud CI/CD"

# 3. Create remote repository using GitHub CLI (or manually on github.com)
gh repo create Chamber --public --source=. --remote=origin --push
```

---

## ☁️ Cloud CI/CD Pipelines

Automated workflows are located in `.github/workflows/`:

1. **`android-build.yml`**:
   - Downloads headless Godot 4 and export templates in an Ubuntu runner.
   - Compiles debug keystore and exports `Chamber-Debug.apk`.
   - Generates a downloadable APK artifact on every push or workflow trigger.

2. **`ios-build.yml`**:
   - Runs on GitHub Actions `macos-14` runner.
   - Exports the Godot iOS Xcode project and builds an iOS application bundle.
   - Produces `Chamber-iOS-Artifacts` ready for TestFlight or development sideloading.

---

## 📱 Testing On Devices

For comprehensive instructions on sideloading to Android and configuring TestFlight / AltStore for iPhone, see [MOBILE_TESTING_GUIDE.md](file:///Users/spine/StudioProjects/Test%20project/Chamber/MOBILE_TESTING_GUIDE.md).
