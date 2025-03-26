import 'package:flutter/material.dart';
import 'package:resq/utils/menu_list.dart';

class ResQMenu extends StatefulWidget {
  final List<String> roles; // Pass user roles to filter menu items
  final bool showDrawer; // Option to show drawer or not
  
  const ResQMenu({
    Key? key, 
    this.roles = const [], 
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<ResQMenu> createState() => _ResQMenuState();
}

class _ResQMenuState extends State<ResQMenu> {
  List<MenuItem> menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      // Get menu items filtered by user roles
      final items = getFilteredMenuItems(widget.roles);
      
      if (mounted) {
        setState(() {
          menuItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading menu items: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    // For wide screens, return a horizontal menu
    if (isWideScreen) {
      return _buildHorizontalMenu();
    }
    
    // For narrow screens, return a drawer if requested
    if (widget.showDrawer) {
      return _buildDrawer();
    }
    
    // Return empty if not showing drawer on narrow screens
    return const SizedBox.shrink();
  }

  Widget _buildHorizontalMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: menuItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, item.route);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, color: Colors.black),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 46),
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ResQ Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Navigate through available features',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ...menuItems.map((item) {
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: () {
                      // Close the drawer first
                      Navigator.pop(context);
                      // Then navigate
                      Navigator.pushNamed(context, item.route);
                    },
                  );
                }).toList(),
              ],
            ),
    );
  }
}