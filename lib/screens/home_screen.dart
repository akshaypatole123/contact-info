import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'contacts_screen.dart';
import 'favorites_screen.dart';
import '../routes/app_router.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RxInt _currentIndex = 0.obs;

  final List<Widget> _screens = [
    const ContactsScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() => AnimatedSwitcher(
            duration: AppConstants.durationNormal,
            child: _screens[_currentIndex.value],
          )),
      
      // Bottom Navigation Bar (Material 3 NavigationBar)
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: _currentIndex.value,
            onDestinationSelected: (index) {
              _currentIndex.value = index;
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.contacts_outlined),
                selectedIcon: Icon(Icons.contacts),
                label: 'Contacts',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_outline_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Favorites',
              ),
            ],
          )),
      
      // Floating Action Button to create contact
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add contact form
          Get.toNamed(AppRoutes.addEdit);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
