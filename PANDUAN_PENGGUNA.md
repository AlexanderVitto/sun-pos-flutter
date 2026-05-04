# 📱 PANDUAN PENGGUNA SUN POS

## Daftar Isi

- [Tentang Aplikasi](#tentang-aplikasi)
- [Memulai](#memulai)
- [Fitur Utama](#fitur-utama)
  - [1. Dashboard](#1-dashboard)
  - [2. Transaksi POS](#2-transaksi-pos)
  - [3. Produk](#3-produk)
  - [4. Pelanggan](#4-pelanggan)
  - [5. Daftar Transaksi](#5-daftar-transaksi)
  - [6. Hutang/Outstanding](#6-hutangoutstanding)
  - [7. Pesanan/Draft](#7-pesanandraft)
  - [8. Refund](#8-refund)
  - [9. Arus Kas](#9-arus-kas)
  - [10. Laporan](#10-laporan)
  - [11. Printer Bluetooth](#11-printer-bluetooth)
- [Tips & Trik](#tips--trik)
- [FAQ](#faq)

---

## Tentang Aplikasi

**SUN POS** adalah aplikasi Point of Sale (POS) yang dirancang untuk membantu pengelolaan toko retail/grosir dengan fitur lengkap meliputi:

- 🛒 Penjualan dengan keranjang belanja
- 📦 Manajemen produk & stok
- 👥 Manajemen pelanggan & grup harga
- 💰 Multiple metode pembayaran
- 📝 Tracking hutang pelanggan
- 🔄 Refund & edit transaksi
- 💵 Pencatatan arus kas
- 📊 Laporan penjualan
- 🖨️ Cetak struk via Bluetooth

---

## Memulai

### Login

1. Buka aplikasi SUN POS
2. Masukkan **email/username** dan **password**
3. Tap tombol **Masuk**

### Role/Peran Pengguna

Aplikasi mendukung berbagai peran dengan hak akses berbeda:

- **Owner/Manager** (Role ID ≤ 2): Akses penuh ke semua fitur
- **Cashier/Staff** (Role ID > 2): Akses terbatas untuk operasional harian

> **Catatan**: Beberapa fitur hanya tersedia untuk role tertentu

---

## Fitur Utama

### 1. Dashboard

Dashboard adalah halaman utama yang menampilkan ringkasan bisnis Anda.

#### Untuk Owner/Manager:

**Kartu Statistik Hari Ini:**

- 📊 Total Transaksi
- 💰 Total Pendapatan
- 📈 Rata-rata Nilai Transaksi
- 📦 Total Produk Terjual

**Informasi Toko:**

- Nama toko
- Alamat
- Kontak

**Quick Actions:**

- ➕ Transaksi Baru → Langsung ke halaman POS
- 👥 Kelola Pelanggan
- ⚙️ Pengaturan

**Transaksi Terbaru:**

- Menampilkan 5 transaksi terbaru
- Status transaksi (Selesai/Pending/Batal)
- Tap untuk melihat detail

#### Untuk Cashier/Staff:

- Informasi toko
- Quick action terbatas
- Notifikasi akses terbatas

---

### 2. Transaksi POS

Halaman Point of Sale untuk melakukan transaksi penjualan.

#### A. Memilih Produk

1. **Browse Produk**
   - Scroll untuk melihat katalog produk
   - Gunakan **Search** untuk mencari produk tertentu
   - Filter berdasarkan **Kategori**
   - Perhatikan stok yang tersedia

2. **Tambah ke Keranjang**
   - Tap produk untuk melihat detail
   - Jika produk memiliki varian:
     - Pilih varian yang diinginkan (ukuran, warna, dll)
     - Cek stok per varian
   - Atur **Quantity** (jumlah)
   - Tap **Tambahkan ke Keranjang**

#### B. Kelola Keranjang

Setelah menambahkan produk, Anda dapat:

- ✏️ **Edit Quantity**: Tambah atau kurangi jumlah
- 🏷️ **Edit Harga**: Ubah harga per item (opsional)
- 💸 **Diskon per Item**: Terapkan diskon persentase
- 🗑️ **Hapus Item**: Keluarkan dari keranjang

**Real-time Total**: Total harga otomatis dihitung ulang

#### C. Pilih Pelanggan (Opsional)

Keuntungan memilih pelanggan:

- Harga otomatis disesuaikan dengan grup pelanggan
- Tracking riwayat pembelian
- Opsi pembayaran hutang

**Cara:**

1. Tap **Pilih Pelanggan**
2. **Browse** dari daftar atau **Search** by nama/telepon
3. Atau **Tambah Pelanggan Baru** on-the-fly
4. Pilih pelanggan yang sesuai

#### D. Proses Pembayaran

1. **Review Keranjang**
   - Pastikan semua item sudah benar
   - Cek total pembayaran

2. **Tap Bayar**

3. **Pilih Metode Pembayaran:**
   - 💵 **Tunai (Cash)**
   - 🏦 **Transfer Bank**
   - 💳 **Kartu Debit/Kredit**
   - 📱 **E-Wallet (QRIS)**
   - 🔀 **Campuran** (kombinasi 2 metode)

4. **Pilih Status Pembayaran:**

   **LUNAS (Paid):**
   - Masukkan jumlah uang yang diterima
   - Sistem akan hitung kembalian otomatis
   - Klik **Selesaikan Pembayaran**

   **UTANG/OUTSTANDING:**
   - Pilih opsi **Bayar Nanti** atau **Bayar Sebagian**
   - Set **Tanggal Jatuh Tempo** (reminder)
   - Jumlah hutang akan tercatat
   - Klik **Simpan Transaksi**

5. **Konfirmasi & Selesai**

#### E. Transaksi Selesai

Setelah pembayaran:

- ✅ Lihat **Struk Digital** dengan detail lengkap
- 🖨️ **Cetak Struk** via Bluetooth printer
- 📤 **Share** atau **Copy** struk
- ➕ **Transaksi Baru** untuk mulai penjualan berikutnya
- 🏠 **Kembali ke Dashboard**

#### F. Draft Transaksi

Transaksi otomatis disimpan sebagai draft:

- Saat Anda menambahkan item ke keranjang
- Bisa dilanjutkan kapan saja
- Akses via menu **Pesan**

---

### 3. Produk

Kelola katalog produk toko Anda.

#### Melihat Daftar Produk

- **Scroll** untuk melihat semua produk (infinite scroll)
- **Search** berdasarkan nama produk
- **Filter** berdasarkan kategori
- Setiap kartu produk menampilkan:
  - 🖼️ Gambar produk
  - 📝 Nama & SKU
  - 💰 Harga
  - 📦 Status stok
  - 🏷️ Badge varian (jika ada)

#### Detail Produk

Tap produk untuk melihat:

- Informasi lengkap produk
- Semua varian tersedia
- Harga per varian
- Stok per varian
- Atribut (ukuran, warna, dll)
- Tombol **Tambah ke Keranjang** langsung

#### Indikator Stok

- 🔴 **Habis**: Stok = 0
- 🟡 **Stok Menipis**: Stok ≤ 5
- 🟢 **Tersedia**: Stok > 5

---

### 4. Pelanggan

Kelola data pelanggan dan grup harga.

#### A. Daftar Pelanggan

- Lihat semua pelanggan (infinite scroll)
- **Search** real-time by nama/telepon
- Kartu pelanggan menampilkan:
  - 👤 Nama lengkap
  - 📞 Nomor telepon
  - 🏷️ Grup pelanggan
  - 💰 Total hutang (jika ada)

#### B. Tambah Pelanggan Baru

1. Tap tombol **➕ Tambah Pelanggan**
2. Isi form:
   - **Nama Lengkap** (wajib)
   - **Nomor Telepon** (wajib)
   - **Grup Pelanggan** (opsional)
3. Tap **Simpan**

#### C. Edit Pelanggan

1. Tap pelanggan dari daftar
2. Tap ikon **Edit** (pensil)
3. Update informasi
4. Tap **Simpan Perubahan**

#### D. Hapus Pelanggan

1. Tap pelanggan dari daftar
2. Tap ikon **Hapus** (tempat sampah)
3. Konfirmasi penghapusan

#### Grup Pelanggan

Grup pelanggan menentukan harga khusus:

- 🛍️ **Retail** (0% diskon) - Harga normal
- 🏪 **Agen** (10% diskon)
- 📦 **Grosir** (15% diskon)
- ⭐ **VIP** (20% diskon)

> Harga otomatis disesuaikan saat pelanggan dipilih di POS

---

### 5. Daftar Transaksi

Lihat dan kelola semua transaksi.

#### A. Melihat Transaksi

**Kartu Transaksi menampilkan:**

- 🔢 Nomor transaksi
- 📅 Tanggal & waktu
- 👤 Nama pelanggan (jika ada)
- 💰 Total pembayaran
- 💳 Metode pembayaran
- 🏷️ Status badge (Selesai/Hutang/Pending/Batal)

#### B. Filter & Pencarian

**Quick Filters:**

- 📅 Hari Ini
- 📅 Minggu Ini
- 📅 Bulan Ini

**Advanced Filters:**

- 📆 **Date Range**: Pilih rentang tanggal
- 💵 **Jumlah**: Filter by minimum-maksimum
- 💳 **Metode Pembayaran**: Cash/Transfer/Card/E-Wallet
- 🏷️ **Status**: Completed/Outstanding/Pending/Cancelled

**Search:**

- Cari by nomor transaksi
- Real-time filtering

**Reset Filter**: Kembalikan ke default

#### C. Detail Transaksi

Tap transaksi untuk melihat:

- Informasi lengkap transaksi
- Detail pelanggan
- Daftar item dengan quantities
- Detail pembayaran
- Catatan
- Info kasir

#### D. Aksi Transaksi

Dari detail transaksi:

- 📄 **View Detail**: Lihat informasi lengkap
- 🖨️ **Print Receipt**: Cetak ulang struk
- ↩️ **Create Refund**: Buat refund (untuk status Selesai)
- ✏️ **Edit Transaction**: Edit transaksi (untuk status Hutang)

---

### 6. Hutang/Outstanding

Kelola pembayaran hutang pelanggan.

#### A. Daftar Pelanggan Berhutang

Menu **Hutang** menampilkan:

- 👥 Daftar pelanggan yang memiliki hutang
- 💰 Total hutang per pelanggan
- 🔢 Jumlah transaksi outstanding
- Sort berdasarkan jumlah/tanggal

#### B. Detail Hutang Pelanggan

Tap pelanggan untuk melihat:

**Header:**

- Info pelanggan lengkap
- Total hutang keseluruhan
- Total nilai transaksi
- Jumlah transaksi

**Daftar Transaksi:**

- Semua transaksi yang belum lunas
- Jumlah hutang per transaksi
- Progress bar pembayaran
- Tanggal jatuh tempo
- Riwayat cicilan (jika ada)

#### C. Bayar Hutang

**Cara Bayar Multi-Transaksi:**

1. **Tap FAB** (Floating Action Button) **"Bayar Hutang"**

2. **Review Total Hutang**
   - Sistem akan tampilkan total hutang keseluruhan

3. **Input Jumlah Pembayaran**
   - Masukkan jumlah uang yang dibayarkan
   - Bisa partial (sebagian) atau full (lunas)

4. **Pilih Metode Pembayaran**
   - Cash/Transfer/Card/E-Wallet

5. **Tambah Catatan** (opsional)

6. **Konfirmasi Pembayaran**

**Sistem Distribusi Otomatis:**

- Pembayaran didistribusikan ke transaksi dari yang **terlama** (FIFO)
- Transaksi yang lunas otomatis berubah status ke **Completed**
- Sisa hutang otomatis terupdate
- Riwayat cicilan tercatat

**Contoh:**

```
Pelanggan A punya 3 transaksi hutang:
- Transaksi 1 (1 Jan): Rp 100.000 (hutang Rp 100.000)
- Transaksi 2 (2 Jan): Rp 200.000 (hutang Rp 200.000)
- Transaksi 3 (3 Jan): Rp 150.000 (hutang Rp 150.000)

Total hutang: Rp 450.000

Pelanggan bayar Rp 250.000:
✅ Transaksi 1: Lunas (Rp 100.000)
✅ Transaksi 2: Lunas (Rp 200.000)
⏳ Transaksi 3: Tersisa Rp 100.000

Sisa hutang total: Rp 100.000
```

---

### 7. Pesanan/Draft

Kelola transaksi yang pending/draft.

#### Menu "Pesan"

Menampilkan semua transaksi yang:

- Belum dibayar
- Disimpan sebagai pesanan
- Masih dalam proses

**Info yang ditampilkan:**

- 👤 Nama & telepon pelanggan
- 💰 Total nilai pesanan
- 📦 Jumlah item
- 📅 Tanggal transaksi

#### Aksi

**Resume:**

1. Tap pesanan
2. Pilih **Resume/Lanjutkan**
3. Keranjang otomatis terisi dengan item pesanan
4. Lanjutkan ke pembayaran

**Hapus:**

1. Tap pesanan
2. Pilih **Hapus**
3. Konfirmasi penghapusan

> **Auto-Cleanup**: Pesanan otomatis dihapus setelah pembayaran selesai

---

### 8. Refund

Proses pengembalian barang/uang untuk transaksi yang sudah selesai.

#### A. Buat Refund (Untuk Transaksi Lunas)

1. **Akses Transaksi**
   - Buka **Daftar Transaksi**
   - Tap transaksi dengan status **Selesai**
   - Tap **Create Refund**

2. **Pilih Item**
   - Centang item yang akan di-refund
   - Set quantity per item
   - Minimal 1 item harus dipilih

3. **Atur Quantity**
   - Quantity refund ≤ quantity pembelian
   - Contoh: Beli 5, bisa refund 1-5 pcs

4. **Pilih Metode Refund**
   - 💵 Cash (Tunai)
   - 🏦 Transfer
   - 🔀 Cash & Transfer (campuran)

5. **Set Tanggal Refund**
   - Default: Hari ini
   - Bisa diubah sesuai kebutuhan

6. **Tambah Catatan** (opsional)
   - Alasan refund
   - Kondisi barang
   - Info tambahan

7. **Konfirmasi Refund**

**Hasil:**

- ✅ Record refund tersimpan
- 🔗 Link ke transaksi asli
- 📊 Data masuk ke laporan

#### B. Edit Transaksi (Untuk Transaksi Hutang)

Untuk transaksi dengan status **Outstanding/Hutang**:

1. Buka transaksi dari **Daftar Hutang**
2. Tap **Edit Transaction**
3. **Hapus item** yang tidak jadi dibeli
4. Sistem akan:
   - Hitung ulang total transaksi
   - Update jumlah hutang
   - Ubah status ke **Completed** jika lunas

---

### 9. Arus Kas

Catat pemasukan dan pengeluaran toko.

#### A. Tambah Arus Kas

1. **Tap tombol ➕**

2. **Isi Form:**
   - **Judul**: Nama transaksi (contoh: "Beli Stok Barang")
   - **Deskripsi**: Detail transaksi
   - **Jumlah**: Nominal uang
   - **Tipe**:
     - 📈 **MASUK** (Pemasukan)
     - 📉 **KELUAR** (Pengeluaran)
   - **Kategori**:
     - 💰 Sales (Penjualan)
     - 🛒 Expense (Pengeluaran)
     - 🔄 Transfer
     - 💼 Investment (Investasi)
     - 🏦 Loan (Pinjaman)
     - 📋 Other (Lainnya)
   - **Tanggal Transaksi**
   - **Catatan** (opsional)

3. **Tap Simpan**

#### B. Lihat Arus Kas

**Kartu Summary:**

- 📈 **Total Masuk**: Jumlah pemasukan
- 📉 **Total Keluar**: Jumlah pengeluaran
- 💵 **Net Amount**: Selisih (Masuk - Keluar)

**Daftar Arus Kas:**

- Infinite scroll pagination
- Indikator tipe (IN/OUT)
- Badge kategori
- Format mata uang
- Tampilan tanggal

#### C. Filter & Search

**Filter:**

- By Tipe (Masuk/Keluar)
- By Kategori
- By Rentang Tanggal

**Search:**

- Real-time search by judul/deskripsi

---

### 10. Laporan

Lihat performa penjualan dan analisis bisnis.

#### A. Ringkasan Penjualan

**Pilih Period:**

- 📅 Hari Ini
- 📅 Minggu Ini
- 📅 Bulan Ini

**Kartu Summary:**

- 🔢 **Total Transaksi**: Jumlah transaksi
- 💰 **Total Penjualan**: Revenue total
- 📦 **Item Terjual**: Total produk terjual
- 📈 **Rata-rata Transaksi**: Nilai rata-rata per transaksi

#### B. Chart Penjualan

**Bar Chart 7 Hari Terakhir:**

- Visual grafik penjualan harian
- Highlight hari ini
- Format K (ribu) / M (juta) untuk mata uang
- Mudah membaca tren

#### C. Top Products

**Ranking 5 Produk Terlaris:**

- 🥇 Peringkat 1-5 (Gold/Silver/Bronze medal)
- Jumlah terjual per produk
- Revenue per produk
- Persentase kontribusi

#### D. Transaksi Terbaru

- 4 transaksi terkini
- Info quick: ID, waktu, items, total, metode
- Link **"Lihat Semua"** ke daftar transaksi

#### E. Export (Coming Soon)

Fitur export laporan dalam format Excel/PDF

---

### 11. Printer Bluetooth

Cetak struk menggunakan thermal printer Bluetooth.

#### A. Setup Printer

**Hardware yang Didukung:**

- ✅ ESC/POS thermal printer
- ✅ Thermal paper 58mm
- ✅ Bluetooth SPP connection

**Pairing Printer:**

1. **Nyalakan Printer**
   - Pastikan printer menyala
   - Pastikan kertas thermal terpasang

2. **Aktifkan Bluetooth Printer**
   - Tekan tombol Bluetooth di printer
   - Indikator Bluetooth menyala

3. **Pairing via Android Settings**
   - Buka **Settings** → **Bluetooth**
   - Scan perangkat
   - Tap nama printer (contoh: "RPP02N", "BlueTooth Printer", dll)
   - Masukkan PIN jika diminta (biasanya: 0000, 1234, atau 1111)
   - Tunggu sampai status **"Paired"**

4. **Connect di Aplikasi SUN POS**
   - Buka **Settings/Pengaturan Printer**
   - Tap **Scan Printers**
   - Pilih printer yang sudah di-pair
   - Tap **Connect**
   - Status akan berubah **"Connected"**

#### B. Cetak Struk

**Dari Halaman Receipt:**

1. Selesaikan transaksi
2. Di halaman struk, tap tombol **🖨️ Cetak**
3. Pastikan printer terhubung
4. Struk akan tercetak otomatis

**Format Struk:**

- 📄 Header: Logo & info toko
- 📋 Daftar item detail dengan harga
- 💰 Summary: Subtotal, diskon, total
- 💳 Metode pembayaran
- 💵 Bayar & kembalian (jika cash)
- 👤 Kasir & tanggal
- 📝 Footer: Thank you message
- 🔢 Barcode/QR (opsional)

#### C. Test Print

**Untuk testing:**

1. Buka **Pengaturan Printer**
2. Tap **Test Print**
3. Printer akan cetak sample receipt

#### D. Troubleshooting Printer

**Printer tidak terdeteksi:**

- ✅ Pastikan Bluetooth HP aktif
- ✅ Pastikan printer sudah di-pair di Android Settings
- ✅ Restart printer
- ✅ Scan ulang di aplikasi

**Struk tidak keluar:**

- ✅ Cek koneksi printer (status Connected)
- ✅ Pastikan kertas thermal terpasang
- ✅ Cek baterai printer
- ✅ Test print dulu
- ✅ Reconnect printer

**Hasil cetak tidak jelas:**

- ✅ Ganti kertas thermal baru
- ✅ Bersihkan head printer
- ✅ Charge baterai printer (low battery = hasil pudar)

**Printer sering disconnect:**

- ✅ Dekatkan HP dan printer (max 10 meter)
- ✅ Hindari interferensi Bluetooth lain
- ✅ Forget & pair ulang di Settings
- ✅ Update firmware printer (jika ada)

---

## Tips & Trik

### 🚀 Produktivitas

1. **Gunakan Search & Filter**
   - Hemat waktu mencari produk/transaksi/pelanggan
   - Manfaatkan quick filters

2. **Simpan Pelanggan Favorit**
   - Buat grup pelanggan untuk pricing otomatis
   - Hemat waktu tidak perlu edit harga manual

3. **Manfaatkan Draft Transaction**
   - Simpan pesanan yang belum siap bayar
   - Resume kapan saja

4. **Monitor Dashboard**
   - Cek performa harian
   - Lihat tren penjualan

5. **Gunakan Keyboard Shortcuts** (jika ada)
   - Navigasi lebih cepat

### 💡 Best Practices

1. **Atur Stok Secara Berkala**
   - Update stok produk
   - Hindari overselling

2. **Catat Semua Arus Kas**
   - Transparansi keuangan
   - Laporan akurat

3. **Follow-up Hutang**
   - Set reminder date
   - Hubungi pelanggan mendekati jatuh tempo

4. **Review Laporan Rutin**
   - Analisis top products
   - Strategi promosi

5. **Backup Data**
   - Sync dengan server secara rutin
   - Hindari kehilangan data

### ⚡ Shortcut Workflows

**Fast Transaction:**

```
Dashboard → Transaksi Baru →
Scan/Pilih Produk → Tambah →
Bayar → Pilih Metode → Selesai
```

**Bayar Hutang Cepat:**

```
Menu Hutang → Pilih Pelanggan →
FAB Bayar → Input Nominal →
Pilih Metode → Konfirmasi
```

**Cek Stok Produk:**

```
Menu Produk → Search Nama →
Tap Produk → Lihat Varian & Stok
```

---

## FAQ

### ❓ Pertanyaan Umum

**Q: Apakah bisa menggunakan aplikasi offline?**
A: Fitur tertentu memerlukan koneksi internet (sync data, API products). Namun transaksi lokal bisa dilakukan offline dan disync saat ada koneksi.

**Q: Bagaimana jika salah input transaksi?**
A:

- Untuk transaksi **Lunas**: Buat refund
- Untuk transaksi **Hutang**: Edit transaksi

**Q: Apakah bisa print struk tanpa printer Bluetooth?**
A: Ya, bisa share/screenshot struk digital atau print via device lain.

**Q: Bagaimana cara mengubah harga produk?**
A: Saat ini harga produk dikelola dari server/database. Namun bisa edit harga per item saat transaksi di POS.

**Q: Pelanggan bayar hutang lebih dari yang terutang, bagaimana?**
A: Sistem akan otomatis hitung dan lunas-kan semua transaksi. Lebihnya bisa dicatat sebagai deposit/saldo (fitur coming soon) atau kembalian tunai.

**Q: Apakah ada backup otomatis?**
A: Data tersync dengan server secara real-time saat ada koneksi internet.

**Q: Bagaimana cara menambah produk baru?**
A: Saat ini penambahan produk dilakukan melalui admin panel/server. Hubungi administrator.

**Q: Bisa cetak laporan?**
A: Fitur export laporan (Excel/PDF) sedang dalam pengembangan. Saat ini bisa screenshot laporan.

**Q: Apakah mendukung multi-currency?**
A: Saat ini hanya Rupiah (IDR). Multi-currency dalam roadmap future.

**Q: Ada batasan jumlah transaksi/pelanggan?**
A: Tidak ada batasan. Infinite scroll mendukung data dalam jumlah besar.

### 🔧 Troubleshooting

**Aplikasi lemot/lag:**

- Bersihkan cache aplikasi
- Restart aplikasi
- Pastikan cukup storage di HP
- Update ke versi terbaru

**Data tidak muncul:**

- Cek koneksi internet
- Pull-to-refresh
- Logout dan login kembali

**Struk tidak tercetak:**

- Lihat bagian [Troubleshooting Printer](#d-troubleshooting-printer)

**Lupa password:**

- Hubungi administrator untuk reset password

**Error saat transaksi:**

- Screenshot error message
- Coba lagi
- Jika tetap gagal, hubungi support

---

## 📞 Dukungan

Jika mengalami kendala atau ada pertanyaan lebih lanjut:

- 📧 **Email**: [email support]
- 📱 **WhatsApp**: [nomor support]
- 🌐 **Website**: [website toko]

---

## 📝 Catatan Versi

**Versi**: 1.0.31+32

**Flutter SDK**: 3.8.0-133.0.dev

---

## 📄 Lisensi

© 2026 SUN POS. All rights reserved.

---

**Selamat menggunakan SUN POS! 🎉**

Semoga aplikasi ini membantu meningkatkan efisiensi dan produktivitas bisnis Anda.
