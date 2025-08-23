import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../data/models/customer.dart';
import '../widgets/edit_customer_dialog.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;
  final Customer? customer; // Optional initial customer data

  const CustomerDetailPage({
    super.key,
    required this.customerId,
    this.customer,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load customer detail when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.customer == null) {
        context.read<CustomerProvider>().getCustomerDetail(widget.customerId);
      } else {
        // Set initial customer data if provided
        context.read<CustomerProvider>().clearCustomerDetail();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          final customer = customerProvider.customerDetail ?? widget.customer;

          if (customerProvider.isLoadingDetail && customer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (customerProvider.errorMessage != null && customer == null) {
            return _buildErrorWidget(customerProvider);
          }

          if (customer == null) {
            return _buildNotFoundWidget();
          }

          return RefreshIndicator(
            onRefresh: _refreshCustomerDetail,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Customer Info Card
                  _buildCustomerInfoCard(customer),

                  const SizedBox(height: 16),

                  // Customer Stats Card
                  _buildCustomerStatsCard(customer),

                  const SizedBox(height: 16),

                  // Action Buttons
                  _buildActionButtons(customer, customerProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          final customer = provider.customerDetail ?? widget.customer;
          if (customer == null) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _showEditDialog(customer),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.edit),
          );
        },
      ),
    );
  }

  Widget _buildCustomerInfoCard(Customer customer) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Customer Name
            Text(
              customer.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Customer Phone
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  customer.phone,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _callCustomer(customer.phone),
                  icon: const Icon(Icons.call, color: Colors.green),
                  tooltip: 'Call Customer',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Customer ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${customer.id}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStatsCard(Customer customer) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Created Date
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              value: _formatDate(customer.createdAt),
            ),

            const SizedBox(height: 12),

            // Last Updated
            _buildInfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDate(customer.updatedAt),
            ),

            const SizedBox(height: 12),

            // Customer Age (days since created)
            _buildInfoRow(
              icon: Icons.person,
              label: 'Customer Age',
              value:
                  '${DateTime.now().difference(customer.createdAt).inDays} days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Customer customer, CustomerProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        provider.isUpdating
                            ? null
                            : () => _showEditDialog(customer),
                    icon:
                        provider.isUpdating
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.edit),
                    label: Text(
                      provider.isUpdating ? 'Updating...' : 'Edit Customer',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(customer),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _selectCustomerForCart(customer),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Select for Cart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.blue.shade300),
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(CustomerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load customer',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshCustomerDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Customer Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The customer you are looking for does not exist.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshCustomerDetail() async {
    await context.read<CustomerProvider>().getCustomerDetail(widget.customerId);
  }

  void _handleMenuAction(String action) {
    final customer =
        context.read<CustomerProvider>().customerDetail ?? widget.customer;
    if (customer == null) return;

    switch (action) {
      case 'edit':
        _showEditDialog(customer);
        break;
      case 'delete':
        _showDeleteDialog(customer);
        break;
    }
  }

  Future<void> _showEditDialog(Customer customer) async {
    final updatedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => EditCustomerDialog(customer: customer),
    );

    if (updatedCustomer != null && mounted) {
      // Refresh customer detail to show updated data
      await _refreshCustomerDetail();
    }
  }

  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this customer?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${customer.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'Phone: ${customer.phone}',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              Consumer<CustomerProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed:
                        provider.isLoading
                            ? null
                            : () => _deleteCustomer(customer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        provider.isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Delete'),
                  );
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final success = await context.read<CustomerProvider>().deleteCustomer(
      customer.id,
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog

      if (success) {
        Navigator.of(context).pop(); // Go back to previous page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} has been deleted'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${customer.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _callCustomer(String phone) {
    // Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _selectCustomerForCart(Customer customer) {
    // Implement cart selection functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customer.name} selected for cart'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
