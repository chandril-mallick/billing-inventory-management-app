import 'package:billing_app/presentation/sidebaroptions/customers.dart';
import 'package:billing_app/presentation/sidebaroptions/dashboard.dart';
import 'package:billing_app/presentation/sidebaroptions/newPurchase.dart';
import 'package:billing_app/presentation/sidebaroptions/newsale.dart';
import 'package:billing_app/presentation/sidebaroptions/products.dart';
import 'package:billing_app/presentation/sidebaroptions/purchases.dart';
import 'package:billing_app/presentation/sidebaroptions/sales.dart';
import 'package:billing_app/presentation/sidebaroptions/suppliers.dart';
import 'package:flutter/material.dart';

// Responsive Sidebar Widget
class ResponsiveSidebar extends StatefulWidget {
  final Function(int) onSelectPage;
  final int? currentPageIndex;

  const ResponsiveSidebar({
    super.key, 
    required this.onSelectPage,
    this.currentPageIndex,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return _buildMobileDrawer();
    }

    return _buildDesktopSidebar();
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildMobileHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildSidebarHeading("Main Navigation"),
                  const SizedBox(height: 20),
                  ..._buildAllMenuItems(isMobile: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nagerbazar Furniture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    double sidebarWidth = isCollapsed ? 70 : 240;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      color: Colors.black87,
      child: Column(
        children: [
          _buildDesktopHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (!isCollapsed) ...[
                  _buildSidebarHeading("Main Navigation"),
                  const SizedBox(height: 20),
                ],
                ..._buildAllMenuItems(isCollapsed: isCollapsed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white, size: 24),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.menu_open : Icons.menu,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                isCollapsed = !isCollapsed;
              });
            },
            tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllMenuItems({bool isCollapsed = false, bool isMobile = false}) {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'index': 0},
      {'icon': Icons.receipt_outlined, 'title': 'New Sale', 'index': 1},
      {'icon': Icons.receipt, 'title': 'Sales', 'index': 2},
      {'icon': Icons.inventory_2_outlined, 'title': 'New Purchase', 'index': 3},
      {'icon': Icons.inventory, 'title': 'Purchases', 'index': 4},
      {'icon': Icons.shop, 'title': 'Products', 'index': 5},
      {'icon': Icons.people, 'title': 'Customers', 'index': 6},
      {'icon': Icons.local_shipping, 'title': 'Suppliers', 'index': 7},
    ];

    return menuItems.map((item) => _buildSidebarItem(
      item['icon'] as IconData,
      item['title'] as String,
      item['index'] as int,
      isCollapsed: isCollapsed,
      isMobile: isMobile,
    )).toList();
  }

  Widget _buildSidebarItem(
    IconData icon, 
    String title, 
    int pageIndex, {
    bool isCollapsed = false,
    bool isMobile = false,
  }) {
    final isSelected = widget.currentPageIndex == pageIndex;

    if (isCollapsed) {
      return Tooltip(
        message: title,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(icon, color: isSelected ? Colors.blue : Colors.white),
            onPressed: () => widget.onSelectPage(pageIndex),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isSelected ? Colors.blue : Colors.white,
          size: isMobile ? 24 : 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white,
            fontSize: isMobile ? 16 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        onTap: () {
          widget.onSelectPage(pageIndex);
          if (isMobile) {
            Navigator.of(context).pop();
          }
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 12,
          vertical: isMobile ? 8 : 4,
        ),
        minLeadingWidth: isMobile ? 32 : 24,
        dense: !isMobile,
      ),
    );
  }

  Widget _buildSidebarHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

// Updated Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    DashboardGrid(),
    NewSale(),
    const Sales(),
    NewPurchaseScreen(),
    const Purchases(),
    const Products(),
    const Customers(),
    const Suppliers(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'New Sale',
    'Sales',
    'New Purchase',
    'Purchases',
    'Products',
    'Customers',
    'Suppliers',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            _pageTitles[_currentIndex],
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (String value) {
                switch (value) {
                  case 'contact':
                    // Handle contact action
                    break;
                  case 'logout':
                    // Handle logout action
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'contact',
                  child: Text('Contact'),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
        drawer: ResponsiveSidebar(
          onSelectPage: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentPageIndex: _currentIndex,
        ),
        body: _pages[_currentIndex],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Nagerbazar Furniture & Interiors',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              // Handle contact action
            },
            child: const Text(
              'Contact',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              // Handle logout action
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          ResponsiveSidebar(
            onSelectPage: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            currentPageIndex: _currentIndex,
          ),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
    );
  }
}