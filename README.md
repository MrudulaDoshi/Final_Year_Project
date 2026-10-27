# UWB Hospital Navigation Flutter app

This Flutter app displays the supplied map, node/door/anchor markers and route returned by the Flask API.

## Run on Android Emulator
1. Start the Python backend first (instructions in `../UWB_Hospital_Navigation_New/README.md`).
2. In this folder run `flutter pub get`.
3. Run `flutter run`.
4. The Android emulator uses `http://10.0.2.2:5000` to reach Flask running on your computer.

For a real Android phone, connect phone and computer to the same Wi-Fi and change `apiBase` in `lib/main.dart` to the computer's LAN IPv4 address. Allow port 5000 through the computer firewall if prompted.
