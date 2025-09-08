import 'package:flutter/material.dart';
import '../../database/db_manager.dart'; // Assuming this path is correct

class Purchases extends StatefulWidget {
  const Purchases({super.key});

  @override
  _PurchasesState createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> {
  List<Map<String, dynamic>> purchasesData = [];

  @override
  void initState() {
    super.initState();
    _loadPurchasesFromDatabase();
  }

  /// Loads all purchase orders from the database and updates the state.
  Future<void> _loadPurchasesFromDatabase() async {
    try {
      final purchases = await DatabaseHelper.instance.getAllPurchaseOrders();
      setState(() {
        purchasesData = purchases.map((purchase) {
          // Ensure all fields are handled, providing empty string as fallback
          return {
            'date': purchase['date'] ?? '',
            'orderNo': purchase['orderNo'] ?? '',
            'supplier': purchase['supplier'] ?? '',
            'purchaseReturn': purchase['purchaseReturn'] ?? '',
            'orderAmount': purchase['orderAmount']?.toString() ?? '',
            'discount': purchase['discount']?.toString() ?? '',
            'prevBalance': purchase['prevBalance']?.toString() ?? '',
            'billPaid': purchase['billPaid']?.toString() ?? '',
            'balance': purchase['balance']?.toString() ?? '',
          };
        }).toList();
      });
    } catch (e) {
      // Log or show an error if database loading fails
      _showSnackBar('Failed to load purchases: $e');
    }
  }

  /// Deletes a purchase order by its order number and refreshes the data.
  Future<void> _deletePurchaseOrder(String orderNo) async {
    try {
      await DatabaseHelper.instance.deletePurchaseOrderByOrderNo(orderNo);
      _loadPurchasesFromDatabase(); // Refresh the data after deletion
      _showSnackBar('Purchase order $orderNo deleted successfully.');
    } catch (e) {
      _showSnackBar('Failed to delete purchase order: $e');
    }
  }

  /// Shows a confirmation dialog before deleting a purchase.
  void _confirmDelete(String orderNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Purchase"),
          content: const Text("Are you sure you want to delete this purchase? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _deletePurchaseOrder(orderNo); // Proceed with deletion
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
            height: screenHeight * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
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
                          'Purchases Data',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32, // Responsive font size for title
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey), // Changed color to grey for better visibility
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ConstrainedBox(
                          // Ensure a minimum width for the table to maintain readability
                          constraints: BoxConstraints(minWidth: isMobile ? 800.0 : screenWidth * 0.7),
                          child: Table(
                            border: TableBorder.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                            // Use FlexColumnWidth for responsive column sizing
                            columnWidths: const {
                              0: FlexColumnWidth(1.2), // Date
                              1: FlexColumnWidth(1.0), // Order No.
                              2: FlexColumnWidth(1.8), // Supplier
                              3: FlexColumnWidth(1.5), // Purchase Return
                              4: FlexColumnWidth(1.2), // Order Amount
                              5: FlexColumnWidth(1.0), // Discount
                              6: FlexColumnWidth(1.2), // Prev. Balance
                              7: FlexColumnWidth(1.0), // Bill Paid
                              8: FlexColumnWidth(1.0), // Balance
                              9: IntrinsicColumnWidth(), // Action (delete button)
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                ),
                                children: [
                                  _TableHeaderCell('Date', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Order No.', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Supplier', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Purchase Return', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Order Amount', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Discount', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Prev. Balance', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Bill Paid', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Balance', fontSize: isMobile ? 14 : 18),
                                  _TableHeaderCell('Action', fontSize: isMobile ? 14 : 18),
                                ],
                              ),
                              // Iterate through purchase data to create table rows
                              for (var purchase in purchasesData)
                                TableRow(
                                  children: [
                                    _TableCell(purchase['date'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['orderNo'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['supplier'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['purchaseReturn'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['orderAmount'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['discount'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['prevBalance'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['billPaid'] ?? '', fontSize: isMobile ? 12 : 16),
                                    _TableCell(purchase['balance'] ?? '', fontSize: isMobile ? 12 : 16),
                                    Center( // Center the delete icon
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          if (purchase['orderNo'] != null && purchase['orderNo']!.isNotEmpty) {
                                            _confirmDelete(purchase['orderNo']);
                                          } else {
                                            _showSnackBar('Error: Cannot delete record without an Order No');
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
        textAlign: TextAlign.center,
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
        textAlign: TextAlign.center,
      ),
    );
  }
}
