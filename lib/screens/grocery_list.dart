import 'dart:convert';

import 'package:course_5th_project/mocks/categories.dart';
import 'package:course_5th_project/mocks/dummy_items.dart';
import 'package:course_5th_project/models/grocery_item.dart';
import 'package:course_5th_project/screens/new_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('flutter-grocery-868f9-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final Map<String, dynamic> body = json.decode(res.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in body.entries) {
      final category = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
      setState(() {
        _groceryItems = loadedItems;
      });
    }
  }

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
