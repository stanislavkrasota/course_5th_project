import 'package:course_5th_project/mocks/dummy_items.dart';
import 'package:course_5th_project/models/grocery_item.dart';
import 'package:course_5th_project/screens/new_item.dart';
import 'package:flutter/material.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addNewItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyListContent =
        const Center(child: Text('There is no items yet'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
        ],
      ),
      body: _groceryItems.isNotEmpty
          ? ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (BuildContext context, int index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  title: Text(
                    _groceryItems[index].name,
                  ),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(
                    _groceryItems[index].quantity.toString(),
                  ),
                ),
                onDismissed: (direction) {
                  _removeItem(groceryItems[index]);
                },
              ),
            )
          : emptyListContent,
    );
  }
}
