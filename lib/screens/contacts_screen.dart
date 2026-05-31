import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';
import '../models/contact_model.dart';
import '../widgets/contact_tile.dart';
import '../widgets/empty_state.dart';
import '../utils/constants.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ContactController controller = Get.find<ContactController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Styled Search Bar (Google Contacts style)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Card(
                elevation: 0,
                color: theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                      AppConstants.horizontalSpaceM,
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => controller.filterContacts(value),
                          decoration: InputDecoration(
                            hintText: 'Search contacts',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withAlpha(153),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingM,
                            ),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              controller.filterContacts('');
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
            
            // List of Contacts
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.contacts.isEmpty) {
                  return EmptyState(
                    icon: Icons.contact_phone_outlined,
                    title: 'No contacts yet',
                    description: 'Contacts you add will appear here.',
                  );
                }

                if (controller.filteredContacts.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No search results',
                    description: 'No contacts matching "${controller.searchQuery.value}" were found.',
                  );
                }

                // Process contacts into alphabetical sections
                final listItems = _buildAlphabeticalList(controller.filteredContacts);

                return RefreshIndicator(
                  onRefresh: () => controller.loadContacts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 80, // Space for FAB
                      left: AppConstants.paddingS,
                      right: AppConstants.paddingS,
                    ),
                    itemCount: listItems.length,
                    itemBuilder: (context, index) {
                      final item = listItems[index];
                      if (item is String) {
                        // Section Header Letter
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: AppConstants.paddingM + 4,
                            top: AppConstants.paddingM,
                            bottom: AppConstants.paddingS,
                          ),
                          child: Text(
                            item,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (item is Contact) {
                        return ContactTile(
                          contact: item,
                          controller: controller,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Create an ordered, flat list containing letters (headers) and Contact models
  List<dynamic> _buildAlphabeticalList(List<Contact> list) {
    final Map<String, List<Contact>> grouped = {};
    for (var contact in list) {
      if (contact.name.trim().isEmpty) continue;
      final String firstLetter = contact.name.trim()[0].toUpperCase();
      final String key = RegExp(r'[A-Z]').hasMatch(firstLetter) ? firstLetter : '#';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(contact);
    }

    final List<dynamic> flatList = [];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == '#') return 1;
        if (b == '#') return -1;
        return a.compareTo(b);
      });

    for (var key in sortedKeys) {
      flatList.add(key); // Letter title
      flatList.addAll(grouped[key]!); // Contacts
    }
    return flatList;
  }
}
