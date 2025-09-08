import 'package:flutter/material.dart';
import '../../database/db_manager.dart'; // Import your DatabaseHelper

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({super.key});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  // final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
              child: _buildHeading("Dashboard"),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getDashboardData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data;

                  // Use the data from the snapshot to build the grid
                  return GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 800 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      DashboardTile(
                        icon: Icons.shopping_bag,
                        title: 'Purchases',
                        value: data?['totalPurchasesAmount'] ?? '0',
                        color: Colors.green,
                      ),
                      DashboardTile(
                        icon: Icons.bar_chart,
                        title: 'Sales',
                        value: data?['totalSalesAmount'] ?? '0',
                        color: Colors.blue,
                      ),
                      DashboardTile(
                        icon: Icons.pie_chart,
                        title: 'Suppliers',
                        value: data?['totalSuppliers'].toString() ?? '0',
                        color: Colors.grey,
                      ),
                      DashboardTile(
                        icon: Icons.inventory,
                        title: 'Products',
                        value: data?['totalProducts'].toString() ?? '0',
                        color: Colors.orange,
                      ),
                      DashboardTile(
                        icon: Icons.people,
                        title: 'Customers',
                        value: data?['totalCustomers'].toString() ?? '0',
                        color: Colors.red,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modify _getDashboardData to directly return the data
  Future<Map<String, dynamic>> _getDashboardData() async {
    final databaseHelper = DatabaseHelper.instance;

    // Fetching all purchase and sale orders
    final purchaseOrders = await databaseHelper.getAllPurchaseOrders();
    final saleOrders = await databaseHelper.getAllSaleOrders();

    // _logger.d('Fetched ${purchaseOrders.length} purchase orders.');
    // _logger.d('Fetched ${saleOrders.length} sale orders.');

    // Initialize totals
    double totalPurchasesAmount = 0.0;
    double totalSalesAmount = 0.0;

    // Function to clean and parse amounts
    double parseAmount(String? amount) {
      if (amount == null) return 0.0;
      // Remove ₹ and any commas
      String cleanedAmount = amount.replaceAll('₹', '').replaceAll(',', '');
      return double.tryParse(cleanedAmount) ?? 0.0;
    }

    // Calculate total purchase amount
    for (var order in purchaseOrders) {
      final billPaid = order['billPaid']; // Get the billPaid value
      totalPurchasesAmount += parseAmount(billPaid?.toString());
    }

    // _logger.d('Total Purchases Amount: $totalPurchasesAmount');

    // Calculate total sales amount
    for (var order in saleOrders) {
      final billPaid = order['billPaid']; // Get the billPaid value
      totalSalesAmount += parseAmount(billPaid?.toString());
    }

    // _logger.d('Total Sales Amount: $totalSalesAmount');

    // Fetching counts for suppliers, products, and customers
    final totalSuppliers = await databaseHelper.getAllSuppliers();
    final totalCustomers = await databaseHelper.getAllCustomers();
    final totalProducts = await databaseHelper.getAllProducts();

    // _logger.d('Total Suppliers: ${totalSuppliers.length}');
    // _logger.d('Total Customers: ${totalCustomers.length}');
    // _logger.d('Total Products: ${totalProducts.length}');

    // Return the calculated data
    return {
      'totalPurchasesAmount':
          totalPurchasesAmount.toStringAsFixed(2), // Format to 2 decimal places
      'totalSalesAmount':
          totalSalesAmount.toStringAsFixed(2), // Format to 2 decimal places
      'totalSuppliers': totalSuppliers.length,
      'totalCustomers': totalCustomers.length,
      'totalProducts': totalProducts.length,
    };
  }

  Widget _buildHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
