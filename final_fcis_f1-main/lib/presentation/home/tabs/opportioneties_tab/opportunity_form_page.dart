import 'package:flutter/material.dart';
import '../../../../core/utils/colors_manager.dart';
//import '../components/models.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart';

class OpportunityFormPage extends StatefulWidget {
  @override
  _OpportunityFormPageState createState() => _OpportunityFormPageState();
}

class _OpportunityFormPageState extends State<OpportunityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  String _jobType = 'Full-Time';
  String _category = opportunityCategories.first;

  @override
  void dispose() {
    _companyNameController.dispose();
    _websiteController.dispose();
    _contactEmailController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _qualificationsController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backGroundColor,
        title: const Text(
          'Submit Opportunity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_companyNameController, 'Company Name',
                  isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_websiteController, 'Website (https://...)',
                  isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_contactEmailController, 'Contact Email',
                  isRequired: true, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_jobTitleController, 'Job Title',
                  isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Job Description',
                  isRequired: true, maxLines: 5),
              const SizedBox(height: 16),
              _buildTextField(_skillsController, 'Required Skills',
                  isRequired: true, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_qualificationsController, 'Qualifications',
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_locationController, 'Location',
                  isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_salaryController, 'Salary/Compensation',
                  isRequired: true),
              const SizedBox(height: 24),
              _buildDropdownSelector(
                label: 'Job Type',
                value: _jobType,
                items: const ['Full-Time', 'Part-Time', 'Internship', 'Remote'],
                onChanged: (value) => setState(() => _jobType = value!),
              ),
              const SizedBox(height: 24),
              _buildDropdownSelector(
                label: 'Category',
                value: _category,
                items: opportunityCategories,
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Submit Opportunity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (label.contains('Email') && !value.contains('@')) {
                return 'Please enter a valid email';
              }
              if (label.contains('Website') && !value.startsWith('http')) {
                return 'Please include http:// or https://';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownSelector({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final opportunityData = {
        'companyName': _companyNameController.text.trim(),
        'website': _websiteController.text.trim(),
        'contactEmail': _contactEmailController.text.trim(),
        'jobTitle': _jobTitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'skills': _skillsController.text.trim(),
        'qualifications': _qualificationsController.text.trim(),
        'location': _locationController.text.trim(),
        'salary': _salaryController.text.trim(),
        'jobType': _jobType,
        'category': _category,
        'type': 'opportunity',
        'timestamp': DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, opportunityData);
    }
  }
}
