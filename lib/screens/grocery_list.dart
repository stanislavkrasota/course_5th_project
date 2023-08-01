import 'dart:convert';

import 'package:course_5th_project/mocks/categories.dart';
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
  late Future<List<GroceryItem>> _loadedItems;
  // var isLoading = true; // Use it you use FutureBuilder
  // String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https('flutter-grocery-868f9-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json '},
    );

    if (res.statusCode >= 400) {
      // Use it when use FutureBuilder
      // setState(() {
      //   _error = 'Failed fetch data, please try again later.';
      // });
      throw Exception('Failed fetch data, please try again later. ');
    }

    // Backend speciific
    if (res.body == 'null') {
      return [];
    }
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
    }
    return loadedItems;
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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-grocery-868f9-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final res = await http.delete(url);
    if (res.statusCode >= 300) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use it when  use FutureBuilder
    // Widget content = const Center(child: Text('There is no items yet'));

    // if (_isLoading) {
    //   content = const Center(child: CircularProgressIndicator());
    // }

    // if (_groceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (BuildContext ctx, int index) => Dismissible(
    //       key: ValueKey(_groceryItems[index].id),
    //       child: ListTile(
    //         title: Text(
    //           _groceryItems[index].name,
    //         ),
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color,
    //         ),
    //         trailing: Text(
    //           _groceryItems[index].quantity.toString(),
    //         ),
    //       ),
    //       onDismissed: (direction) {
    //         _removeItem(_groceryItems[index]);
    //       },
    //     ),
    //   );
    // }

    // if (_error != null) {
    //   content = Center(child: Text(_error!));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data!.isEmpty) {
            const Center(child: Text('There is no items yet'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext ctx, int index) => Dismissible(
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(
                  snapshot.data![index].name,
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
            ),
          );
        },
      ),
    );
  }
}
