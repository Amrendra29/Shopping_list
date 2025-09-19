import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryitems = [];
  void _additem() async {
    final newitem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));
    if (newitem == null) return;

    setState(() {
      _groceryitems.add(newitem);
    });
  }

  void _remove(GroceryItem item) {
    setState(() {
      _groceryitems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text('No items added yet'));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _additem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
