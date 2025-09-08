import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:logger/logger.dart'; // Commented out as it's not used directly here
import '../../database/db_manager.dart';
import '../../helper/pdfgenerator.dart'; // Ensure this path is correct

class NewPurchaseScreen extends StatefulWidget {
  const NewPurchaseScreen({super.key});

  @override
  _NewPurchaseScreenState createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController orderTotalController = TextEditingController();
  final TextEditingController orderDiscountController = TextEditingController();
  final TextEditingController subTotalController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final PdfGenerator pdfGenerator = PdfGenerator();

  final GlobalKey supplierFieldKey = GlobalKey();
  final FocusNode supplierFocusNode = FocusNode();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> _purchaseOrders = [];
  List<Map<String, dynamic>> purchaseRows = [];
  String selectedOption = 'Cash'; // Default selected value
  String formattedDate = "";
  String phonenumber = ""; // This holds the supplier's phone number

  OverlayEntry? supplierOverlay;
  OverlayEntry? productOverlay;

  @override
  void initState() {
    DateTime now = DateTime.now();
    _loadPurchaseOrders();
    // Format the date
    formattedDate = DateFormat('dd/MM/yyyy').format(now);
    super.initState();
    addNewRow();
    initializeSummaryValues();
    fetchSuppliers();
    fetchProducts();
  }

  Future<void> fetchSuppliers() async {
    try {
      suppliers = await dbHelper.getAllSuppliers();
      // logger.i("Fetched suppliers: $suppliers");
      setState(() {
        filteredSuppliers = suppliers;
      });
    } catch (e) {
      // logger.e("Error fetching suppliers: $e");
    }
  }

  void savePurchaseToDatabase(String date, orderno, supplier, purchaseReturn,
      orderAmount, discount, prevbalance, billpaid, balance) async {
    final purchase = {
      'date': date,
      'orderNo': orderno,
      'supplier': supplier,
      'purchaseReturn': purchaseReturn,
      'orderAmount': orderAmount,
      'discount': discount,
      'prevBalance': prevbalance,
      'billPaid': billpaid,
      'balance': balance,
    };

    await DatabaseHelper.instance.addPurchaseOrder(purchase);
  }

  Future<void> fetchProducts() async {
    try {
      products = await dbHelper.getAllProducts();
      // logger.i("Fetched products: $products");
      setState(() {
        filteredProducts = products;
      });
    } catch (e) {
      // logger.e("Error fetching products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> searchSuppliers(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredSuppliers = suppliers;
      });
      return;
    }
    try {
      final result = await dbHelper.searchSuppliers(query);
      // logger.i('Supplier search query: "$query", Results: $result');
      setState(() {
        filteredSuppliers = result;
      });
    } catch (e) {
      // logger.e("Error searching suppliers: $e");
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
      hideProductOverlay();
      return;
    }

    try {
      final result = await dbHelper.searchProducts(query);
      // logger.i('Product search query: "$query", Results: $result');
      setState(() {
        filteredProducts = result;
      });
    } catch (e) {
      // logger.e("Error searching products: $e");
    }
  }

  void onSupplierSelected(Map<String, dynamic> supplier) {
    setState(() {
      supplierController.text = supplier['name'];
      addressController.text = supplier['address'];
      phonenumber = supplier['phone']; // Capture the phone number

      // logger.d("Supplier selected: $supplier");
      hideSupplierOverlay();
    });
  }

  void calculateItemTotal(int index) {
    final price = double.tryParse(
          purchaseRows[index]['priceController'].text.replaceAll(',', ''),
        ) ??
        0.0;
    final quantity =
        int.tryParse(purchaseRows[index]['quantityController'].text) ?? 0;

    setState(() {
      final total = price * quantity;
      purchaseRows[index]['totalController'].text = total.toStringAsFixed(2);
      // logger.d(
      //     "Calculated total for row $index: Price = $price, Quantity = $quantity, Total = $total");
    });
    updateOrderSummary();
  }

  void _loadPurchaseOrders() async {
    final purchaseOrders = await DatabaseHelper.instance.getAllPurchaseOrders();
    setState(() {
      _purchaseOrders = purchaseOrders;
    });
  }

  void updateOrderSummary() {
    double orderTotal = 0.0;

    for (var row in purchaseRows) {
      final itemTotal =
          double.tryParse(row['totalController'].text.replaceAll(',', '')) ??
              0.0;
      orderTotal += itemTotal;
    }

    setState(() {
      orderTotalController.text = orderTotal.toStringAsFixed(2);

      // Subtotal is initially equal to order total minus discount
      final discount = double.tryParse(orderDiscountController.text) ?? 0.0;
      final subTotal = orderTotal - discount;
      subTotalController.text = subTotal.toStringAsFixed(2);

      // Total is equal to subtotal
      totalController.text = subTotalController.text;
      paidController.text = subTotalController.text;

      // Balance is total minus paid amount
      final paid = double.tryParse(paidController.text) ?? 0.0;
      final balance = subTotal - paid;
      balanceController.text = balance.toStringAsFixed(2);
    });
  }

  void handleDiscountChange(String value) {
    updateOrderSummary();
  }

  void handlePaidChange(String value) {
    final paid = double.tryParse(value) ?? 0.0;
    final subTotal = double.tryParse(subTotalController.text) ?? 0.0;

    setState(() {
      final balance = subTotal - paid;
      balanceController.text = balance.toStringAsFixed(2);
    });
  }

  void selectProduct(int rowIndex, Map<String, dynamic> product) {
    setState(() {
      purchaseRows[rowIndex]['productController'].text = product['productName'];
      purchaseRows[rowIndex]['priceController'].text =
          product['purchasePrice'].toString();
      purchaseRows[rowIndex]['quantityController'].text = '1';
      calculateItemTotal(rowIndex);
      // logger.i("Product selected for row $rowIndex: $product");
      hideProductOverlay();
    });
  }

  void showProductOverlay(BuildContext rowContext, int rowIndex) {
    hideProductOverlay();

    final RenderBox renderBox = rowContext.findRenderObject() as RenderBox;

    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;

    productOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + renderBox.size.height,
          width: width,
          child: Material(
            elevation: 4,
            child: filteredProducts.isEmpty
                ? const ListTile(title: Text('No products found'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      final product = filteredProducts[i];
                      return ListTile(
                        title: Text(product['productName']),
                        subtitle: Text('Price: ${product['purchasePrice'] ?? 'N/A'}'),
                        onTap: () {
                          selectProduct(rowIndex, product);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );

    Overlay.of(context).insert(productOverlay!);
  }

  void showSupplierOverlay(BuildContext context, GlobalKey key) {
    hideSupplierOverlay();

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;

    supplierOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + renderBox.size.height,
          width: width,
          child: Material(
            elevation: 4,
            child: ListView.builder(
              itemCount: filteredSuppliers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredSuppliers[index]['name']),
                  onTap: () {
                    onSupplierSelected(filteredSuppliers[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(supplierOverlay!);
  }

  void hideSupplierOverlay() {
    supplierOverlay?.remove();
    supplierOverlay = null;
  }

  void hideProductOverlay() {
    productOverlay?.remove();
    productOverlay = null;
  }

  void initializeSummaryValues() {
    setState(() {
      orderTotalController.text = "0.00";
      orderDiscountController.text = "0.00";
      subTotalController.text = "0.00";
      totalController.text = "0.00";
      paidController.text = "0.00";
      balanceController.text = "0.00";
    });
  }

  void addNewRow() {
    setState(() {
      purchaseRows.add({
        'productName': '',
        'purchasePrice': '0',
        'quantity': '1',
        'itemTotal': '0',
        'productController': TextEditingController(),
        'priceController': TextEditingController(),
        'quantityController': TextEditingController(),
        'totalController': TextEditingController(),
        'perUnit': '', // Initialize perUnit for new rows
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      purchaseRows[index]['productController'].dispose();
      purchaseRows[index]['priceController'].dispose();
      purchaseRows[index]['quantityController'].dispose();
      purchaseRows[index]['totalController'].dispose();

      purchaseRows.removeAt(index);

      if (purchaseRows.isEmpty) {
        addNewRow();
      }
    });
  }

  @override
  void dispose() {
    orderTotalController.dispose();
    orderDiscountController.dispose();
    subTotalController.dispose();
    totalController.dispose();
    paidController.dispose();
    balanceController.dispose();
    for (var row in purchaseRows) {
      row['productController'].dispose();
      row['priceController'].dispose();
      row['quantityController'].dispose();
      row['totalController'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Define a breakpoint for mobile

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Purchase'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier and Address Section
            isMobile
                ? Column(
                    children: [
                      Builder(
                        builder: (fieldContext) {
                          return TextFormField(
                            key: supplierFieldKey,
                            focusNode: supplierFocusNode,
                            controller: supplierController,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              searchSuppliers(value);
                              showSupplierOverlay(fieldContext, supplierFieldKey);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (fieldContext) {
                            return TextFormField(
                              key: supplierFieldKey,
                              focusNode: supplierFocusNode,
                              controller: supplierController,
                              decoration: const InputDecoration(
                                labelText: 'Supplier Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                searchSuppliers(value);
                                showSupplierOverlay(fieldContext, supplierFieldKey);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: addressController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),

            // Product Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: screenWidth), // Ensure it takes at least screen width
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: const FixedColumnWidth(50), // #
                    1: FlexColumnWidth(isMobile ? 3 : 4), // Product Name
                    2: FlexColumnWidth(isMobile ? 2 : 3), // Purchase Price
                    3: FlexColumnWidth(isMobile ? 1.5 : 2), // Quantity
                    4: FlexColumnWidth(isMobile ? 2 : 3), // Item Total
                    5: const FixedColumnWidth(60), // Actions (smaller for mobile)
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('#', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Product', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Price', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Del', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    for (int i = 0; i < purchaseRows.length; i++)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${i + 1}', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Builder(
                              builder: (rowContext) {
                                return TextFormField(
                                  controller: purchaseRows[i]['productController'],
                                  decoration: const InputDecoration(
                                    labelText: 'Product Name',
                                    border: OutlineInputBorder(),
                                    isDense: true, // Make it more compact
                                  ),
                                  onChanged: (value) {
                                    searchProducts(value).then((_) {
                                      if (filteredProducts.isNotEmpty) {
                                        showProductOverlay(rowContext, i);
                                      } else {
                                        hideProductOverlay();
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              readOnly: true,
                              controller: purchaseRows[i]['priceController'],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                calculateItemTotal(i);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: purchaseRows[i]['quantityController'],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                calculateItemTotal(i);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: purchaseRows[i]['totalController'],
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Total',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: purchaseRows.length > 1
                                  ? () => removeRow(i)
                                  : null,
                              padding: EdgeInsets.zero, // Reduce padding
                              constraints: const BoxConstraints(), // Remove default constraints
                              iconSize: isMobile ? 20 : 24, // Adjust icon size
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Add Row Button
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: addNewRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: isMobile ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
                ),
                child: const Text(
                  '+ Add Row',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Order Summary Section
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: isMobile ? screenWidth * 0.9 : 350, // Adjust width based on mobile/desktop
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummaryRow(
                        "Order Total", orderTotalController.text, isMobile ? 18 : 20),
                    const SizedBox(height: 10),
                    buildInputRow(
                      "Order Discount",
                      orderDiscountController,
                      isMobile ? 18 : 20,
                      onChanged: handleDiscountChange,
                    ),
                    const SizedBox(height: 10),
                    buildSummaryRow("Sub Total", subTotalController.text, isMobile ? 18 : 20,
                        bold: true),
                    const SizedBox(height: 10),
                    buildInputRow("Paid", paidController, isMobile ? 18 : 20,
                        onChanged: handlePaidChange),
                    const SizedBox(height: 10),
                    buildSummaryRow("Balance", balanceController.text, isMobile ? 18 : 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bill Print Section
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Dropdown inside a box
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: DropdownButton<String>(
                    value: selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOption = newValue!;
                      });
                    },
                    items: <String>['Cash', 'Online', 'Cheque', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black),
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                SizedBox(
                  width: isMobile ? 10 : 50,
                ),
                // Save and Print Button
                Expanded( // Use Expanded to allow button to take available space
                  child: ElevatedButton(
                    onPressed: () {
                      // Save purchase data to database
                      savePurchaseToDatabase(
                        formattedDate,
                        _purchaseOrders.length + 1,
                        supplierController.text,
                        "NO",
                        '\u20B9${orderTotalController.text}',
                        '\u20B9${orderDiscountController.text}',
                        '\u20B9${totalController.text}',
                        '\u20B9${paidController.text}',
                        '\u20B9${balanceController.text}',
                      );
                      // Create a new invoice of the order
                      createpdfinvoice();

                      // Show confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Purchase saved and PDF generated!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: isMobile ? const Size(double.infinity, 50) : const Size(150, 60), // Full width on mobile
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8.0), // Reduced horizontal padding for mobile
                      textStyle: TextStyle(
                          fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                    ),
                    child: subTotalController.text == "0.00"
                        ? const Text(
                            'Save and Print',
                            style: TextStyle(color: Colors.white),
                          )
                        : Text(
                            'Pay ${subTotalController.text}',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Helper function for rows with a static value
  Widget buildSummaryRow(String label, String value, double size,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper function for rows with input fields
  Widget buildInputRow(
      String label, TextEditingController controller, double size,
      {Function(String)? onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: size),
        ),
        SizedBox(
          width: 100, // Keep a fixed width for input fields in summary for consistency
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void createpdfinvoice() {
    List<Map<String, dynamic>> items = purchaseRows
        .map((row) => {
              "slNo":
                  "${purchaseRows.indexOf(row) + 1}", // Dynamic serial number
              "quantity": row['quantityController'].text.isEmpty
                  ? "0"
                  : row['quantityController'].text, // Default to "0" if empty
              "particular": row['productController'].text.isEmpty
                  ? "Unnamed Product"
                  : row['productController'].text,
              "rate": row['priceController'].text.isEmpty
                  ? "0"
                  : row['priceController'].text,
              // Note: 'perUnit' is passed to PDF generator but not used in the provided PDF template
              "perUnit": row['perUnit']?.toString() ?? '',
              "amount": row['totalController'].text.isEmpty
                  ? "0"
                  : row['totalController'].text,
            })
        .toList();

    // Prepare other required fields
    final ref = "PO-${_purchaseOrders.length + 1}"; // Example: Order number
    final date = formattedDate; // Current date
    final name = supplierController.text.isEmpty
        ? "Unnamed Supplier"
        : supplierController.text;
    final address = addressController.text.isEmpty
        ? "No Address Provided"
        : addressController.text;
    final grossTotal = double.tryParse(orderTotalController.text) ?? 0.0;
    final advance = double.tryParse(paidController.text) ?? 0.0;
    final dueBalance = double.tryParse(balanceController.text) ?? 0.0;
    // final totalAmount = double.tryParse(totalController.text) ?? 0.0; // This parameter is not used by generatePdfWithBackground
    final applicationId = ref; // Using ref as applicationId for now
    final deliveryDate = formattedDate; // Using formattedDate as deliveryDate for now
    final mobileNumber = this.phonenumber.isEmpty ? "N/A" : this.phonenumber; // Use 'mobile' for the parameter name


    // Call the PdfGenerator's 'generatePdfWithBackground' method
    pdfGenerator.generatePdfWithBackground(
      ref: ref,
      date: date,
      name: name,
      address: address,
      mobile: mobileNumber, // Changed to 'mobile' to match PdfGenerator method
      grossTotal: grossTotal,
      advance: advance,
      dueBalance: dueBalance,
      items: items,
      applicationId: applicationId,
      deliveryDate: deliveryDate,
      // Removed 'totalAmount' as it's not a parameter in generatePdfWithBackground
    );
  }
}