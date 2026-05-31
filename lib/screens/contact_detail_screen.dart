import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/contact_controller.dart';
import '../models/contact_model.dart';
import '../routes/app_router.dart';
import '../utils/constants.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ContactController controller = Get.find<ContactController>();
    
    // Retrieve passed Contact from arguments
    final Contact contactArg = Get.arguments as Contact;

    // Reactively find the contact in case its state changed (e.g. edited or favorited)
    return Obx(() {
      // Look up current contact in state list to keep details fresh
      final contact = controller.contacts.firstWhere(
        (c) => c.id == contactArg.id, 
        orElse: () => contactArg,
      );

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final hasImage = contact.imagePath != null && contact.imagePath!.isNotEmpty;
      final Color avatarColor = _getAvatarColor(contact.name);

      return Scaffold(
        appBar: AppBar(
          actions: [
            // Favorite Button
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.amber.shade700 : colorScheme.onSurface,
              ),
              onPressed: () => controller.toggleFavoriteStatus(contact),
            ),
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Pre-populate picked image state
                controller.selectedImagePath.value = contact.imagePath ?? '';
                Get.toNamed(AppRoutes.addEdit, arguments: contact);
              },
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, controller, contact),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppConstants.verticalSpaceM,
              
              // Top Profile Card (Large Photo / Initials)
              Center(
                child: Column(
                  children: [
                    Hero(
                      tag: 'contact_avatar_${contact.id}',
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasImage ? Colors.transparent : avatarColor.withAlpha(204),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
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
                                          fontSize: 48,
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
                                    fontSize: 48,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    AppConstants.verticalSpaceM,
                    
                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                      child: Text(
                        contact.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              AppConstants.verticalSpaceL,

              // Quick Actions Row (Call, Text, Email)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    icon: Icons.call_outlined,
                    label: 'Call',
                    onPressed: () => controller.makeCall(contact.phone),
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _buildQuickAction(
                    icon: Icons.message_outlined,
                    label: 'Text',
                    onPressed: () => _sendSms(contact.phone),
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _buildQuickAction(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onPressed: contact.email.isNotEmpty 
                        ? () => controller.sendEmail(contact.email)
                        : null,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                ],
              ),
              AppConstants.verticalSpaceXL,
              
              // Contact Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact info',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        AppConstants.verticalSpaceM,
                        
                        // Phone Detail
                        _buildDetailTile(
                          icon: Icons.phone_outlined,
                          title: contact.phone,
                          subtitle: 'Mobile',
                          trailing: IconButton(
                            icon: const Icon(Icons.message_outlined),
                            onPressed: () => _sendSms(contact.phone),
                          ),
                          onTap: () => controller.makeCall(contact.phone),
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                        
                        if (contact.email.isNotEmpty) ...[
                          const Divider(),
                          // Email Detail
                          _buildDetailTile(
                            icon: Icons.email_outlined,
                            title: contact.email,
                            subtitle: 'Email',
                            onTap: () => controller.sendEmail(contact.email),
                            theme: theme,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    final isEnabled = onPressed != null;
    final color = isEnabled ? colorScheme.primary : colorScheme.onSurface.withAlpha(76);

    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(12),
          ),
          icon: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isEnabled ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(76),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(128),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _sendSms(String phone) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'\s+\(\)-'), '');
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: sanitizedPhone,
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      Get.snackbar('SMS failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _confirmDelete(BuildContext context, ContactController controller, Contact contact) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteContact(contact.id!);
              Get.back(); // close dialog
              Get.back(); // return to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
