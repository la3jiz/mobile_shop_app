import "package:flutter/material.dart";
import '../Screens/auth_screen.dart';
import '../Screens/edit_product_screen.dart';
import '../Screens/splash_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

import './Screens/user_products_screen.dart';
import './Screens/orders_screen.dart';
import './Screens/cart_screen.dart';
import './providers/cart.dart';
import './Screens/product_details_screen.dart';
import '../Screens/product_overview_screen.dart';
import './providers/products.dart';
import './providers/orders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
/*
* side note: .value vs create:
-whenever you want to estentiate a new class provider like in main.dart use create and whenever you want to use existing 
class  provider use .value like in products_grid.dart

 */
    //changeNotifierProvider work with to methods without .value with create attribute or .value constructor and value attribute
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(
        //   // use .value when you don't need the context and when use existing class provider
        //   // value: Products(),
        //   create: (ctx) => Products(),
        // ),
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // use .value when you don't need the context and when use existing class provider
          // value: Products(),
          // create: (_) => Products(),
          update: (ctx, auth, prevProducts) => Products(
              auth.token as String,
              auth.userId as String,
              prevProducts == null ? [] : prevProducts.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, prevOrders) => Orders(
                auth.token as String,
                auth.userId as String,
                prevOrders == null ? [] : prevOrders.orders)),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        return MaterialApp(
            theme: ThemeData(
                primarySwatch: Colors.deepOrange,
                accentColor: Colors.amber,
                textTheme: TextTheme(
                  titleMedium: TextStyle(fontFamily: 'lato'),
                  titleSmall: TextStyle(fontFamily: 'Lato'),
                  titleLarge: TextStyle(fontFamily: 'Lato'),
                ),
                fontFamily: 'Lato'),
            // initialRoute: '/',
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : snapshot.data == true
                                ? ProductOverviewScreen()
                                : AuthScreen()),
            routes: {
              // '/': (_) => ProductOverviewScreen(),
              ProductDetailsScreen.route: (_) => ProductDetailsScreen(),
              CartScreen.route: (_) => CartScreen(),
              OrdersScreen.route: (_) => OrdersScreen(),
              UserProductsScreen.route: (_) => UserProductsScreen(),
              EditProductScreen.route: (_) => EditProductScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (_) => ProductOverviewScreen());
            });
      }),
    );
  }
}

// class MyAppPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('new App'),
//       ),
//       body: Center(child: Text('new App')),
//     );
//   }
// }
