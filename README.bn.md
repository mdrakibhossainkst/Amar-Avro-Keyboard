# Amar Avro Keyboard — macOS

macOS-এর জন্য কাস্টমাইজ করা বাংলা ইনপুট মেথড। এতে Avro Phonetic, Probhat ও Unijoy লেআউট এবং Unicode অথবা ANSI (Bijoy-font) আউটপুট রয়েছে।

- **কাস্টম ব্র্যান্ডিং ও রক্ষণাবেক্ষণ:** Md Rakib Hossain
- **ভার্সন:** 1.0.0
- **ন্যূনতম macOS:** macOS 12 Monterey (মূল প্রজেক্টের উত্তরাধিকারসূত্রে)

## গুরুত্বপূর্ণ লাইসেন্স ও কৃতিত্ব
Amar Avro Keyboard হলো ওপেন-সোর্স iAvro / Avro Keyboard প্রজেক্টের একটি কাস্টমাইজড fork। মূল কিবোর্ড ইঞ্জিন ও upstream অবদানগুলোকে এই fork-এর নতুন কাজ হিসেবে দাবি করা হচ্ছে না। প্রয়োজনীয় copyright notice এবং `LICENSE` ফাইল রাখা হয়েছে। কোডের জন্য Mozilla Public License 1.1 (MPL 1.1) প্রযোজ্য; পুনর্বিতরণের আগে `LICENSE` পড়ুন।

## কী কী পরিবর্তন করা হয়েছে
- অ্যাপের নাম: **Amar Avro Keyboard**
- অ্যাপ আইকন ও input-menu icon: আপনার দেওয়া লোগো
- Credits screen: এই fork-এর maintainer হিসেবে Md Rakib Hossain এবং upstream project-এর acknowledgement
- Bundle identifier: `com.rakibhossain.amaravrokeyboard`
- GitHub Actions workflow-তে নতুন scheme ও app নাম সেট করা হয়েছে

## GitHub-এ Build
1. GitHub-এ নতুন repository তৈরি করে এই ফোল্ডারের সব ফাইল upload করুন।
2. **Actions** ট্যাব খুলে workflow enable করুন।
3. **Build** workflow-তে **Run workflow** চাপুন, অথবা `v1.0.0`-এর মতো version tag push করুন।
4. workflow শেষ হলে build artifacts ডাউনলোড করুন।
5. প্রকাশের জন্য signing/notarization চাইলে `.github/workflows/build.yml`-এ উল্লেখিত Apple Developer ID ও App Store Connect secrets সেট করুন।

এই পরিবেশে Xcode build চালানো হয়নি। GitHub Actions-এর ফলাফল সফল হয়েছে কি না যাচাই করে তারপর বিতরণ করবেন।

## Mac-এ Local Build
1. Xcode 16 বা পরের সংস্করণ ইনস্টল করুন।
2. `AvroKeyboard.xcodeproj` খুলুন।
3. **Amar Avro Keyboard** scheme নির্বাচন করুন।
4. **Product → Build** চাপুন।

## Install
1. Build করা `Amar Avro Keyboard.app` ফাইলটি `~/Library/Input Methods/` ফোল্ডারে কপি করুন।
2. macOS ইনপুট মেথড শনাক্ত না করলে log out করে আবার log in করুন।
3. **System Preferences → Keyboard → Input Sources (macOS Monterey 12)** থেকে Bangla যোগ করে **Amar Avro Keyboard** নির্বাচন করুন।
4. Preferences থেকে keyboard layout ও output option বেছে নিন।

## Upstream acknowledgement
এই fork-টি OmicronLab এবং iAvro / Avro Keyboard-এর মূল ও কমিউনিটি অবদানকারীদের কাজের ওপর ভিত্তি করে তৈরি। এটি স্বাধীন প্রকল্প, OmicronLab-এর official release নয়। Avro নাম ও সংশ্লিষ্ট trademark-এর অধিকার নিজ নিজ মালিকের হতে পারে।

## License
সম্পূর্ণ শর্তের জন্য `LICENSE` দেখুন। পুনর্বিতরণের সময় প্রযোজ্য license এবং source-file copyright notice সংরক্ষণ করুন।


## UI ও GitHub Build Fix

General ও AutoCorrect Preferences-এর layout-এ নতুন heading, spacing এবং বড় window যুক্ত করা হয়েছে। App icon, menu icon ও website icon asset-এ Amar Avro Keyboard-এর branding ব্যবহার করা হয়েছে। GitHub Actions-এ script-গুলো সরাসরি execute না করে `bash` দিয়ে চালানো হয়, ফলে executable permission না থাকলেও DMG build step-এ `Permission denied` হওয়ার কথা নয়। Build ও signing সম্পর্কে `BUILD-FIXES.md` দেখুন।

### Input Sources-এ Amar Avro Keyboard না দেখালে

1. System Preferences বন্ধ করুন। `Amar Avro Keyboard.app` অবশ্যই `~/Library/Input Methods/`-এর ভেতরে থাকবে; অতিরিক্ত nested folder-এর মধ্যে নয়।
2. ওই folder থেকে app-টি একবার চালু করুন। এখন app চালু হলে নিজে থেকে Text Input Source register ও enable করার চেষ্টা করবে, হাতে copy করা হলেও।
3. macOS থেকে log out করে আবার log in করুন। এরপর **System Preferences → Keyboard → Input Sources → + (macOS Monterey 12)** খুলে **Bangla** অথবা **Other** বিভাগ দেখুন। macOS version অনুযায়ী category আলাদা হতে পারে।
4. তবুও না দেখালে `~/Library/Input Methods/` থেকে পুরোনো duplicate app সরিয়ে শুধু নতুনটি রাখুন, Mac restart করে আবার চেষ্টা করুন।

Build সফল হলেই macOS-এর cached input-source তালিকা আপডেট হয়ে যায়—এমন নিশ্চয়তা নেই।

