import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';
import '../routes/app_router.dart';
import '../widgets/empty_state.dart';
import '../utils/constants.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ContactController controller = Get.find<ContactController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favorites.isEmpty) {
          return EmptyState(
            icon: Icons.star_outline_rounded,
            title: 'No favorites yet',
            description: 'Mark your important contacts as favorites to see them here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadContacts(),
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingM,
              AppConstants.paddingS,
              AppConstants.paddingM,
              80.0, // Floating space
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.paddingM,
              mainAxisSpacing: AppConstants.paddingM,
              childAspectRatio: 0.95,
            ),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final contact = controller.favorites[index];
              final hasImage = contact.imagePath != null && contact.imagePath!.isNotEmpty;
              final Color avatarColor = _getAvatarColor(contact.name);

              return GestureDetector(
                onTap: () {
                  controller.selectedImagePath.value = contact.imagePath ?? '';
                  Get.toNamed(AppRoutes.detail, arguments: contact);
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Card Content
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Circular Avatar
                              Hero(
                                tag: 'contact_avatar_${contact.id}',
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasImage ? Colors.transparent : avatarColor.withAlpha(204),
                                  ),
                                  child: hasImage
                                      ? ClipOval(
                                          child: Image.file(
                                            File(contact.imagePath!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  _getInitials(contact.name),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            _getInitials(contact.name),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              AppConstants.verticalSpaceM,
                              
                              // Contact Name
                              Text(
                                contact.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              // Contact Phone
                              Text(
                                contact.phone,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Positioned Call Quick Icon
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: IconButton(
                          icon: Icon(
                            Icons.call_outlined,
                            size: AppConstants.iconSizeS + 2,
                            color: colorScheme.primary,
                          ),
                          onPressed: () => controller.makeCall(contact.phone),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.blueGrey;
    final char = name.trim().toUpperCase().codeUnitAt(0);
    final list = [
      const Color(0xFFE53935),
      const Color(0xFFD81B60),
      const Color(0xFF8E24AA),
      const Color(0xFF5E35B1),
      const Color(0xFF3949AB),
      const Color(0xFF1E88E5),
      const Color(0xFF00ACC1),
      const Color(0xFF00897B),
      const Color(0xFF43A047),
      const Color(0xFF7CB342),
      const Color(0xFFF4511E),
      const Color(0xFF6D4C41),
      const Color(0xFF546E7A),
    ];
    return list[char % list.length];
  }
}
