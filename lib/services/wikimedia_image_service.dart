import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches descriptive images for dictionary entries from Wikimedia Commons.
///
/// Wikimedia's API is free and does not require an API key. A descriptive
/// User-Agent is mandatory per Wikimedia's access policy — default Dart/http
/// user agents are commonly rejected with 403.
class WikimediaImageService {
  static const _endpoint = 'https://commons.wikimedia.org/w/api.php';
  static const _userAgent =
      'JishoAnkiDicts/1.0 (Flutter dictionary app; educational use)';

  /// Returns a thumbnail URL for the first bitmap match of [searchTerm],
  /// or null when nothing suitable was found or the request failed.
  Future<String?> fetchThumbnailUrl(String searchTerm) async {
    final term = searchTerm.trim();
    if (term.isEmpty) return null;

    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'query',
      'format': 'json',
      'generator': 'search',
      'gsrsearch': 'filetype:bitmap $term',
      'gsrnamespace': '6',
      'gsrlimit': '5',
      'prop': 'imageinfo',
      'iiprop': 'url',
      'iiurlwidth': '600',
    });

    try {
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = json['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null || pages.isEmpty) return null;

      for (final page in pages.values) {
        final infos = (page as Map<String, dynamic>)['imageinfo'] as List?;
        if (infos == null || infos.isEmpty) continue;
        final url =
            (infos.first as Map<String, dynamic>)['thumburl'] as String?;
        if (url != null && url.isNotEmpty) return url;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
