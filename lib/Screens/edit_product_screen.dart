import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';

import '../providers/product.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String route = '/edit-product';
  EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  Product _existingProduct = Product(
      id: DateTime.now().toString(),
      title: '',
      description: '',
      price: 0.0,
      imageUrl: '');
  var _intialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _existingProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _intialValues = {
          'title': _existingProduct.title,
          'description': _existingProduct.description,
          'price': _existingProduct.price.toString(),
          // 'imageUrl': _existingProduct.imageUrl
          'imageUrl': ''
        };
        _imageUrlController.text = _existingProduct.imageUrl;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty) {
        return;
      }
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) {
        return;
      }
      if (!_imageUrlController.text.endsWith('.png') &&
          !_imageUrlController.text.endsWith('.jpg') &&
          !_imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  Future<void> _formSave() async {
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final productId = ModalRoute.of(context)!.settings.arguments;

    if (productId != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(productId as String, _existingProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_existingProduct);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error ocuured !'),
            content: Text('Something went wrong. '),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'okay',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              )
            ],
          ),
        );
        // } finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _formSave,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: _intialValues['title'],
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _existingProduct = Product(
                            id: _existingProduct.id,
                            title: value as String,
                            description: _existingProduct.description,
                            price: _existingProduct.price,
                            imageUrl: _existingProduct.imageUrl,
                            isFavorite: _existingProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: _intialValues['price'],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Please provide a value';
                        }
                        if (double.tryParse(value as String) == null) {
                          return 'Please enter a valid price';
                        }
                        if (double.parse(value as String) <= 0) {
                          return 'Please enter a value greater than zero';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _existingProduct = Product(
                            id: _existingProduct.id,
                            title: _existingProduct.title,
                            description: _existingProduct.description,
                            price: double.parse(value as String),
                            imageUrl: _existingProduct.imageUrl,
                            isFavorite: _existingProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: _intialValues['description'],
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Please provide a value';
                        }
                        if ((value as String).length < 10) {
                          return 'Should be at least 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _existingProduct = Product(
                            id: _existingProduct.id,
                            title: _existingProduct.title,
                            description: value as String,
                            price: _existingProduct.price,
                            imageUrl: _existingProduct.imageUrl,
                            isFavorite: _existingProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Image URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            // initialValue: _intialValues['imageUrl'], //if you have a controller on textFormField you can't set an inital value
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if ((value as String).isEmpty) {
                                return 'Please provide a value';
                              }
                              if (!(value as String).startsWith('http') &&
                                  !(value as String).startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!(value as String).endsWith('.png') &&
                                  !(value as String).endsWith('.jpg') &&
                                  !(value as String).endsWith('.jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              _formSave();
                            },
                            onSaved: (value) {
                              _existingProduct = Product(
                                  id: _existingProduct.id,
                                  title: _existingProduct.title,
                                  description: _existingProduct.description,
                                  price: _existingProduct.price,
                                  imageUrl: value as String,
                                  isFavorite: _existingProduct.isFavorite);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
