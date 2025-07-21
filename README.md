# purplestack

![purplestack](assets/images/purplestack.png)

Development stack designed for AI agents to build Nostr-enabled Flutter applications. It includes a complete tech stack based on Riverpod and Purplebase, along with documentation and recipes for common implementation scenarios.

See [CONTEXT](CONTEXT.md) for more.

Originally created to build the new version of [Zapstore](https://zapstore.dev) and to encourage many more freedom oriented tech tools in the store.

## Change

To modify the assistant's instructions or add new project-specific guidelines:

1. Add a Markdown file in the context folder and run `./generate-context.sh`
2. The changes take effect in the next session

## Sample environment setup

For MacOS (may work with Homebrew on Linux) and just for guidance. View the respective projects' documentation for more.

```bash
# Install Android
brew install android-commandlinetools
# add to shell's rc file ANDROID_SDK_ROOT=/opt/homebrew/share/android-commandlinetools

# Install Java
brew install openjdk@17

# Install Dart
brew tap dart-lang/dart
brew install dart
dart --disable-analytics
dart pub global activate fvm

# Install Flutter
fvm releases
fvm install <version>

sdkmanager --install "platforms;android-35"
sdkmanager --install "build-tools;35.0.0"
sdkmanager --install emulator platform-tools tools
sdkmanager --licenses

sdkmanager --install "system-images;android-30;google_apis;arm64-v8a"
avdmanager create avd --name "pixel_8" --package "system-images;android-35;google_apis;arm64-v8a" --abi "arm64-v8a" --device "pixel_8"
```

## License

MIT