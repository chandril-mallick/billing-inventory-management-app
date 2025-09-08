import 'package:flutter/material.dart';

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
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    // Auto-collapse on mobile and tablet
    if (isMobile) {
      return _buildMobileDrawer();
    }

    // Desktop and tablet sidebar
    return _buildDesktopSidebar(isTablet: isTablet, isDesktop: isDesktop);
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
              'Billing App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildDesktopSidebar({required bool isTablet, required bool isDesktop}) {
    double sidebarWidth = isCollapsed 
        ? 70 
        : isTablet 
            ? 200 
            : 240;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      color: Colors.black87,
      child: Column(
        children: [
          _buildDesktopHeader(sidebarWidth),
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

  Widget _buildDesktopHeader(double width) {
    return Container(
      width: width,
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
                'Billing App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
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
            Navigator.of(context).pop(); // Close drawer on mobile
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

// Usage example for your main layout
class ResponsiveLayout extends StatefulWidget {
  final Widget child;
  final Function(int) onSelectPage;
  final int currentPageIndex;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.onSelectPage,
    required this.currentPageIndex,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text('Billing App', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: ResponsiveSidebar(
          onSelectPage: widget.onSelectPage,
          currentPageIndex: widget.currentPageIndex,
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          ResponsiveSidebar(
            onSelectPage: widget.onSelectPage,
            currentPageIndex: widget.currentPageIndex,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}