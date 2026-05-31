import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/contact_model.dart';
import '../controllers/contact_controller.dart';
import '../utils/constants.dart';
import '../routes/app_router.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final ContactController controller;

  const ContactTile({
    super.key,
    required this.contact,
    required this.controller,
  });

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = contact.imagePath != null && contact.imagePath!.isNotEmpty;

    // Get color for initials avatar based on character
    final Color avatarColor = _getAvatarColor(contact.name);

    return InkWell(
      onTap: () {
        // Clear picked image state and go to detail
        controller.selectedImagePath.value = contact.imagePath ?? '';
        Get.toNamed(AppRoutes.detail, arguments: contact);
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS + 2,
        ),
        child: Row(
          children: [
            // Left Profile Picture / Initials Avatar
            Hero(
              tag: 'contact_avatar_${contact.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasImage ? Colors.transparent : avatarColor.withAlpha(204),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
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
                                  fontSize: 18,
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
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ),
            AppConstants.horizontalSpaceM,
            
            // Middle Name & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppConstants.verticalSpaceXS,
                  Text(
                    contact.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Right Favorite Star Icon
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.amber.shade700 : colorScheme.onSurfaceVariant.withAlpha(128),
              ),
              onPressed: () {
                controller.toggleFavoriteStatus(contact);
              },
            ),
          ],
        ),
      ),
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
    // Custom beautiful tones
    final list = [
      const Color(0xFFE53935), // Red
      const Color(0xFFD81B60), // Pink
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF5E35B1), // Deep Purple
      const Color(0xFF3949AB), // Indigo
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFF00897B), // Teal
      const Color(0xFF43A047), // Green
      const Color(0xFF7CB342), // Light Green
      const Color(0xFFF4511E), // Deep Orange
      const Color(0xFF6D4C41), // Brown
      const Color(0xFF546E7A), // Blue Grey
    ];
    return list[char % list.length];
  }
}
