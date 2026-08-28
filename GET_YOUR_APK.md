# Get your TaskFlow.apk — no computer setup required

I can't compile the APK myself (explained at the bottom), but I've set this
project up so a free cloud service builds it for you automatically. You
never install Flutter, Android Studio, or use a terminal. About 10 minutes,
all in a web browser.

## Steps (do these once)

1. **Create a free GitHub account** at github.com if you don't have one.

2. **Create a new repository**
   - Click the **+** in the top-right → **New repository**
   - Name it `taskflow` → click **Create repository**
   - Leave everything else default (don't add a README)

3. **Upload the project files**
   - On the new (empty) repo page, click **"uploading an existing file"**
   - Unzip `taskflow_source.zip` on your computer first
   - Drag the **contents** of the unzipped `taskflow` folder (the `lib`
     folder, `.github` folder, `pubspec.yaml`, etc. — not the outer
     `taskflow` folder itself) into the browser upload box
   - Scroll down, click the green **Commit changes** button

4. **Let it build automatically**
   - Click the **Actions** tab at the top of your repo
   - You'll see a run called "Build TaskFlow APK" already in progress
     (uploading the files triggers it automatically)
   - Wait 3–6 minutes for the green checkmark ✅

5. **Download the APK**
   - Click into that finished workflow run
   - Scroll to the **Artifacts** section at the bottom
   - Click **TaskFlow-release-apk** — this downloads a small `.zip`
   - Unzip it → you'll find `app-release.apk` inside

6. **Install it on your phone**
   - Get the APK onto your phone (email it to yourself, upload to Google
     Drive/WhatsApp and open on the phone, or a USB cable)
   - Tap the file on your phone
   - Android will ask to allow installing from this source the first
     time — tap **Settings → Allow**, then go back and tap install
   - Open **TaskFlow** like any other app

You won't need to repeat steps 1–4 again — if you ever want an updated
version, you'd just upload the new files and the Actions tab builds a
fresh APK the same way.

## Why I can't hand you a finished .apk directly

I'm running in a sandboxed environment with no Android SDK and no network
access to the servers Flutter needs to download its own build tools from
(I tested this directly — it's blocked at the network level, not a missing
setting I can toggle). There's no local workaround from my side. The GitHub
Actions route above uses GitHub's own servers (which do have full internet
access) to do the actual compiling, which is why it works even though my
environment can't do it directly.
