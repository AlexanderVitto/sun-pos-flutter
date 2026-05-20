import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../../transactions/data/models/store.dart';

class StoreProvider extends ChangeNotifier {
  Store? _selectedStore;
  final List<VoidCallback> _onStoreChangedCallbacks = [];

  Store? get selectedStore => _selectedStore;

  /// Add callback to be triggered when store changes
  void addOnStoreChangedCallback(VoidCallback callback) {
    _onStoreChangedCallbacks.add(callback);
  }

  /// Remove callback
  void removeOnStoreChangedCallback(VoidCallback callback) {
    _onStoreChangedCallbacks.remove(callback);
  }

  /// Set the currently selected store
  void setSelectedStore(Store store) {
    _selectedStore = store;
    notifyListeners();
    debugPrint('🏪 Store selected: ${store.name} (ID: ${store.id})');

    // Trigger all callbacks to reload data
    for (final callback in _onStoreChangedCallbacks) {
      callback.call();
    }
  }

  /// Initialize with first store from user's stores list.
  /// Saat berhasil men-set store dari null → store pertama, picu juga
  /// callback yang sama dengan setSelectedStore agar data dependen
  /// (TransactionListProvider, RefundListProvider, dll) ikut termuat.
  ///
  /// Notifikasi & callback di-defer ke post-frame karena method ini sering
  /// dipanggil dari `initState` atau dari listener yang fire selama build
  /// phase parent — `notifyListeners()` sync di sini akan throw
  /// "setState() called during build".
  void initializeWithStores(List<Store> stores) {
    if (stores.isNotEmpty && _selectedStore == null) {
      _selectedStore = stores.first;
      debugPrint(
        '🏪 Store initialized: ${_selectedStore!.name} (ID: ${_selectedStore!.id})',
      );

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        for (final callback in _onStoreChangedCallbacks) {
          callback.call();
        }
      });
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
