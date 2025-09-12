import 'package:flutter/foundation.dart';
import '../../transactions/data/models/store.dart';

class StoreProvider extends ChangeNotifier {
  Store? _selectedStore;

  Store? get selectedStore => _selectedStore;

  /// Set the currently selected store
  void setSelectedStore(Store store) {
    _selectedStore = store;
    notifyListeners();
    debugPrint('🏪 Store selected: ${store.name} (ID: ${store.id})');
  }

  /// Initialize with first store from user's stores list
  void initializeWithStores(List<Store> stores) {
    if (stores.isNotEmpty && _selectedStore == null) {
      _selectedStore = stores.first;
      debugPrint(
        '🏪 Store initialized: ${_selectedStore!.name} (ID: ${_selectedStore!.id})',
      );
    }
  }

  /// Get the selected store ID or return default
  int getSelectedStoreId() {
    return _selectedStore?.id ?? 1;
  }

  /// Clear selected store
  void clearSelectedStore() {
    _selectedStore = null;
    notifyListeners();
    debugPrint('🏪 Store selection cleared');
  }

  /// Check if a store is currently selected
  bool get hasSelectedStore => _selectedStore != null;

  /// Get selected store name for display
  String get selectedStoreName => _selectedStore?.name ?? 'Default Store';
}
