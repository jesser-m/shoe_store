# TODO - Local server URL input (phone & wifi)

## Goal
Make the Flutter app use a server Base URL that the user can set on the phone (so it works on the same WiFi as the PC).

## Agreed behavior
User enters **IP only** (example: `192.168.1.50`).
We assume **port = 3000** and build:
`http://<IP>:3000/api`

## Steps
1. Add setting key in `SettingsProvider` for API IP (`api_ip`).
2. Add methods in `SettingsProvider` to save/get API IP.
3. Update `ApiConfig` so `baseUrl` is derived from saved IP (with fallback to current defaults).
4. Call `ApiConfig.init()` before `runApp` in `lib/main.dart`.
5. Add UI in `lib/screens/profile_screen.dart` inside Settings card:
   - TextField: “Server IP”
   - Save button
6. Test on same WiFi:
   - set IP on phone
   - refresh app
   - verify API calls (load products)

## Progress
- [x] Implement `api_ip` storage + setters/getters
- [x] Implement `ApiConfig.init()` and dynamic `baseUrl`
- [x] Add UI + Save in profile screen
- [x] Wire init in main
- [ ] Test on same WiFi: set IP on phone -> refresh -> load products


