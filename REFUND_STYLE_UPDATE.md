# Update Style Refund Creation Page

## 📋 Ringkasan

Tampilan halaman Create Refund telah diperbarui untuk mengikuti design system yang konsisten dengan aplikasi, terutama mengikuti style dari Payment Confirmation Page.

## 🎨 Perubahan Style

### 1. **Color Scheme Update**

**Before:**

- AppBar: Blue
- Cards: Default white dengan minimal styling
- Buttons: Blue primary, Orange outline
- Total refund: Blue background

**After:**

- AppBar: Green shade 600 (konsisten dengan tema refund/success)
- Cards: White dengan elevation & border radius 12px
- Selected items: Green shade 300 border, Green shade 50 background
- Total refund: Green shade 50 background dengan green shade 200 border
- Buttons: Green shade 600 dengan icon
- Input focus: Green shade 600 border

### 2. **Transaction Info Card**

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Icon badge dengan green background
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_long, color: Colors.white, size: 20),
        ),
        // Transaction info dengan divider
        // Total amount dengan bold styling
      ],
    ),
  ),
)
```

**Fitur:**

- Icon badge container dengan green background
- Divider untuk memisahkan sections
- Typography hierarchy yang jelas
- Spacing konsisten (12-16px)

### 3. **Item Selection Cards**

**Before:**

- CheckboxListTile dengan default styling
- Minimal visual feedback
- Quantity input inline tanpa highlight

**After:**

```dart
Card(
  elevation: 1,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: _selectedItems[detail.id] == true
          ? Colors.green.shade300
          : Colors.grey.shade200,
      width: _selectedItems[detail.id] == true ? 2 : 1,
    ),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => toggleSelection(),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Custom checkbox dengan green theme
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade600 : Colors.white,
              border: Border.all(...),
              borderRadius: BorderRadius.circular(6),
            ),
            child: selected ? Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          // Product details dengan badge quantity
          // Collapsible quantity input
        ],
      ),
    ),
  ),
)
```

**Fitur:**

- Dynamic border color & width berdasarkan selection
- InkWell untuk tap effect di seluruh card
- Custom checkbox dengan green fill animation
- Blue badge untuk quantity (konsisten dengan payment page)
- Collapsible quantity input dengan green theme
- Max limit indicator

### 4. **Quantity Input Container**

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.green.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.green.shade200),
  ),
  child: Row(
    children: [
      Text('Jumlah Refund:', style: TextStyle(fontWeight: w600, color: green.shade800)),
      // Styled TextFormField dengan center alignment
      // Max indicator
    ],
  ),
)
```

**Fitur:**

- Green themed container untuk highlight
- Center-aligned input dengan bold font
- Custom borders untuk setiap state (enabled/focused/error)
- Max limit di kanan untuk guidance

### 5. **Total Refund Card**

**Before:**

- Simple card dengan blue background
- Minimal styling

**After:**

```dart
Card(
  elevation: 2,
  color: Colors.green.shade50,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Colors.green.shade200, width: 2),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        // Icon badge
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.calculate, color: Colors.white, size: 16),
        ),
        // Title & Amount
        Text('Total Refund', fontWeight: bold, color: green.shade900),
        Text(amount, fontSize: 20, fontWeight: bold, color: green.shade800),
      ],
    ),
  ),
)
```

**Fitur:**

- Prominent dengan elevation & border
- Icon badge untuk visual context
- Large bold amount (20px)
- Color-coded dengan green theme

### 6. **Form Inputs Styling**

**Dropdown (Metode Refund):**

```dart
DropdownButtonFormField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade600, width: 2),
    ),
    prefixIcon: Icon(Icons.payment, color: Colors.green.shade600),
    suffixIcon: Icon(Icons.arrow_drop_down),
  ),
)
```

**Amount Fields:**

```dart
TextFormField(
  style: TextStyle(fontSize: 16, fontWeight: w600),
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade600, width: 2),
    ),
    prefixIcon: Icon(Icons.attach_money, color: Colors.green.shade600),
    prefixText: 'Rp ',
    prefixStyle: TextStyle(fontSize: 16, fontWeight: w600, color: Colors.black87),
  ),
)
```

**Date Picker:**

```dart
InputDecorator(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIcon: Icon(Icons.calendar_today, color: Colors.green.shade600),
    suffixIcon: Icon(Icons.arrow_drop_down),
  ),
  child: Text(DateFormat('dd MMM yyyy').format(date), fontWeight: w600),
)
```

**Notes:**

```dart
TextFormField(
  maxLines: 3,
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade600, width: 2),
    ),
    prefixIcon: Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: Icon(Icons.note_add, color: Colors.green.shade600),
    ),
    hintText: 'Tambahkan catatan untuk refund ini...',
  ),
)
```

### 7. **Submit Button**

**Before:**

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(vertical: 16),
  ),
  child: Text('Submit Refund'),
)
```

**After:**

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade600,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.check_circle_outline, size: 22),
      SizedBox(width: 8),
      Text('Submit Refund', fontSize: 16, fontWeight: bold, letterSpacing: 0.5),
    ],
  ),
)

// Container dengan shadow
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: button,
)
```

**Fitur:**

- Green theme konsisten
- Icon + Text layout
- Elevated container dengan subtle shadow
- Fixed height (56px) untuk consistency
- Disabled state dengan grey color
- Loading indicator (24x24) dengan white color

## 📊 Design Consistency

### Spacing System

- **Card padding:** 16px
- **Section spacing:** 20-24px
- **Item spacing:** 12-16px
- **Icon spacing:** 8-12px dari text
- **Border radius:** 12px untuk cards, 8px untuk inner elements, 6px untuk badges

### Typography

- **Headings:** 16px, bold (fontWeight.bold), black87
- **Body:** 14-16px, regular/w600
- **Labels:** 14px, w600, grey.shade700/green.shade800
- **Amounts:** 16-20px, bold, green.shade800
- **Hints:** 12-13px, regular, grey.shade600

### Color Palette

- **Primary Green:** shade 600 (#43A047)
- **Background Green:** shade 50 (#E8F5E9)
- **Border Green:** shade 200-300 (#A5D6A7 - #81C784)
- **Text Green:** shade 800-900 (#2E7D32 - #1B5E20)
- **Neutral Grey:** shade 200-700
- **White:** #FFFFFF
- **Black:** black87

### Icon System

- **Size:** 16px (badges), 20px (headers), 22px (buttons)
- **Color:** white (on colored bg), green.shade600 (on white bg)
- **Badges:** Container dengan padding 6-8px, border radius 6-8px

## ✅ Checklist Perubahan

- [x] AppBar color: Blue → Green shade 600
- [x] Transaction card: Icon badge dengan green theme
- [x] Item cards: Dynamic border & custom checkbox
- [x] Quantity input: Green themed container
- [x] Total refund: Prominent card dengan green theme
- [x] Dropdown: Styled dengan prefix icon
- [x] Amount fields: Icon prefix & custom styling
- [x] Date picker: Styled InputDecorator
- [x] Notes: Multi-line dengan hint text
- [x] Submit button: Green theme dengan icon
- [x] Container shadows: Subtle elevation
- [x] Border radius: Konsisten 12px
- [x] Typography: Clear hierarchy
- [x] Spacing: Consistent system

## 🎯 Result

Tampilan Create Refund Page sekarang:

1. ✅ Konsisten dengan design system aplikasi
2. ✅ Mengikuti pattern dari Payment Confirmation Page
3. ✅ Visual hierarchy yang jelas
4. ✅ Color coding yang meaningful (green = refund/success)
5. ✅ Interactive elements dengan feedback jelas
6. ✅ Responsive dan user-friendly
7. ✅ Professional dan polished appearance

---

**Updated:** 10 Oktober 2025  
**Status:** ✅ Completed
