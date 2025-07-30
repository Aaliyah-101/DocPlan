import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/medical_record_service.dart';
import '../../services/storage_service.dart';
import '../../models/medical_record_model.dart';
import '../../widgets/gradient_background.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final AuthService _authService = AuthService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  // ignore: unused_field
  final StorageService _storageService = StorageService();

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Diagnosis',
    'Prescription',
    'Test Result',
  ];

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(
            color: AppColors.docplanBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: GradientBackground(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Filter: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      underline: const SizedBox(),
                      items: _filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Medical Records List
            Expanded(
              child: user == null
                  ? const Center(
                      child: Text('Please log in to view medical records'),
                    )
                  : StreamBuilder<List<MedicalRecordModel>>(
                      stream: _medicalRecordService.getPatientMedicalRecords(
                        user.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No medical records found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Your medical records will appear here',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final records = snapshot.data!;
                        final filteredRecords = _selectedFilter == 'All'
                            ? records
                            : records
                                  .where(
                                    (record) =>
                                        record.type.toLowerCase() ==
                                        _selectedFilter.toLowerCase(),
                                  )
                                  .toList();

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            return _buildMedicalRecordCard(record);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecordModel record) {
    IconData iconData;
    Color iconColor;

    switch (record.type.toLowerCase()) {
      case 'diagnosis':
        iconData = Icons.medical_services;
        iconColor = AppColors.primary;
        break;
      case 'prescription':
        iconData = Icons.medication;
        iconColor = AppColors.accent;
        break;
      case 'test_result':
        iconData = Icons.science;
        iconColor = AppColors.docplanBlue;
        break;
      default:
        iconData = Icons.description;
        iconColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        record.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.description,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            if (record.doctorName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Doctor: ${record.doctorName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (record.attachments != null &&
                record.attachments!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: record.attachments!.map((attachment) {
                  return Chip(
                    label: const Text('Attachment'),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMedicalRecordDialog(),
    );
  }
}

class AddMedicalRecordDialog extends StatefulWidget {
  const AddMedicalRecordDialog({super.key});

  @override
  State<AddMedicalRecordDialog> createState() => _AddMedicalRecordDialogState();
}

class _AddMedicalRecordDialogState extends State<AddMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Diagnosis';
  bool _isLoading = false;

  final List<String> _recordTypes = [
    'Diagnosis',
    'Prescription',
    'Test Result',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not logged in');

      final userModel = await AuthService().getUserData(user.uid);
      if (userModel == null) throw Exception('User data not found');

      final recordId = FirebaseFirestore.instance
          .collection('medical_records')
          .doc()
          .id;

      final record = MedicalRecordModel(
        id: recordId,
        patientId: user.uid,
        patientName: userModel.name,
        date: DateTime.now(),
        type: _selectedType.toLowerCase(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      await MedicalRecordService().createMedicalRecord(record);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medical Record'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Record Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Record Type',
                border: OutlineInputBorder(),
              ),
              items: _recordTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addRecord,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
