import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  static final String route = '/product-details';
  @override
  Widget build(BuildContext context) {
    final _productIdFromRoute =
        ModalRoute.of(context)?.settings.arguments as String;
    final _productFromProvider = Provider.of<Products>(context, listen: false)
        .findById(_productIdFromRoute);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_productFromProvider.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_productFromProvider.title),
              background: Hero(
                tag: _productFromProvider.id,
                child: Image.network(
                  _productFromProvider.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 20,
            ),
            Text(
              '\$${_productFromProvider.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              _productFromProvider.description,
              textAlign: TextAlign.center,
            ),
          ]))
        ],
      ),
    );
  }
}
