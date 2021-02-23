import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final url =
        'https://myshop-a165c-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    var currentFavorate = isFavorite;
    try {
      isFavorite = !isFavorite;
      notifyListeners();
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        throw HttpException('faild to change fave statuse ');
      }
      currentFavorate = null;
    } catch (e) {
      print(e);
      isFavorite = currentFavorate;
      notifyListeners();
    }
  }
}
