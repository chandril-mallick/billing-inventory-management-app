import 'package:flutter/material.dart';
import '../../database/db_manager.dart'; // Assuming this path is correct

class Suppliers extends StatefulWidget {
  const Suppliers({super.key});

  @override
  _SuppliersState createState() => _SuppliersState();
}

class _SuppliersState extends State<Suppliers> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  List<Map<String, dynamic>> _suppliers = []; // List to hold supplier data

  @override
  void initState() {
    super.initState();
    _loadSuppliers(); // Load suppliers from the database on init
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Loads all suppliers from the database and updates the state.
  void _loadSuppliers() async {
    try {
      final suppliers = await DatabaseHelper.instance.getAllSuppliers();
      setState(() {
        _suppliers = suppliers;
      });
    } catch (e) {
      _showSnackBar('Failed to load suppliers: $e');
    }
  }

  /// Shows a confirmation dialog before deleting a supplier.
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Supplier"), // Updated title
          content: const Text("Are you sure you want to delete this supplier? This action cannot be undone."), // Updated content
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _deleteSupplier(id); // Delete the supplier
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Deletes a supplier by their ID and refreshes the data.
  Future<void> _deleteSupplier(int id) async {
    try {
      await DatabaseHelper.instance.deleteSupplierById(id);
      _loadSuppliers(); // Refresh the data
      _showSnackBar('Supplier ID $id deleted successfully.');
    } catch (e) {
      _showSnackBar('Failed to delete supplier: $e');
    }
  }

  /// Shows a dialog for adding a new supplier.
  void _showAddSupplierDialog() {
    // Clear fields before showing the dialog for a new entry
    _clearFields();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Determine if the screen is considered 'mobile' for dialog width
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;

        return AlertDialog(
          title: const Text('Add New Supplier'),
          content: SizedBox(
            width: isMobile ? screenWidth * 0.8 : 400, // Responsive width for dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Supplier ID - non-editable, auto-generated based on current list size
                  TextField(
                    controller: TextEditingController(
                        text: (_suppliers.length + 1).toString()),
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Supplier ID',
                      hintText: 'Auto-generated',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),

                  // Phone
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),

                  // Address
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3, // Allow multiple lines for address
                  ),
                  const SizedBox(height: 10),

                  // Balance (I Have to Pay)
                  TextField(
                    controller: _balanceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'I Have to Pay',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate input fields before saving
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _phoneController.text.isEmpty ||
                    _addressController.text.isEmpty) {
                  _showSnackBar('Please fill all required fields.');
                  return;
                }

                final supplier = {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'address': _addressController.text,
                  'balance': double.tryParse(_balanceController.text) ?? 0.0,
                };

                try {
                  await DatabaseHelper.instance.addSupplier(supplier);
                  _clearFields(); // Clear fields after saving
                  _loadSuppliers(); // Reload suppliers from the database
                  Navigator.of(context).pop();
                  _showSnackBar('Supplier added successfully!');
                } catch (e) {
                  _showSnackBar('Failed to add supplier: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Function to clear all input fields after saving.
  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _balanceController.clear();
  }

  /// Helper function to show a SnackBar message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Determine if the screen is considered 'mobile' based on width
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // Adjust container width based on screen size
            width: isMobile ? screenWidth * 0.95 : screenWidth * 0.8,
            height: screenHeight * 0.8, // Maintain height
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200, // Changed shadow color
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Allows horizontal scrolling for the table
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allows vertical scrolling for the entire content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Supplier Data',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32, // Responsive font size for title
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey), // Changed color to grey
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ConstrainedBox(
                          // Ensure a minimum width for the table to maintain readability
                          constraints: BoxConstraints(minWidth: isMobile ? 700.0 : screenWidth * 0.7),
                          child: Table(
                            border: TableBorder.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                            // Use FlexColumnWidth for responsive column sizing
                            columnWidths: const {
                              0: FlexColumnWidth(0.8), // ID
                              1: FlexColumnWidth(1.5), // Name
                              2: FlexColumnWidth(2.0), // Email
                              3: FlexColumnWidth(1.2), // Phone
                              4: FlexColumnWidth(2.0), // Address
                              5: FlexColumnWidth(1.2), // I Have to Pay
                              6: IntrinsicColumnWidth(), // Action (delete button)
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                ),
                                children: [
                                  _TableHeaderCell('ID', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Name', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Email', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Phone', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Address', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('I Have to Pay', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Action', fontSize: isMobile ? 14 : 18),
                                ],
                              ),
                              // Data Rows
                              for (var supplier in _suppliers)
                                TableRow(
                                  children: [
                                    _TableCell(supplier['id'].toString(), fontSize: isMobile ? 12 : 16),
                                    _TableCell(supplier['name'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(supplier['email'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(supplier['phone'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(supplier['address'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(
                                        '\u{20B9}${supplier['balance']?.toStringAsFixed(2) ?? '0.00'}',
                                        fontSize: isMobile ? 12 : 16),
                                    Center( // Center the delete icon
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          if (supplier['id'] != null) {
                                            _confirmDelete(supplier['id']);
                                          } else {
                                            _showSnackBar('Error: Cannot delete record without a Supplier ID');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: isMobile ? 120 : 150, // Responsive width for the button
        height: isMobile ? 40 : 50, // Responsive height for the button
        child: FloatingActionButton(
          backgroundColor: Colors.yellow.shade600,
          onPressed: _showAddSupplierDialog,
          tooltip: 'Add Supplier',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Add rounded corners
          child: Center(
            child: Text(
              "Add Supplier",
              style: TextStyle(
                fontSize: isMobile ? 12 : 15, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Ensure text color is visible
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable widget for table header cells.
class _TableHeaderCell extends StatelessWidget {
  final String text;
  final double fontSize;
  const _TableHeaderCell(this.text, {this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center, // Centered text
      ),
    );
  }
}

/// Reusable widget for standard table data cells.
class _TableCell extends StatelessWidget {
  final String text;
  final double fontSize;
  const _TableCell(this.text, {this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: fontSize),
        textAlign: TextAlign.center, // Centered text
      ),
    );
  }
}
