import 'package:flutter/material.dart';

class RoleCreationScreen extends StatelessWidget {
  const RoleCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Role Creation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildRoleCard(
                      icon: Icons.home,
                      label: 'Camp Admin',
                      onTap: () {},
                    ),
                    _buildRoleCard(
                      icon: Icons.layers,
                      label: 'Collection Point Admin',
                      onTap: () {},
                    ),
                    _buildRoleCard(
                      icon: Icons.trending_up,
                      label: 'Statistics',
                      onTap: () {},
                    ),
                    _buildRoleCard(
                      icon: Icons.person_check,
                      label: 'KAS',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// For custom house icon that more closely matches the design
class CustomIcons {
  static IconData campHouse = Icons.home;
  static IconData layers = Icons.layers;
  static IconData stats = Icons.trending_up;
  static IconData personCheck = Icons.person_check;
}