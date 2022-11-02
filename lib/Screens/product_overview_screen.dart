import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../Screens/cart_screen.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../providers/products.dart';

enum FavoriteOption { Favorite, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFavorite = false;
  bool _isInit = false;
  bool _isLoading = false;

  //fetching data from db
  @override
  void initState() {
    //*Won't work because initState con't work with .of(context) before the widgets builds completely
    //Provider.of<Products>(context).fetchAndSetProducts();

    //*solution for initState
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    // });
    super.initState();
  }

  //another approach for fetching data from db
//*didChangeDependencies need a variable like we used _isInit to run it once not multiple times because it runs on every change in this widget
  @override
  void didChangeDependencies() {
  
    if (!_isInit) {
        setState(() {
      _isLoading = true;
    });
      Provider.of<Products>(context, listen: false).fetchAndSetProducts().then((_) =>       setState(() {
        _isLoading = false;
      }));

    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FavoriteOption value) {
              if (value == FavoriteOption.Favorite) {
                setState(() {
                  _showFavorite = true;
                });
              } else {
                setState(() {
                  _showFavorite = false;
                });
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                value: FavoriteOption.Favorite,
              ),
              PopupMenuItem(
                child: Text('Show All',
                    style: Theme.of(context).textTheme.titleLarge),
                value: FavoriteOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.route);
              },
            ),
            builder: (_, cart, child) => Badge(
              child: child as Widget,
              value: cart.getCartProductCount.toString(),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavorite),
    );
  }
}
