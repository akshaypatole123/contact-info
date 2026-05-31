import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';
import '../models/contact_model.dart';
import '../widgets/avatar_picker.dart';
import '../utils/constants.dart';
import '../routes/app_router.dart';

class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({super.key});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final ContactController _controller = Get.find<ContactController>();

  // Text Editing Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Focus Nodes for smooth navigation
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  Contact? _editingContact;
  bool get _isEditMode => _editingContact != null;

  @override
  void initState() {
    super.initState();
    
    // Retrieve Contact from arguments if in Edit Mode
    if (Get.arguments is Contact) {
      _editingContact = Get.arguments as Contact;
    }

    // Initialize text controllers with existing data or empty values
    _nameController = TextEditingController(text: _editingContact?.name ?? '');
    _phoneController = TextEditingController(text: _editingContact?.phone ?? '');
    _emailController = TextEditingController(text: _editingContact?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  // Handle Form Submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success;
    if (_isEditMode) {
      success = await _controller.updateContactDetail(
        _editingContact!,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
    } else {
      success = await _controller.addContact(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
    }

    if (success) {
      // Navigate to home/contact list screen after successful save
      Get.offNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Contact' : 'Create Contact'),
        actions: [
          // AppBar Save Action Button
          Obx(() => _controller.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submitForm,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppConstants.verticalSpaceM,
                  
                  // Profile Photo Picker Component
                  AvatarPicker(
                    controller: _controller,
                    initialImagePath: _editingContact?.imagePath,
                  ),
                  AppConstants.verticalSpaceXL,
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'First & Last Name',
                      hintText: 'Enter contact name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name is too short';
                      }
                      return null;
                    },
                  ),
                  AppConstants.verticalSpaceM,
                  
                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      // Regular expression for validating international numbers
                      final phoneRegex = RegExp(r'^[+]*[0-9\s\-()]{7,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  AppConstants.verticalSpaceM,
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitForm(),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter email address (optional)',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null; // Email is optional
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  AppConstants.verticalSpaceXL,
                  
                  // Save Button at bottom (fallback)
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _controller.isSaving.value ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            elevation: 2,
                          ),
                          child: _controller.isSaving.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'Update Contact' : 'Save Contact',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
