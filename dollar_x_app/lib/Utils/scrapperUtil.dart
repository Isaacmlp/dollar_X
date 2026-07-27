import 'dart:convert';
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ScrapperUtil {
  static Future<double?> _fetchBcvRate(String selector) async {
    try {
      final HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final IOClient ioClient = IOClient(httpClient);

      final response =
          await ioClient.get(Uri.parse('https://www.bcv.org.ve/'));

      if (response.statusCode == 200) {
        Document document = parser.parse(response.body);
        final element = document.querySelector(selector);

        if (element != null) {
          String rateString = element.text.trim();
          rateString = rateString.replaceAll(',', '.');
          return double.tryParse(rateString);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching BCV rate ($selector): $e');
      return null;
    }
  }

  static Future<double?> getDolarBcv() async {
    return _fetchBcvRate('#dolar strong');
  }

  static Future<double?> getEuroBcv() async {
    return _fetchBcvRate('#euro strong');
  }

  static Future<double?> getUsdtVes() async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search'),
      );
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', '*/*');
      request.write(jsonEncode({
        "asset": "USDT",
        "fiat": "VES",
        "tradeType": "SELL",
        "page": 1,
        "rows": 5,
        "payTypes": [],
        "countries": [],
        "publisherType": null,
      }));
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final offers = data['data'] as List<dynamic>;
        if (offers.isNotEmpty) {
          final best = offers[0] as Map<String, dynamic>;
          final adv = best['adv'] as Map<String, dynamic>;
          final price = double.tryParse(adv['price'].toString());
          if (price != null) return price;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching USDT/VES from Binance P2P: $e');
      return null;
    }
  }
}
