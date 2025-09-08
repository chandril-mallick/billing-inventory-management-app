import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  static final Logger _logger = Logger();

  Future<void> generatePdfWithBackground({
    required String ref,
    required String date,
    required String name,
    required String address,
    required String mobile,
    String? applicationId,
    String? deliveryDate,
    required double grossTotal,
    required double advance,
    required double dueBalance,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final imageData = await rootBundle.load('assets/images/nagerbazar_invoice-1.png');
    //final stampData = await rootBundle.load('Assets/images/stamp.png'); // Stamp image
    //final stampImage = pw.MemoryImage(stampData.buffer.asUint8List());
    final bgImage = pw.MemoryImage(imageData.buffer.asUint8List());

    const baseTableTop = 280.0;
    const rowHeight = 20.0;
    const containerHeight = 320.0;
    // Calculate the top position for the footer container
    final footerContainerTop = baseTableTop + 300 + 20; // 300 is the fixed height of the items table

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(child: pw.Image(bgImage, fit: pw.BoxFit.cover)),

              // Customer Information Box
              pw.Positioned(
                left: 30,
                right: 30,
                top: 178,
                child: pw.Container(
                  height: 120,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.7, color: PdfColors.black),
                  ),
                  child: pw.Column(
                    children: [
                      // First Row: Ref and Date
                     pw.Container(
  padding: pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
   border: pw.Border(bottom: pw.BorderSide(width: 0.7, color: PdfColors.black)),
  ),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        "Ref:- NBFB$ref",
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bolded
      ),
      pw.Text(
        "Date: $date",
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bolded
      ),
    ],
  ),
),
                      
                      // Customer Details Section
          pw.Container(
  padding: pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(width: 0.7, color: PdfColors.black)),
  ),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      // Left side: Delivery Date above Ref
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // Align text left inside the column
        children: [
          pw.Text(
            "Name:- $name",
            style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Adresss: $address",
            style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),

      // Right side: you can add something here or leave empty
      
    ],
  ),
),



                      
                      // Mobile and Application ID Row
                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Mobile: $mobile", style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
                            pw.Text("Application ID:- NBF&IOR$ref", style: pw.TextStyle(fontSize: 10 ,fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Table Container
              pw.Positioned(
                top: baseTableTop,
                left: 30,
                right: 30,
                child: pw.Container(
                  height: containerHeight,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.7, color: PdfColors.black),
                  ),
                  child: pw.Column(
                    children: [
                      // Header Row
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 40,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Sl. No", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 50,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Quantity", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 300,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Particular", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 50,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Rate", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 30,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Per", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 35,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                              ),
                              child: pw.Text("Rs", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 20,
                              alignment: pw.Alignment.centerLeft,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                              child: pw.Text("p", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      // Content Area with Fixed Height
                      pw.Expanded(
                        child: pw.Stack(
                          children: [
                            // Item Rows
                            pw.Column(
                              children: items.map((item) {
                                final double rate = double.tryParse(item['rate'].toString()) ?? 0.0;
                                final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
                                final rs = amount.floor();
                                final ps = ((amount - rs) * 100).round();

                                return pw.Container(
                                  height: rowHeight,
                                  child: pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 40,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(item['slNo'].toString(), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 50,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(item['quantity'].toString(), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 300,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(item['particular'].toString(), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 50,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(rate.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 30,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text("", style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 35,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(rs.toString(), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                      pw.Container(
                                        width: 20,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                        child: pw.Text(ps.toString().padLeft(2, '0'), style: const pw.TextStyle(fontSize: 9)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            // Vertical lines that span the full height
                            pw.Positioned.fill(
                              child: pw.Row(
                                children: [
                                  pw.Container(
                                    width: 40,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 50,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 300,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 50,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 30,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 35,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(right: pw.BorderSide(width: 0.7, color: PdfColors.black)),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Container
              pw.Positioned(
                left: 30,
                right: 30,
                top: footerContainerTop, // Use the calculated top for the container
                child: pw.Container(
                  height: 100, // Fixed height for the footer container
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.7),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Footer Left Side (Amount in words, Delivery Date, E. & O.E., For Nagerbazar Furniture & Interior)
                      pw.Container(
                        width: 352, // Same width as your existing footer1
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Amount in Word: ${numberToWords(grossTotal.toInt()).toUpperCase()} RUPEES ONLY",
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                            ),
                           pw.SizedBox(height: 5),
pw.Text(
  "Delivery Date: ${deliveryDate ?? 'N/A'}", // Use the deliveryDate variable
  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
),
                            pw.SizedBox(height: 10),
                            pw.Center(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    "E. & O.E.",
                                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Text(
                                    "For Nagerbazar Furniture & Interior",
                                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Footer Right Side (Gross Total, Advance, Due Balance, Total Table)
                      pw.Container(
                        width: 180, // Adjust width as needed for the table
                        child: pw.Table(
                          columnWidths: {
                            0: pw.FixedColumnWidth(100),
                            1: pw.FixedColumnWidth(80),
                          },
                          border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                          defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                          children: [
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Gross Total", style: pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Rs ${grossTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 10)),
                              ),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Advance", style: pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Rs ${advance.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 10)),
                              ),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Due Balance", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Rs ${dueBalance.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                              ),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Total", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Rs ${grossTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            //  pw.Positioned(
               // right: 40,
             //   bottom: 70,
              //  child: pw.Image(stampImage, width: 70),
            //  ),

             // pw.Positioned(
              //  right: 30,
               // bottom: 120,
               // child: pw.Text("For Nagerbazar Furniture & Interior", style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
             // ),
            ],
          );
        },
      ),
    );

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        _logger.e('Failed to locate the Downloads directory.');
        return;
      }

      final nagerbazarDir = Directory('${downloadsDir.path}/Nagerbazar');
      if (!await nagerbazarDir.exists()) {
        await nagerbazarDir.create(recursive: true);
        _logger.i('Created folder: ${nagerbazarDir.path}');
      }

      final fileName = 'ORD${generateRandomFiveDigitNumber()}.pdf';
      final filePath = '${nagerbazarDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _logger.i('PDF successfully saved to: $filePath');

      final openResult = await OpenFile.open(filePath);
      if (openResult.type != ResultType.done) {
        _logger.w('Failed to open PDF: ${openResult.message}');
      }
    } catch (e) {
      _logger.e('Error occurred while saving or opening the PDF: $e');
    }
  }

  int generateRandomFiveDigitNumber() {
    final random = Random();
    return 10000 + random.nextInt(90000);
  }

  String numberToWords(int number) {
    final units = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
    final teens = ["eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"];
    final tens = ["", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];
    final thousands = ["", "thousand", "million", "billion"];

    if (number == 0) return "zero";

    String convert(int n, int level) {
      if (n == 0) return "";
      String words = "";
      if (n >= 100) {
        words += "${units[n ~/ 100]} hundred ";
        n %= 100;
      }
      if (n >= 11 && n <= 19) {
        words += "${teens[n - 11]} ";
      } else {
        if (n >= 20) {
          words += "${tens[n ~/ 10]} ";
          n %= 10;
        }
        if (n >= 1 && n <= 9) {
          words += "${units[n]} ";
        }
      }
      if (level > 0 && words.isNotEmpty) {
        words += "${thousands[level]} ";
      }
      return words.trim();
    }

    String result = "";
    int level = 0;
    while (number > 0) {
      int chunk = number % 1000;
      if (chunk > 0) {
        result = "${convert(chunk, level)} $result";
      }
      number ~/= 1000;
      level++;
    }
    return result.trim();
  }
}