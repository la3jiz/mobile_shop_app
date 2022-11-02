import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description, 
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void setId(String id) {
    this.id = id;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setPrice(double price) {
    this.price = price;
  }

  void setDescription(String description) {
    this.description = description;
  }

  void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  Future<void> toggleFavorite(String authToken, String userId) async {
    final String db_url =
        'https://flutter-app-d9b28-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    final oldFavoriteStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(
      Uri.parse(db_url),
      body: json.encode(isFavorite),
    );
    if (response.statusCode >= 400) {
      isFavorite = oldFavoriteStatus;
      notifyListeners();
      throw Exception();
    }
  }
}
