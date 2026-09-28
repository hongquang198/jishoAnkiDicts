// Central switch between Firebase and the custom backend: no run flags needed.
// Physical device rule: phone + PC on the same Wi-Fi, uvicorn bound to 0.0.0.0.
abstract final class BackendConfig {
  // false = Firebase (release default), true = custom REST backend.
  static const bool useRest = true;

  // Reachable base URL per target:
  // - Android emulator: http://10.0.2.2:8000 (emulator's host loopback)
  // - Physical phone: PC's Wi-Fi IPv4 (ipconfig → Wireless LAN adapter Wi-Fi)
  // - iOS simulator / desktop: http://localhost:8000
  static const String apiBaseUrl = 'http://192.168.0.104:8000';
}
