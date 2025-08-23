import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cash_flow_provider.dart';

class CashFlowFilterDialog extends StatefulWidget {
  const CashFlowFilterDialog({super.key});

  @override
  State<CashFlowFilterDialog> createState() => _CashFlowFilterDialogState();
}

class _CashFlowFilterDialogState extends State<CashFlowFilterDialog> {
  late String? _selectedType;
  late String? _selectedCategory;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CashFlowProvider>();
    _selectedType = provider.selectedType;
    _selectedCategory = provider.selectedCategory;
    _dateFrom =
        provider.dateFrom != null
            ? DateTime.tryParse(provider.dateFrom!)
            : null;
    _dateTo =
        provider.dateTo != null ? DateTime.tryParse(provider.dateTo!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Filter Cash Flows',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Type Filter
            const Text(
              'Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildTypeFilter(),

            const SizedBox(height: 20),

            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildCategoryFilter(),

            const SizedBox(height: 20),

            // Date Range Filter
            const Text(
              'Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDateRangeFilter(),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          label: 'All',
          selected: _selectedType == null,
          onSelected: (_) => setState(() => _selectedType = null),
        ),
        _buildFilterChip(
          label: 'Cash In',
          selected: _selectedType == 'in',
          onSelected: (_) => setState(() => _selectedType = 'in'),
          icon: Icons.arrow_upward,
          color: Colors.green,
        ),
        _buildFilterChip(
          label: 'Cash Out',
          selected: _selectedType == 'out',
          onSelected: (_) => setState(() => _selectedType = 'out'),
          icon: Icons.arrow_downward,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final provider = context.read<CashFlowProvider>();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          label: 'All',
          selected: _selectedCategory == null,
          onSelected: (_) => setState(() => _selectedCategory = null),
        ),
        ...provider.categories.map(
          (category) => _buildFilterChip(
            label: provider.getFormattedCategory(category),
            selected: _selectedCategory == category,
            onSelected: (_) => setState(() => _selectedCategory = category),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(isFromDate: true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFrom != null
                              ? DateFormat('dd MMM yyyy').format(_dateFrom!)
                              : 'Select date',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(isFromDate: false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateTo != null
                              ? DateFormat('dd MMM yyyy').format(_dateTo!)
                              : 'Select date',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_dateFrom != null || _dateTo != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  () => setState(() {
                    _dateFrom = null;
                    _dateTo = null;
                  }),
              child: const Text('Clear dates'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    IconData? icon,
    Color? color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color ?? Colors.blue.shade600,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            selected ? (color ?? Colors.blue.shade600) : Colors.grey.shade300,
      ),
    );
  }

  Future<void> _selectDate({required bool isFromDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFromDate
              ? (_dateFrom ?? DateTime.now())
              : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = picked;
          // If from date is after to date, clear to date
          if (_dateTo != null && picked.isAfter(_dateTo!)) {
            _dateTo = null;
          }
        } else {
          _dateTo = picked;
          // If to date is before from date, clear from date
          if (_dateFrom != null && picked.isBefore(_dateFrom!)) {
            _dateFrom = null;
          }
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _dateFrom = null;
      _dateTo = null;
    });
  }

  void _applyFilters() {
    final provider = context.read<CashFlowProvider>();

    // Set individual filters
    if (provider.selectedType != _selectedType) {
      provider.setTypeFilter(_selectedType);
    }

    if (provider.selectedCategory != _selectedCategory) {
      provider.setCategoryFilter(_selectedCategory);
    }

    // Set date range filter
    final dateFromString =
        _dateFrom != null ? DateFormat('yyyy-MM-dd').format(_dateFrom!) : null;
    final dateToString =
        _dateTo != null ? DateFormat('yyyy-MM-dd').format(_dateTo!) : null;

    if (provider.dateFrom != dateFromString ||
        provider.dateTo != dateToString) {
      provider.setDateRangeFilter(dateFromString, dateToString);
    }

    Navigator.pop(context);
  }
}
