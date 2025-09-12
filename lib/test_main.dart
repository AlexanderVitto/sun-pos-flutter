import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/providers/store_provider.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Store Provider Test')),
          body: Consumer<StoreProvider>(
            builder: (context, storeProvider, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Store Provider is working!'),
                    Text(
                      'Has selected store: ${storeProvider.hasSelectedStore}',
                    ),
                    Text(
                      'Selected store ID: ${storeProvider.getSelectedStoreId()}',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
