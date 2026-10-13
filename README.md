# 🎬 Status Video Optimizer

A Flutter-based Android application designed to compress, trim, and enhance videos specifically for WhatsApp Status to maintain crisp **HD quality without blur**.

---

## 📖 Complete Guide:

Follow the steps below to clone this project and run it directly on your Android device.

---

### Step 1: Computer / Laptop Setup

Make sure your machine has the following installed:
1. **Git** ([Download Git](https://git-scm.com/))
2. **Flutter SDK** ([Flutter Installation Guide](https://docs.flutter.dev/get-started/install))
3. **Android Studio & Android SDK / NDK** (Ensure `flutter doctor` runs in your terminal without any issues).

---

### Step 2: Clone the Project from GitHub

1. Open your Terminal / PowerShell / Command Prompt.
2. Run this command to clone the project:
   ```bash
   git clone [https://github.com/farisrasyids/status-video-optimizer.git](https://github.com/farisrasyids/status-video-optimizer.git)

```

3. Navigate to the project directory:
```bash
cd status-video-optimizer

```


4. Fetch all required dependencies:
```bash
flutter pub get

```



---

### Step 3: Prepare Your Android Device

1. Open **Settings** on your Android phone.
2. Go to **About Phone**, then tap **Build Number** (or **OS/MIUI Version**) **7 times** until you see the message *"You are now a developer!"*.
3. Go to **Developer Options**.
4. Enable **USB Debugging** and **Install via USB** (if available).
5. Connect your phone to your computer using a USB data cable.
6. When the authorization prompt appears on your phone screen (*Allow USB debugging?*), check **Always allow** and tap **OK**.

---

### Step 4: Build & Run the App on Your Phone

Choose one of the following methods:

#### Option A: Run Directly (Debug Mode)

1. Verify that your device is connected:
```bash
flutter devices

```


2. Run the application on your phone:
```bash
flutter run

```


3. Wait for the build to finish; the app will launch automatically on your phone.

---

#### Option B: Build Lightweight Release APK (~58 MB) & Install Manually

If you want a standalone `.apk` file to keep or share:

1. Build the Release APK:
```bash
flutter build apk --release --target-platform android-arm64 --split-per-abi

```


2. Once completed, your APK file will be located at:
```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

```


3. **How to Install on Phone:**
* Transfer `app-arm64-v8a-release.apk` to your phone storage (via USB / file share), locate it using your phone's File Manager, and tap **Install**.
* Or install it directly via terminal:
```bash
flutter install

```





---

## 📲 How to Use the App to Prevent Blurry WhatsApp Status

1. Open **Status Video Optimizer** on your phone.
2. Tap **Pilih Video** (Select Video).
3. Adjust the trim range using the slider if needed.
4. Tap **Mulai Optimalkan** (Optimize) and wait for the process to complete.
5. Tap **Bagikan ke WhatsApp** (Share to WhatsApp) -> Send it to **Message yourself** (your own number / saved contact).
6. Open that WhatsApp chat, tap the **Forward button (arrow pointing sideways)** on the newly sent video, and forward it to **My Status**.

> 💡 **Why forward from Chat to Status?**
> Forwarding a video directly from a chat forces WhatsApp to stream the internal cached media without triggering aggressive server-side compression, keeping your status in crisp 1080p resolution!

---

## 📄 License

Faris2026

Seeu Next Upate :)
