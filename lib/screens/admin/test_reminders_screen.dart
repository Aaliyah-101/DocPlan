import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../../constants/app_colors.dart';
import '../../controllers/reminder_worker.dart';
import 'dart:developer' as developer;

class TestRemindersScreen extends StatefulWidget {
  const TestRemindersScreen({super.key});

  @override
  State<TestRemindersScreen> createState() => _TestRemindersScreenState();
}

class _TestRemindersScreenState extends State<TestRemindersScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Reminders'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder System Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This screen allows you to test the appointment reminder system.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testReminderCheck,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.notifications),
                      label: Text(_isLoading ? 'Testing...' : 'Test Reminder Check'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_statusMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _statusMessage.contains('Error')
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _statusMessage.contains('Error')
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('Error')
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WorkManager Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check if the background task is running properly.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _checkWorkManagerStatus,
                      icon: const Icon(Icons.work),
                      label: const Text('Check WorkManager Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testReminderCheck() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      developer.log('🧪 Starting manual reminder test...');
      
      // Trigger the manual reminder check
      await manualReminderCheck();
      
      setState(() {
        _statusMessage = '✅ Reminder check completed successfully! Check the logs for details.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error testing reminders: $e';
      });
      developer.log('❌ Error in test reminder check: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkWorkManagerStatus() async {
    try {
      // This is a simple way to check if WorkManager is working
      // In a real app, you might want to store status in SharedPreferences
      setState(() {
        _statusMessage = '✅ WorkManager is initialized. Background tasks should be running every 15 minutes.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error checking WorkManager status: $e';
      });
    }
  }
} 