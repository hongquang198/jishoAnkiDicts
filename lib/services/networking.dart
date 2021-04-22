import 'dart:convert';

import 'package:http/http.dart' as http;
import 'location.dart';

class NetworkHelper {
  String url;

  NetworkHelper(this.url);

  Future getData() async {
    await Future.delayed(Duration(milliseconds: 500));
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else
      print(response.statusCode);
  }
}
