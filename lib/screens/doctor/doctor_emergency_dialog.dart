import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DoctorEmergencyDialog extends StatefulWidget {
  const DoctorEmergencyDialog({super.key});

  @override
  State<DoctorEmergencyDialog> createState() => _DoctorEmergencyDialogState();
}

class _DoctorEmergencyDialogState extends State<DoctorEmergencyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.emergencyLight,
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.emergencyDark,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text(
            'Declare Emergency',
            style: TextStyle(
              color: AppColors.emergencyDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will immediately:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Set your status to Emergency\n'
              '• Reschedule all upcoming appointments\n'
              '• Notify affected patients',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _reasonController,
              label: 'Emergency Reason',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a reason';
                }
                if (value.length < 10) {
                  return 'Please provide more details';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        CustomButton(
          text: 'Declare Emergency',
          onPressed: _isLoading ? null : () => _confirmEmergency(context),
          isLoading: _isLoading,
          backgroundColor: AppColors.emergencyDark,
          width: 150,
        ),
      ],
    );
  }

  void _confirmEmergency(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Return the emergency reason to the parent
    Navigator.of(context).pop(_reasonController.text.trim());
  }
}
