import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/contact_controller.dart';
import '../utils/constants.dart';

class AvatarPicker extends StatelessWidget {
  final ContactController controller;
  final String? initialImagePath;

  const AvatarPicker({
    super.key,
    required this.controller,
    this.initialImagePath,
  });

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Circular Avatar Display
          Obx(() {
            final path = controller.selectedImagePath.value;
            final hasPickedNew = path.isNotEmpty;
            final hasInitial = initialImagePath != null && initialImagePath!.isNotEmpty;

            ImageProvider? imageProvider;
            if (hasPickedNew) {
              imageProvider = FileImage(File(path));
            } else if (hasInitial) {
              imageProvider = FileImage(File(initialImagePath!));
            }

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.primary.withAlpha(51),
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imageProvider != null
                  ? ClipOval(
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
            );
          }),
          
          // Action Button to edit/add photo
          GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2.0,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: AppConstants.iconSizeS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppConstants.verticalSpaceM,
              Text(
                'Profile Photo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppConstants.verticalSpaceM,
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              Obx(() {
                final hasImage = controller.selectedImagePath.value.isNotEmpty ||
                    (initialImagePath != null && initialImagePath!.isNotEmpty);
                
                if (hasImage) {
                  return ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Get.back();
                      controller.clearSelectedImage();
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
