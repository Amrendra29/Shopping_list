import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryitems = [];
  var _isloading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = Uri.https(
      'flutter-prep-7fa8c-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data from database.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }
      final Map<String, dynamic> listdata = json.decode(response.body);
      final List<GroceryItem> _loadeditems = [];
      for (final items in listdata.entries) {
        final category = categories.entries
            .firstWhere(
              (catitem) => catitem.value.title == items.value['category'],
            )
            .value;
        _loadeditems.add(
          GroceryItem(
            id: items.key,
            name: items.value['name'],
            quantity: items.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryitems = _loadeditems;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong.Try again';
      });
    }
  }

  void _additem() async {
    final newitem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (newitem == null) {
      return;
    }
    setState(() {
      _groceryitems.add(newitem);
    });
  }

  void _remove(GroceryItem item) async {
    final index = _groceryitems.indexOf(item);
    setState(() {
      _groceryitems.remove(item);
    });
    final url = Uri.https(
      'flutter-prep-7fa8c-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryitems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text('No items added yet'));

    if (_isloading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _remove(_groceryitems[index]);
          },
          key: ValueKey(_groceryitems[index].id),
          child: ListTile(
            title: Text(_groceryitems[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryitems[index].category.color,
            ),
            trailing: Text(
              _groceryitems[index].quantity.toString(),
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _additem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
