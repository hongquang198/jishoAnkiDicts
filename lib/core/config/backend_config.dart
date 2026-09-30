// Central switch between Firebase and the custom backend: no run flags needed.
// Physical device rule: phone + PC on the same Wi-Fi, uvicorn bound to 0.0.0.0.
abstract final class BackendConfig {
  // false = Firebase (release default), true = custom REST backend.
  static const bool useRest = true;

  // Reachable base URL per flavor (Picked by --dart-define=FLAVOR, which the
  // VS Code launch configs set; bare `flutter run` defaults to dev):
  // - dev: PC's Wi-Fi IPv4 (physical phone) — local Postgres via LAN.
  // - prod: Render URL — Neon cloud, no LAN needed.
  // - Android emulator: http://10.0.2.2:8000 (pass FLAVOR=dev + override here
  //   or via --dart-define=API_BASE_URL, emulator loopback is special).
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static String get apiBaseUrl => switch (_flavor) {
        'prod' => 'https://jishoankidicts.onrender.com',
        _ => 'http://192.168.0.104:8000',
      };
}
