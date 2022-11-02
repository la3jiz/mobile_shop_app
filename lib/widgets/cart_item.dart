import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String productId;
  const CartItem({
    Key? key,
    required this.id,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        color: Color.fromARGB(178, 255, 0, 8),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.delete,
            size: 25,
            color: Colors.white,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        //listen false is a must do because the provider listener used here is local
        Provider.of<Cart>(context, listen: false).removeItemFromCart(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are you sure !'),
                  content: Text(
                    'Do you want to remove the item from the cart ?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        'No',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                    FlatButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Yes',
                          style:
                              TextStyle(color: Theme.of(context).accentColor)),
                    ),
                  ],
                ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(2),
              child: FittedBox(child: Text('\$${price}')),
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text('Total: \$${price * quantity} '),
          trailing: Text('$quantity X '),
        ),
      ),
    );
  }
}
