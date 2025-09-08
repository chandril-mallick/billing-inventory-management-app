import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../database/db_manager.dart'; // Assuming this path is correct for your project
import '../../helper/pdfgenerator.dart'; // Assuming this path is correct for your project

class NewSale extends StatefulWidget {
  const NewSale({super.key});

  @override
  _NewSaleState createState() => _NewSaleState();
}

class _NewSaleState extends State<NewSale> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController orderTotalController = TextEditingController();
  final TextEditingController orderDiscountController = TextEditingController();
  final TextEditingController subTotalController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final PdfGenerator pdfGenerator = PdfGenerator();

  final GlobalKey customerFieldKey = GlobalKey();
  final FocusNode customerFocusNode = FocusNode();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> _saleOrders = [];
  List<Map<String, dynamic>> saleRows = [];
  String selectedOption = 'Cash';
  String formattedDate = "";

  OverlayEntry? customerOverlay;
  OverlayEntry? productOverlay;

  @override
  void initState() {
    DateTime now = DateTime.now();
    _loadSaleOrders();
    formattedDate = DateFormat('dd/MM/yyyy').format(now);
    deliveryDateController.text = formattedDate;
    super.initState();
    addNewRow();
    initializeSummaryValues();
    fetchCustomers();
    fetchProducts();

    // Add listener to customerFocusNode to hide overlay when focus is lost
    customerFocusNode.addListener(() {
      if (!customerFocusNode.hasFocus) {
        // Give a small delay to allow tap on overlay items to register
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return; // Check if widget is still in tree
          hideCustomerOverlay();
        });
      }
    });
  }

  @override
  void dispose() {
    customerController.dispose();
    addressController.dispose();
    phoneController.dispose();
    orderTotalController.dispose();
    orderDiscountController.dispose();
    subTotalController.dispose();
    totalController.dispose();
    paidController.dispose();
    balanceController.dispose();
    deliveryDateController.dispose();
    customerFocusNode.dispose(); // Dispose the focus node
    for (var row in saleRows) {
      row['productController'].dispose();
      row['priceController'].dispose();
      row['quantityController'].dispose();
      row['totalController'].dispose();
    }
    // Ensure overlays are removed when widget is disposed
    hideCustomerOverlay();
    hideProductOverlay();
    super.dispose();
  }

  Future<void> fetchCustomers() async {
    try {
      customers = await dbHelper.getAllCustomers();
      setState(() {
        filteredCustomers = customers;
      });
    } catch (e) {
      // Handle error, maybe show a snackbar
      // In a real app, you might show a SnackBar or a dialog here.
      print('Error fetching customers: $e');
    }
  }

  void saveSaleToDatabase(String date, orderno, customer, orderAmount, discount,
      prevbalance, billpaid, balance) async {
    final sale = {
      'date': date,
      'orderNo': orderno,
      'customer': customer,
      'orderAmount': orderAmount,
      'discount': discount,
      'prevBalance': prevbalance,
      'billPaid': billpaid,
      'balance': balance,
    };

    await DatabaseHelper.instance.addSaleOrder(sale);
  }

  Future<void> fetchProducts() async {
    try {
      products = await dbHelper.getAllProducts();
      setState(() {
        filteredProducts = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = customers;
      });
      hideCustomerOverlay(); // Hide if query is empty
      return;
    }
    try {
      final result = await dbHelper.searchCustomers(query);
      setState(() {
        filteredCustomers = result;
      });
      // If no results, hide overlay, otherwise show
      if (filteredCustomers.isEmpty) {
        hideCustomerOverlay();
      } else {
        // Need to ensure context is available for showing overlay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && customerFieldKey.currentContext != null) {
            showCustomerOverlay(customerFieldKey.currentContext!, customerFieldKey);
          }
        });
      }
    } catch (e) {
      // Handle error
      print('Error searching customers: $e'); // Log error
      hideCustomerOverlay(); // Hide on error
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
      hideProductOverlay(); // Hide if query is empty
      return;
    }

    try {
      final result = await dbHelper.searchProducts(query);
      setState(() {
        filteredProducts = result;
      });
      // If no results, hide overlay, otherwise ensure it's shown
      if (filteredProducts.isEmpty) {
        hideProductOverlay();
      } else {
        // No specific context passed to searchProducts, so need to be careful
        // The showProductOverlay function is called from the Builder within the Table,
        // which gives it the correct rowContext.
      }
    } catch (e) {
      // Handle error
      print('Error searching products: $e'); // Log error
      hideProductOverlay(); // Hide on error
    }
  }

  void onCustomerSelected(Map<String, dynamic> customer) {
    setState(() {
      customerController.text = customer['name'];
      addressController.text = customer['address'];
      phoneController.text = customer['phone'] ?? '';
      hideCustomerOverlay(); // Ensure overlay is hidden on selection
    });
  }

  void calculateItemTotal(int index) {
    final price = double.tryParse(
          saleRows[index]['priceController'].text.replaceAll(',', ''),
        ) ??
        0.0;
    final quantity =
        int.tryParse(saleRows[index]['quantityController'].text) ?? 0;

    setState(() {
      final total = price * quantity;
      saleRows[index]['totalController'].text = total.toStringAsFixed(2);
    });
    updateOrderSummary();
  }

  void _loadSaleOrders() async {
    final saleOrders = await DatabaseHelper.instance.getAllSaleOrders();
    setState(() {
      _saleOrders = saleOrders;
    });
  }

  void updateOrderSummary() {
    double orderTotal = 0.0;

    for (var row in saleRows) {
      final itemTotal =
          double.tryParse(row['totalController'].text.replaceAll(',', '')) ??
              0.0;
      orderTotal += itemTotal;
    }

    setState(() {
      orderTotalController.text = orderTotal.toStringAsFixed(2);

      final discount = double.tryParse(orderDiscountController.text) ?? 0.0;
      final subTotal = orderTotal - discount;
      subTotalController.text = subTotal.toStringAsFixed(2);

      totalController.text = subTotalController.text;
      paidController.text = subTotalController.text;

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
      saleRows[rowIndex]['productController'].text = product['productName'];
      saleRows[rowIndex]['priceController'].text =
          product['salePrice'].toStringAsFixed(2);
      saleRows[rowIndex]['quantityController'].text = '1';
      calculateItemTotal(rowIndex);
      hideProductOverlay(); // Ensure overlay is hidden on selection
    });
  }

  void showProductOverlay(BuildContext rowContext, int rowIndex) {
    // Only show if there are filtered products
    if (filteredProducts.isEmpty) {
      hideProductOverlay();
      return;
    }

    hideProductOverlay(); // Hide existing overlay first

    final RenderBox renderBox = rowContext.findRenderObject() as RenderBox;
    if (renderBox.paintBounds.isEmpty) return; // Avoid errors if renderBox is not laid out

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
            child: ListView.builder(
              itemCount: filteredProducts.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                final product = filteredProducts[i];
                return ListTile(
                  title: Text(product['productName']),
                  subtitle: Text('Price: ${product['salePrice'] ?? 'N/A'}'),
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

  void showCustomerOverlay(BuildContext context, GlobalKey key) {
    // Only show if there are filtered customers
    if (filteredCustomers.isEmpty) {
      hideCustomerOverlay();
      return;
    }

    hideCustomerOverlay(); // Hide existing overlay first

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    if (renderBox.paintBounds.isEmpty) return; // Avoid errors if renderBox is not laid out

    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;

    customerOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + renderBox.size.height,
          width: width,
          child: Material(
            elevation: 4,
            child: ListView.builder(
              itemCount: filteredCustomers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredCustomers[index]['name']),
                  onTap: () {
                    onCustomerSelected(filteredCustomers[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(customerOverlay!);
  }

  void hideCustomerOverlay() {
    if (customerOverlay != null) {
      customerOverlay!.remove();
      customerOverlay = null;
    }
  }

  void hideProductOverlay() {
    if (productOverlay != null) {
      productOverlay!.remove();
      productOverlay = null;
    }
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
      saleRows.add({
        'productName': '',
        'salePrice': '0',
        'quantity': '1',
        'itemTotal': '0',
        'productController': TextEditingController(),
        'priceController': TextEditingController(),
        'quantityController': TextEditingController(),
        'totalController': TextEditingController(),
        'perUnit': '',
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      // Dispose controllers before removing
      saleRows[index]['productController'].dispose();
      saleRows[index]['priceController'].dispose();
      saleRows[index]['quantityController'].dispose();
      saleRows[index]['totalController'].dispose();

      saleRows.removeAt(index);
      if (saleRows.isEmpty) {
        addNewRow(); // Always keep at least one row
      }
      updateOrderSummary();
    });
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        deliveryDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Details Section
            isMobile
                ? Column(
                    children: [
                      Builder(
                        builder: (fieldContext) {
                          return TextFormField(
                            key: customerFieldKey,
                            focusNode: customerFocusNode, // Assign focus node
                            controller: customerController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              searchCustomers(value);
                              // showCustomerOverlay is now handled inside searchCustomers
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
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
                              key: customerFieldKey,
                              focusNode: customerFocusNode, // Assign focus node
                              controller: customerController,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                searchCustomers(value);
                                // showCustomerOverlay is now handled inside searchCustomers
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),

            // Delivery Date Section
            GestureDetector(
              onTap: () => _selectDeliveryDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: deliveryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: screenWidth),
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: const FixedColumnWidth(50),
                    1: FlexColumnWidth(isMobile ? 3 : 4),
                    2: FlexColumnWidth(isMobile ? 2 : 3),
                    3: FlexColumnWidth(isMobile ? 1.5 : 2),
                    4: FlexColumnWidth(isMobile ? 2 : 3),
                    5: const FixedColumnWidth(60),
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
                    for (int i = 0; i < saleRows.length; i++)
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
                                return Focus( // Wrap with Focus to handle focus loss for product search
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        if (!mounted) return;
                                        // Ensure the overlay is hidden when the product field loses focus
                                        hideProductOverlay();
                                      });
                                    }
                                  },
                                  child: TextFormField(
                                    controller: saleRows[i]['productController'],
                                    decoration: const InputDecoration(
                                      labelText: 'Product Name',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      searchProducts(value).then((_) {
                                        // This ensures the overlay is shown/hidden based on search results
                                        if (filteredProducts.isNotEmpty) {
                                          showProductOverlay(rowContext, i);
                                        } else {
                                          hideProductOverlay();
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: saleRows[i]['priceController'],
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'))
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
                              controller: saleRows[i]['quantityController'],
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
                              controller: saleRows[i]['totalController'],
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
                              onPressed: saleRows.length > 1
                                  ? () => removeRow(i)
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: isMobile ? 20 : 24,
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
                width: isMobile ? screenWidth * 0.9 : 350,
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      saveSaleToDatabase(
                        formattedDate,
                        _saleOrders.length + 1,
                        customerController.text,
                        '\u20B9${orderTotalController.text}',
                        '\u20B9${orderDiscountController.text}',
                        '\u20B9${totalController.text}',
                        '\u20B9${paidController.text}',
                        '\u20B9${balanceController.text}',
                      );
                      createpdfinvoice();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Purchase saved and PDF generated!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: isMobile ? const Size(double.infinity, 50) : const Size(150, 60),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8.0),
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

  void createpdfinvoice() {
    // Prepare items list for the PDF, mapping to the structure expected by generatePdfWithBackground
    List<Map<String, dynamic>> itemsForPdf = saleRows
        .map((row) => {
              "slNo": "${saleRows.indexOf(row) + 1}",
              "quantity": row['quantityController'].text,
              "particular": row['productController'].text,
              "rate": row['priceController'].text,
              "amount": row['totalController'].text,
            })
        .toList();

    // Call the correct method: generatePdfWithBackground
    pdfGenerator.generatePdfWithBackground(
      ref: (_saleOrders.length + 1).toString(), // Using sales order count as a simple reference
      date: formattedDate,
      name: customerController.text,
      address: addressController.text,
      mobile: phoneController.text,
      applicationId: null, // You can set a real application ID if available, otherwise null
      deliveryDate: deliveryDateController.text,
      grossTotal: double.tryParse(orderTotalController.text) ?? 0.0,
      advance: double.tryParse(paidController.text) ?? 0.0,
      dueBalance: double.tryParse(balanceController.text) ?? 0.0,
      items: itemsForPdf,
    );
  }

  Widget buildSummaryRow(String label, String value, double fontSize,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\u20B9$value',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget buildInputRow(
      String label, TextEditingController controller, double fontSize,
      {Function(String)? onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
        SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
