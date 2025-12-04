# 📱 Billing & Inventory Management App

A comprehensive cross-platform Flutter application for managing inventory, billing, and customer data efficiently. Built with Flutter for seamless performance across Android, iOS, Windows, macOS, Linux, and Web platforms.

## ✨ Features

- **📦 Inventory Management**: Track products, stock levels, and manage inventory efficiently
- **🧾 Billing System**: Generate professional invoices and bills
- **👥 Customer Management**: Maintain customer records and transaction history
- **💾 Local Database**: SQLite integration for offline-first data storage
- **📄 PDF Generation**: Create and export invoices as PDF documents
- **🖨️ Printing Support**: Direct printing capabilities for invoices
- **📊 Reports**: Generate business insights and reports
- **🔒 Permissions Handling**: Secure file access and storage permissions
- **🎨 Modern UI**: Clean and intuitive user interface

## 🛠️ Tech Stack

- **Framework**: Flutter 3.5.4+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **PDF Generation**: pdf, printing packages
- **State Management**: Flutter built-in
- **File Management**: path_provider, open_file

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  path: ^1.9.0
  sqflite_common_ffi: ^2.3.4+3
  sqflite: ^2.4.2
  logger: ^2.5.0
  intl: ^0.20.1
  pdf: ^3.11.1
  printing: ^5.13.4
  path_provider: ^2.1.5
  open_file: ^3.5.10
  permission_handler: ^11.3.1
  package_info_plus: ^8.0.0
  flutter_launcher_icons: ^0.14.2
  rename_app: ^1.6.1
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/chandril-mallick/billing-inventory-management-app.git
   cd billing-inventory-management-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android/iOS
   flutter run
   
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   
   # For Web
   flutter run -d chrome
   ```

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Windows  | ✅ Supported |
| macOS    | ✅ Supported |
| Linux    | ✅ Supported |
| Web      | ✅ Supported |

## 🏗️ Project Structure

```
billing_app/
├── lib/                    # Main application code
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── windows/                # Windows platform files
├── macos/                  # macOS platform files
├── linux/                  # Linux platform files
├── web/                    # Web platform files
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Project dependencies
└── README.md               # Project documentation
```

## 🔧 Configuration

### App Icon
The app uses custom launcher icons configured in `pubspec.yaml`:
- Android: ✅ Enabled
- Windows: ✅ Enabled
- iOS: ❌ Disabled

To regenerate icons:
```bash
flutter pub run flutter_launcher_icons
```

### Rename App
To rename the application:
```bash
flutter pub run rename_app --appname "Your App Name"
```

## 📝 Usage

1. **Add Products**: Navigate to inventory section and add your products
2. **Create Bills**: Select products, enter quantities, and generate invoices
3. **Manage Customers**: Add and maintain customer information
4. **Generate Reports**: View sales and inventory reports
5. **Export PDFs**: Save and share invoices as PDF documents

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 🔒 Permissions

The app requires the following permissions:
- **Storage**: For saving invoices and reports
- **File Access**: For PDF generation and export

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Chandril Mallick**
- GitHub: [@chandril-mallick](https://github.com/chandril-mallick)
- Repository: [billing-inventory-management-app](https://github.com/chandril-mallick/billing-inventory-management-app)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors and supporters of this project

## 📞 Support

For support, please open an issue in the GitHub repository or contact the maintainer.

---

**Made with ❤️ using Flutter**
