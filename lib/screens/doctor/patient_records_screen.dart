import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/medical_record_service.dart';
import '../../models/medical_record_model.dart';
import '../../widgets/gradient_background.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  // ignore: unused_field
  final AuthService _authService = AuthService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  final _searchController = TextEditingController();
  List<MedicalRecordModel> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Diagnosis',
    'Prescription',
    'Test Result',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPatients() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _medicalRecordService.searchMedicalRecords(
        _searchController.text.trim(),
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<MedicalRecordModel> get _filteredResults {
    if (_selectedFilter == 'All') return _searchResults;
    return _searchResults
        .where(
          (record) =>
              record.type.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Records',
          style: TextStyle(
            color: AppColors.docplanBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: GradientBackground(
        child: Column(
          children: [
            // Search Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by patient name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    onSubmitted: (_) => _searchPatients(),
                  ),
                  const SizedBox(height: 12),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _searchPatients,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isSearching ? 'Searching...' : 'Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter
                  Row(
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
                ],
              ),
            ),

            // Results Section
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Search for patient records',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enter a patient name to search their medical records',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : _filteredResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No records found for the selected filter',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredResults.length,
                      itemBuilder: (context, index) {
                        final record = _filteredResults[index];
                        return _buildMedicalRecordCard(record);
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
                        'Patient: ${record.patientName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.type,
                    style: TextStyle(
                      fontSize: 10,
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (record.doctorName != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'by ${record.doctorName}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
