import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/contact_model.dart';

class ContactController extends GetxController {
  // Database Helper Instance
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Reactive State variables
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> filteredContacts = <Contact>[].obs;
  final RxList<Contact> favorites = <Contact>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Picked image state for Add/Edit contact
  final RxString selectedImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  // Load all contacts from SQLite
  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      final rawContacts = await _dbHelper.getAllContacts();
      contacts.assignAll(rawContacts);
      
      // Update favorites
      favorites.assignAll(rawContacts.where((c) => c.isFavorite).toList());
      
      // Apply existing search filter if any
      filterContacts(searchQuery.value);
    } catch (e) {
      showErrorSnackbar('Error loading contacts', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filter contacts based on search query
  void filterContacts(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredContacts.assignAll(contacts);
    } else {
      final lowercaseQuery = query.toLowerCase();
      filteredContacts.assignAll(
        contacts.where((contact) {
          final matchesName = contact.name.toLowerCase().contains(lowercaseQuery);
          final matchesPhone = contact.phone.contains(lowercaseQuery);
          final matchesEmail = contact.email.toLowerCase().contains(lowercaseQuery);
          return matchesName || matchesPhone || matchesEmail;
        }).toList(),
      );
    }
  }

  // Add a new contact
  Future<bool> addContact({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      isSaving.value = true;
      String? savedImagePath;

      if (selectedImagePath.value.isNotEmpty) {
        savedImagePath = await _saveImagePermanently(selectedImagePath.value);
      }

      final newContact = Contact(
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        imagePath: savedImagePath,
        isFavorite: false,
      );

      await _dbHelper.insertContact(newContact);
      await loadContacts();
      showSuccessSnackbar('Success', 'Contact added successfully');
      selectedImagePath.value = ''; // Reset path
      return true;
    } catch (e) {
      showErrorSnackbar('Error saving contact', e.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update an existing contact
  Future<bool> updateContactDetail(Contact contact, {
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      isSaving.value = true;
      String? savedImagePath = contact.imagePath;

      // If the selected image path is new and different from existing one
      if (selectedImagePath.value.isNotEmpty && selectedImagePath.value != contact.imagePath) {
        savedImagePath = await _saveImagePermanently(selectedImagePath.value);
      } else if (selectedImagePath.value.isEmpty) {
        // If image was cleared
        savedImagePath = null;
      }

      final updated = contact.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        imagePath: savedImagePath,
      );

      await _dbHelper.updateContact(updated);
      await loadContacts();
      showSuccessSnackbar('Success', 'Contact updated successfully');
      selectedImagePath.value = ''; // Reset path
      return true;
    } catch (e) {
      showErrorSnackbar('Error updating contact', e.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete contact
  Future<void> deleteContact(int id) async {
    try {
      isLoading.value = true;
      await _dbHelper.deleteContact(id);
      await loadContacts();
      showSuccessSnackbar('Success', 'Contact deleted successfully');
    } catch (e) {
      showErrorSnackbar('Error deleting contact', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite status
  Future<void> toggleFavoriteStatus(Contact contact) async {
    try {
      final newFavoriteStatus = !contact.isFavorite;
      await _dbHelper.toggleFavorite(contact.id!, newFavoriteStatus);
      await loadContacts();
      
      showSuccessSnackbar(
        newFavoriteStatus ? 'Added to Favorites' : 'Removed from Favorites',
        '${contact.name} has been updated.',
      );
    } catch (e) {
      showErrorSnackbar('Error toggling favorite', e.toString());
    }
  }

  // Image Selection logic
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      showErrorSnackbar('Error picking image', e.toString());
    }
  }

  void clearSelectedImage() {
    selectedImagePath.value = '';
  }

  // Helper to save chosen image into App Documents directory to survive cache cleared
  Future<String?> _saveImagePermanently(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = p.basename(imagePath);
      
      // Ensure folder exists and copy image
      final saveFolder = Directory('${directory.path}/contact_photos');
      if (!await saveFolder.exists()) {
        await saveFolder.create(recursive: true);
      }

      final imageFile = File(imagePath);
      final File savedImage = await imageFile.copy('${saveFolder.path}/$filename');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image permanently: $e');
      return imagePath; // Fallback to temp path
    }
  }

  // URL Launcher triggers
  Future<void> makeCall(String phoneNumber) async {
    final sanitizedPhone = phoneNumber.replaceAll(RegExp(r'\s+\(\)-'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: sanitizedPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch dialer for $sanitizedPhone';
      }
    } catch (e) {
      showErrorSnackbar('Calling failed', e.toString());
    }
  }

  Future<void> sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch mail client for $emailAddress';
      }
    } catch (e) {
      showErrorSnackbar('Email failed', e.toString());
    }
  }

  // Snackbars for UI feedback
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode ? Colors.green.shade900 : Colors.green.shade100,
      colorText: Get.isDarkMode ? Colors.green.shade50 : Colors.green.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode ? Colors.red.shade900 : Colors.red.shade100,
      colorText: Get.isDarkMode ? Colors.red.shade50 : Colors.red.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
