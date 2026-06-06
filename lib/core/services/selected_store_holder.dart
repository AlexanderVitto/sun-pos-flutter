/// Penyimpan ringan ID toko yang sedang dipilih, agar lapisan service
/// (yang tidak punya akses ke BuildContext/Provider) bisa menyisipkan
/// `store_id` ke request tanpa perlu di-threading lewat setiap pemanggil.
///
/// Sumber kebenaran tetap [StoreProvider]; holder ini hanya cermin nilainya.
/// StoreProvider wajib meng-update holder ini saat memilih / init / clear store.
class SelectedStoreHolder {
  SelectedStoreHolder._();

  static final SelectedStoreHolder instance = SelectedStoreHolder._();

  /// ID toko terpilih saat ini, atau null bila belum ada.
  int? storeId;

  /// Kosongkan pilihan (mis. saat logout / ganti user).
  void clear() => storeId = null;
}
