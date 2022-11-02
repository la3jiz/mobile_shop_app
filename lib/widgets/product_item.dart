import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_complete_guide/providers/auth.dart';
import '../providers/cart.dart';
import '../Screens/product_details_screen.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // final String description;
  // final double price;

  // ProductItem(
  //     {required .id,
  //     required .title,
  //     required .imageUrl,
  //     required this.description,
  //     required this.price});

  void _selectProduct(BuildContext context, String prodId) {
    Navigator.of(context)
        .pushNamed(ProductDetailsScreen.route, arguments: prodId);
  }

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _cart = Provider.of<Cart>(context, listen: false);
    final _auth = Provider.of<Auth>(context);
    final scaffold = Scaffold.of(context);
    return GestureDetector(
      onTap: () => _selectProduct(context, _product.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: Hero(
            //tag must be unique to make flutter know which image to animate with hero animation
            tag: _product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(
                _product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(
              _product.title,
              textAlign: TextAlign.center,
            ),
            /* use consumer when you d'ont want the widget to rebuild when the data change
          because Provider rebuild the widget when the data change
        */
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                icon: Icon(_product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await _product.toggleFavorite(
                        _auth.token as String, _auth.userId as String);
                  } catch (err) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text('Add to favorite failed !'),
                      ),
                    );
                  }
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                _cart.addItemToCart(
                    _product.id, _product.title, _product.price);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('added to cart successfully! '),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _cart.removeSingleItem(_product.id);
                      },
                    ),
                  ),
                );
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
