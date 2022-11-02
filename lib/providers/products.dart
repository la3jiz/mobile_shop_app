import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../resources/dummy_product.dart';

class Products with ChangeNotifier {
  List<Product> _items = DUMMY_PRODUCTS;

  // bool _isFavorite = false;

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  // Products.secondProductsConstructor(this.authToken, this._items);

  // void setToken(String token) {
  //   authToken = token;
  // }

  // void setItems(List<Product> items) {
  //   _items = items;
  // }

  // Products.secondConstructorProducts(){
  //   this._items=this.items;
  //   this.authToken=this.authToken;
  // }

  List<Product> get items {
    // if (_isFavorite) {
    //   return _items.where((prod) => (prod.isFavorite)).toList();
    // }
    return [..._items];
  }

  List<Product> get showFavoriteOnly {
    return _items.where((prod) => (prod.isFavorite)).toList();
  }

  // void showAll() {
  //   _isFavorite = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

//addProducts method with .then and .catchError
  // Future<void> addProduct(Product product) {
  //   const url =
  //       'https://flutter-app-d9b28-default-rtdb.firebaseio.com/products.json';
  //   return http
  //       .post(
  //     Uri.parse(url),
  //     body: json.encode({
  //       'title': product.title,
  //       'description': product.description,
  //       'price': product.price,
  //       'imageUrl': product.imageUrl,
  //       'isFavorite': product.isFavorite
  //     }),
  //   )
  //       .then((response) {
  //     print(json.decode(response.body));
  //     product.setId(json.decode(response.body)['name'] as String);
  //     _items.add(product);
  //     notifyListeners();
  //   }).catchError((error) {
  //      throw error;
  //   });
  // }
//addProducts method with async await note(async automatically returns a future you don't need to put return in the method )
  Future<void> addProduct(Product product) async {
    final String db_url =
        'https://flutter-app-d9b28-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(db_url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId
          // 'isFavorite': product.isFavorite
        }),
      );
      // print(json.decode(response.body));
      product.setId(json.decode(response.body)['name'] as String);
      _items.add(product);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterUrlString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId" ' : '';
    final String db_url =
        'https://flutter-app-d9b28-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterUrlString';
    try {
      final response = await http.get(Uri.parse(db_url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final String fav_url =
          'https://flutter-app-d9b28-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favResponse = await http.get(Uri.parse(fav_url));
      final favoriteData = json.decode(favResponse.body);

      List<Product> newItemsList = [];
      extractedData.forEach((productId, productData) {
        newItemsList.add(Product(
          id: productId,
          title: productData['title'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          imageUrl: productData['imageUrl'] as String,
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      _items = newItemsList;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProd) async {
    final String db_url =
        'https://flutter-app-d9b28-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    await http.patch(
      Uri.parse(db_url),
      body: json.encode(
        {
          'title': newProd.title,
          'description': newProd.description,
          'price': newProd.price,
          'imageUrl': newProd.imageUrl,
          // 'isFavorite': newProd.isFavorite
        },
      ),
    );
    _items[prodIndex] = newProd;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-app-d9b28-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
