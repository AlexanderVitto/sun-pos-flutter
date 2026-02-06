import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../data/models/customer.dart';

class EditCustomerDialog extends StatefulWidget {
  final Customer customer;

  const EditCustomerDialog({super.key, required this.customer});

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Customer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Customer Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          radius: 20,
                          child: Text(
                            widget.customer.name.isNotEmpty
                                ? widget.customer.name[0].toUpperCase()
                                : 'C',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editing Customer ID: ${widget.customer.id}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              'Created: ${_formatDate(widget.customer.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter customer name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter customer name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: '+62812345678',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\-\s\(\)]'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }

                      final phoneRegex = RegExp(r'^\+?[0-9\-\s\(\)]{8,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid phone number';
                      }

                      // Check if phone already exists (excluding current customer)
                      if (value.trim() != widget.customer.phone) {
                        if (customerProvider.isCustomerExistsByPhone(
                          value.trim(),
                        )) {
                          return 'Customer with this phone already exists';
                        }
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Helper text
                  Text(
                    'Use international format (e.g., +62812345678)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Changes Summary
                  if (_hasChanges())
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        border: Border.all(color: Colors.amber[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.amber[700],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Changes to be saved:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_nameController.text.trim() !=
                              widget.customer.name)
                            Text(
                              'Name: "${widget.customer.name}" → "${_nameController.text.trim()}"',
                              style: TextStyle(
                                color: Colors.amber[700],
                                fontSize: 12,
                              ),
                            ),
                          if (_phoneController.text.trim() !=
                              widget.customer.phone)
                            Text(
                              'Phone: "${widget.customer.phone}" → "${_phoneController.text.trim()}"',
                              style: TextStyle(
                                color: Colors.amber[700],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Error message
                  if (customerProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customerProvider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting || customerProvider.isUpdating
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed:
                            _isSubmitting ||
                                customerProvider.isUpdating ||
                                !_hasChanges()
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: customerProvider.isUpdating
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Updating...'),
                                ],
                              )
                            : const Text('Update Customer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasChanges() {
    return _nameController.text.trim() != widget.customer.name ||
        _phoneController.text.trim() != widget.customer.phone;
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges()) return;

    setState(() => _isSubmitting = true);

    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      // Clear previous errors
      customerProvider.clearError();

      final updatedCustomer = await customerProvider.updateCustomer(
        customerId: widget.customer.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (updatedCustomer != null) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Customer "${updatedCustomer.name}" updated successfully',
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Close dialog and return the updated customer
          Navigator.of(context).pop(updatedCustomer);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to update customer: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
