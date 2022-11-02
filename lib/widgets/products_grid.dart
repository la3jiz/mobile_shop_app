import 'package:flutter/material.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _showFavorite;

  ProductsGrid(this._showFavorite);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        _showFavorite ? productsData.showFavoriteOnly : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      //changeNotifierProvider work with to methods without .value with create attribute or .value constructor and value attribute
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        //use .value when you don't need the context
        value: products[index],
        //or you can use create without .value constructor
        //create:(_)=>products[index]
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
