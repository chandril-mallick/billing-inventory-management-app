import 'package:flutter/material.dart';
import '../../database/db_manager.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List<Map<String, dynamic>> salesData = [];

  @override
  void initState() {
    super.initState();
    _loadSalesFromDatabase();
  }

  Future<void> _loadSalesFromDatabase() async {
    final sales = await DatabaseHelper.instance.getAllSaleOrders();
    setState(() {
      salesData = sales.map((sale) {
        return {
          'date': sale['date'] ?? '',
          'orderNo': sale['orderNo'] ?? '',
          'customer': sale['customer'] ?? '',
          'orderAmount': sale['orderAmount']?.toString() ?? '',
          'discount': sale['discount']?.toString() ?? '',
          'prevBalance': sale['prevBalance']?.toString() ?? '',
          'billPaid': sale['billPaid']?.toString() ?? '',
          'balance': sale['balance']?.toString() ?? '',
        };
      }).toList();
    });
  }

  Future<void> _deleteSaleOrder(String orderNo) async {
    await DatabaseHelper.instance.deleteSaleOrderByOrderNo(orderNo);
    _loadSalesFromDatabase();
  }

  void _confirmDelete(String orderNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Sale"),
          content: const Text("Are you sure you want to delete this sale?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSaleOrder(orderNo);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSaleDetails(Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sale Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                _buildDetailRow('Date:', sale['date']),
                _buildDetailRow('Order No:', sale['orderNo']),
                _buildDetailRow('Customer:', sale['customer']),
                _buildDetailRow('Order Amount:', sale['orderAmount']),
                _buildDetailRow('Discount:', sale['discount']),
                _buildDetailRow('Prev. Balance:', sale['prevBalance']),
                _buildDetailRow('Bill Paid:', sale['billPaid']),
                _buildDetailRow('Balance:', sale['balance']),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (sale['orderNo'] != null && sale['orderNo'] != '') {
                          _confirmDelete(sale['orderNo']);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'N/A' : value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 10.0 : 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales Data',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (salesData.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${salesData.length} records',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(thickness: 1, color: Colors.grey.shade300),
              Expanded(
                child: salesData.isEmpty
                    ? _buildEmptyState()
                    : isMobile
                        ? _buildMobileLayout()
                        : _buildDesktopLayout(isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No sales data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sales records will appear here once created',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final sale = salesData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showSaleDetails(sale),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sale['orderNo'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            if (sale['orderNo'] != null && sale['orderNo'] != '') {
                              _confirmDelete(sale['orderNo']);
                            }
                          } else if (value == 'details') {
                            _showSaleDetails(sale);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 18),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sale['customer'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sale['date'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹${sale['orderAmount'] ?? '0'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
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

  Widget _buildDesktopLayout(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          child: DataTable(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: isTablet ? 14 : 16,
            ),
            dataTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: isTablet ? 12 : 14,
            ),
            columnSpacing: isTablet ? 20 : 30,
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Order No.')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('Prev. Balance')),
              DataColumn(label: Text('Bill Paid')),
              DataColumn(label: Text('Balance')),
              DataColumn(label: Text('Action')),
            ],
            rows: salesData.map((sale) {
              return DataRow(
                cells: [
                  DataCell(Text(sale['date'] ?? 'N/A')),
                  DataCell(Text(sale['orderNo'] ?? 'N/A')),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        sale['customer'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text('₹${sale['orderAmount'] ?? '0'}')),
                  DataCell(Text('₹${sale['discount'] ?? '0'}')),
                  DataCell(Text('₹${sale['prevBalance'] ?? '0'}')),
                  DataCell(Text('₹${sale['billPaid'] ?? '0'}')),
                  DataCell(Text('₹${sale['balance'] ?? '0'}')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        if (sale['orderNo'] != null && sale['orderNo'] != '') {
                          _confirmDelete(sale['orderNo']);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error: Cannot delete record without an Order No'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      tooltip: 'Delete sale',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}