# Cash Flows Feature Documentation

## 📋 Overview

Implementasi lengkap untuk mengelola Cash Flows (arus kas) pada sistem POS. Fitur ini memungkinkan pengguna untuk membuat dan melihat catatan cash flows dengan menggunakan API endpoint yang telah disediakan.

## 🏗️ Architecture

### 1. Data Models

- **CashFlow** (`lib/features/cash_flows/data/models/cash_flow.dart`)

  - Model utama untuk merepresentasikan data cash flow
  - Properties: id, storeId, title, description, amount, type, category, transactionDate, notes, createdAt, updatedAt
  - Helper methods: formattedAmount, typeIcon, typeColor

- **CreateCashFlowRequest** (`lib/features/cash_flows/data/models/create_cash_flow_request.dart`)

  - Model untuk request pembuatan cash flow baru
  - Properties: storeId, title, description, amount, type, category, transactionDate, notes
  - Method: toFormData() untuk multipart/form-data, validate() untuk validasi

- **CashFlowResponse Models** (`lib/features/cash_flows/data/models/cash_flow_response.dart`)
  - CreateCashFlowResponse: untuk response create cash flow
  - CashFlowListResponse: untuk response list cash flows dengan pagination
  - PaginationMeta: untuk data pagination

### 2. API Service

- **CashFlowApiService** (`lib/features/cash_flows/data/services/cash_flow_api_service.dart`)
  - Handle komunikasi dengan API endpoints
  - Methods:
    - `createCashFlow()` - POST dengan multipart/form-data
    - `getCashFlows()` - GET dengan query parameters untuk filtering
  - Error handling untuk berbagai HTTP status codes

### 3. State Management

- **CashFlowProvider** (`lib/features/cash_flows/providers/cash_flow_provider.dart`)
  - Manage state untuk cash flows
  - Features:
    - Load cash flows dengan pagination
    - Create new cash flow
    - Filter by type, category, date range
    - Calculate totals (in, out, net)
    - Pull to refresh

### 4. UI Components

- **CashFlowsPage** (`lib/features/cash_flows/presentation/pages/cash_flows_page.dart`)

  - Halaman utama untuk melihat daftar cash flows
  - Features:
    - Summary cards (Total Masuk, Keluar, Net Amount)
    - Filter dan search
    - Infinite scroll pagination
    - Pull to refresh

- **AddCashFlowPage** (`lib/features/cash_flows/presentation/pages/add_cash_flow_page.dart`)

  - Halaman untuk menambah cash flow baru
  - Form dengan validasi lengkap
  - Date picker dan dropdown kategori

- **CashFlowCard** (`lib/features/cash_flows/presentation/widgets/cash_flow_card.dart`)

  - Widget untuk menampilkan item cash flow
  - Responsive design dengan informasi lengkap

- **CashFlowFilterDialog** (`lib/features/cash_flows/presentation/widgets/cash_flow_filter_dialog.dart`)
  - Dialog untuk filter cash flows
  - Filter by type, category, date range

## 📱 Features

### 1. Create Cash Flow

- **Endpoint**: `POST https://sfpos.app/api/v1/cash-flows`
- **Content-Type**: `multipart/form-data`
- **Fields**:
  - `store_id`: ID toko (default: 1)
  - `title`: Judul cash flow
  - `description`: Deskripsi
  - `amount`: Jumlah uang
  - `type`: "in" atau "out"
  - `category`: Kategori (sales, expense, transfer, etc.)
  - `transaction_date`: Tanggal dalam format YYYY-MM-DD
  - `notes`: Catatan (optional)

### 2. View Cash Flows

- **Endpoint**: `GET https://sfpos.app/api/v1/cash-flows`
- **Query Parameters**:
  - `store_id`: ID toko (default: 1)
  - `type`: Filter by type ("in" atau "out")
  - `category`: Filter by category
  - `date_from`: Tanggal mulai (YYYY-MM-DD)
  - `date_to`: Tanggal akhir (YYYY-MM-DD)
  - `per_page`: Items per page (default: 15)
  - `page`: Nomor halaman

### 3. Filtering & Search

- Filter by type (Cash In / Cash Out)
- Filter by category (Sales, Expense, Transfer, etc.)
- Date range filtering
- Real-time filter application

### 4. Summary & Analytics

- Total Cash In
- Total Cash Out
- Net Amount (Cash In - Cash Out)
- Visual indicators untuk flow positif/negatif

## 🎨 UI/UX Features

- **Responsive Design**: Bekerja di berbagai ukuran layar
- **Material Design 3**: Modern UI components
- **Pull to Refresh**: Swipe down untuk refresh data
- **Infinite Scroll**: Load more otomatis saat scroll ke bawah
- **Error Handling**: User-friendly error messages
- **Loading States**: Loading indicators yang konsisten
- **Empty States**: Pesan informatif saat tidak ada data

## 🚀 Navigation

### Routes

- `/cash-flows`: Halaman utama cash flows
- `/cash-flows/add`: Halaman tambah cash flow baru

### Dashboard Integration

Cash Flows sudah terintegrasi dengan dashboard utama dengan 2 tombol quick access:

- **Cash Flows**: Akses ke halaman utama
- **Tambah Cash Flow**: Direct access untuk menambah cash flow baru

## 🔧 Usage Examples

### Membuat Cash Flow Baru

```dart
final request = CreateCashFlowRequest(
  storeId: 1,
  title: 'Penjualan Harian',
  description: 'Penjualan produk minuman dan makanan ringan',
  amount: 500000,
  type: 'in',
  category: 'sales',
  transactionDate: '2025-08-10',
  notes: 'Penjualan lancar hari ini',
);

final success = await context.read<CashFlowProvider>().createCashFlow(request);
```

### Load Cash Flows dengan Filter

```dart
final provider = context.read<CashFlowProvider>();
provider.setTypeFilter('in');
provider.setCategoryFilter('sales');
provider.setDateRangeFilter('2025-08-01', '2025-08-31');
```

## 🎯 Categories Supported

1. **Sales** (Penjualan) - Cash dari penjualan produk
2. **Expense** (Pengeluaran) - Biaya operasional
3. **Transfer** (Transfer) - Transfer antar akun/toko
4. **Investment** (Investasi) - Investasi bisnis
5. **Loan** (Pinjaman) - Pinjaman usaha
6. **Tax** (Pajak) - Pembayaran pajak
7. **Other** (Lainnya) - Kategori lain

## 📊 State Management

Provider menggunakan ChangeNotifier pattern dengan fitur:

- State persistence selama aplikasi berjalan
- Automatic refresh saat filter berubah
- Error state management
- Loading state untuk UX yang baik

## 🔒 Security

- Bearer token authentication
- Input validation di client dan server
- Secure storage untuk token
- Error handling untuk unauthorized access

## 🚦 Error Handling

- Network errors
- Authentication errors (401)
- Validation errors (422)
- Server errors (500+)
- Connection timeouts
- User-friendly error messages

## 📱 Testing

Untuk testing fitur cash flows, bisa menggunakan demo app:

```bash
flutter run lib/cash_flow_demo.dart
```

## 🔄 Integration

Cash Flows feature sudah fully integrated dengan:

- Main app navigation
- Dashboard quick actions
- Provider system
- Authentication system
- Error handling system

Fitur ini siap digunakan dan dapat diakses melalui dashboard utama aplikasi.
