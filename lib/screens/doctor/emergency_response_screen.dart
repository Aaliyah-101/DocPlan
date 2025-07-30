import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EmergencyResponseScreen extends StatefulWidget {
  final String appointmentId;
<<<<<<< HEAD

=======
>>>>>>> fik
  const EmergencyResponseScreen({super.key, required this.appointmentId});

  @override
  State<EmergencyResponseScreen> createState() => _EmergencyResponseScreenState();
}

class _EmergencyResponseScreenState extends State<EmergencyResponseScreen> {
  bool isLoading = true;
  bool isAcknowledged = false;
  bool isResolved = false;
  bool isAckLoading = false;
  bool isResolveLoading = false;
  Map<String, dynamic>? emergencyData;
  String? error;

<<<<<<< HEAD
=======
  // Modern gradient color scheme
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyRedDark = Color(0xFFB71C1C);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successGreenLight = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFEF6C00);
  static const Color warningAmberLight = Color(0xFFFF9800);

  // Background and card colors
  static const Color backgroundGradientStart = Color(0xFFF0F4F8);
  static const Color backgroundGradientEnd = Color(0xFFE8F4F8);
  static const Color cardBackground = Color(0xFFFAFBFC);
  static const Color cardSecondary = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentTeal = Color(0xFF00ACC1);

>>>>>>> fik
  @override
  void initState() {
    super.initState();
    loadEmergencyDetails();
  }

  Future<void> loadEmergencyDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });
<<<<<<< HEAD

=======
>>>>>>> fik
    try {
      final res = await http.get(
        Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}'),
      );
<<<<<<< HEAD

=======
>>>>>>> fik
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          emergencyData = data;
          isAcknowledged = data['status'] == 'acknowledged' || data['status'] == 'resolved';
          isResolved = data['status'] == 'resolved';
          isLoading = false;
        });
      } else {
        setState(() {
<<<<<<< HEAD
          error = '❌ Failed to load emergency.';
=======
          error = 'Failed to load emergency details';
>>>>>>> fik
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
<<<<<<< HEAD
        error = '❌ Error: $e';
=======
        error = 'Network error occurred';
>>>>>>> fik
        isLoading = false;
      });
    }
  }

  Future<void> handleAcknowledge() async {
    setState(() => isAckLoading = true);
    final res = await http.post(
      Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/acknowledge'),
    );
<<<<<<< HEAD

=======
>>>>>>> fik
    if (res.statusCode == 200) {
      setState(() {
        isAcknowledged = true;
        isAckLoading = false;
      });
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Emergency acknowledged")),
      );
    } else {
      setState(() => isAckLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to acknowledge")),
      );
=======
      _showSuccessSnackBar("Emergency acknowledged successfully");
    } else {
      setState(() => isAckLoading = false);
      _showErrorSnackBar("Failed to acknowledge emergency");
>>>>>>> fik
    }
  }

  Future<void> handleResolve() async {
<<<<<<< HEAD
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to resolve this emergency?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );

=======
    final confirmed = await _showConfirmationDialog();
>>>>>>> fik
    if (confirmed == true) {
      setState(() => isResolveLoading = true);
      final res = await http.post(
        Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/resolve'),
      );
<<<<<<< HEAD

=======
>>>>>>> fik
      if (res.statusCode == 200) {
        setState(() {
          isResolved = true;
          isResolveLoading = false;
        });
<<<<<<< HEAD

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Emergency resolved")),
        );

        await Future.delayed(const Duration(seconds: 3));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => isResolveLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to resolve")),
        );
=======
        _showSuccessSnackBar("Emergency resolved successfully");
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => isResolveLoading = false);
        _showErrorSnackBar("Failed to resolve emergency");
>>>>>>> fik
      }
    }
  }

<<<<<<< HEAD
=======
  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [warningAmber.withOpacity(0.1), warningAmberLight.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [warningAmber, warningAmberLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Confirm Resolution",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Are you sure you want to mark this emergency as resolved? This action cannot be undone.",
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [emergencyRed, emergencyRedDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: emergencyRed.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: emergencyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

>>>>>>> fik
  String formatTimestamp(Map<String, dynamic> timestamp) {
    try {
      final seconds = timestamp['_seconds'];
      final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
<<<<<<< HEAD
      return DateFormat('MMMM d, yyyy – h:mm a').format(date.toLocal());
=======
      return DateFormat('MMMM d, yyyy • h:mm a').format(date.toLocal());
>>>>>>> fik
    } catch (e) {
      return "Invalid date";
    }
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("🚨 Emergency Response"),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            onPressed: loadEmergencyDetails,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
          : emergencyData == null
          ? const Center(child: Text("No emergency data found."))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🚑 Emergency Assigned",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 20),

            infoRow(Icons.person, "Patient: ${emergencyData!['patientName'] ?? 'Unknown'}"),
            infoRow(Icons.info_outline, "Reason: ${emergencyData!['reason']}"),
            infoRow(Icons.note_alt_outlined, "Notes: ${emergencyData!['notes'] ?? 'None'}"),
            infoRow(Icons.access_time_filled, "Started: ${formatTimestamp(emergencyData!['dateTime'])}"),

            const SizedBox(height: 30),

            if (!isAcknowledged)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isAckLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.verified),
                  label: const Text("Acknowledge Emergency"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isAckLoading ? null : handleAcknowledge,
                ),
              ),

            const SizedBox(height: 12),

            if (!isResolved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isResolveLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.check_circle),
                  label: const Text("Resolve Emergency"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isResolveLoading ? null : handleResolve,
                ),
              ),

            if (isResolved)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "✅ Emergency has been resolved.",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
=======
  Widget _buildStatusChip() {
    String status = emergencyData!['status'] ?? 'pending';
    List<Color> gradientColors;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'resolved':
        gradientColors = [successGreen, successGreenLight];
        icon = Icons.check_circle;
        label = 'Resolved';
        break;
      case 'acknowledged':
        gradientColors = [warningAmber, warningAmberLight];
        icon = Icons.visibility;
        label = 'Acknowledged';
        break;
      default:
        gradientColors = [emergencyRed, emergencyRedDark];
        icon = Icons.priority_high;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundGradientStart, backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, deepBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medical_services, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Emergency Response",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: loadEmergencyDetails,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        tooltip: "Refresh",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body Content
            Expanded(
              child: isLoading
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue.withOpacity(0.1), lightBlue.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Loading emergency details...",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please wait while we fetch the information",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : error != null
                  ? Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [emergencyRed.withOpacity(0.1), emergencyRedDark.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.error_outline, color: emergencyRed, size: 48),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Error Loading Emergency",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: TextStyle(color: textSecondary, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, deepBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: loadEmergencyDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : emergencyData == null
                  ? const Center(child: Text("No emergency data found"))
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardBackground, cardSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [emergencyRed.withOpacity(0.1), emergencyRedDark.withOpacity(0.1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: emergencyRed.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.emergency,
                                  color: emergencyRed,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Emergency Alert",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatusChip(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Details Card with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardBackground, cardSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryBlue.withOpacity(0.1), lightBlue.withOpacity(0.1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.info_outline, color: primaryBlue, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Emergency Details",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow(
                            Icons.person_outline,
                            "Patient",
                            emergencyData!['patientName'] ?? 'Unknown',
                          ),
                          _buildDetailRow(
                            Icons.info_outline,
                            "Reason",
                            emergencyData!['reason'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            Icons.note_alt_outlined,
                            "Notes",
                            emergencyData!['notes'] ?? 'No additional notes',
                          ),
                          _buildDetailRow(
                            Icons.access_time,
                            "Started",
                            formatTimestamp(emergencyData!['dateTime']),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    if (!isResolved) ...[
                      if (!isAcknowledged)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [warningAmber, warningAmberLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: warningAmber.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: isAckLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.visibility, size: 22),
                            label: Text(
                              isAckLoading ? "Acknowledging..." : "Acknowledge Emergency",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: isAckLoading ? null : handleAcknowledge,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [emergencyRed, emergencyRedDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: emergencyRed.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: isResolveLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.check_circle, size: 22),
                          label: Text(
                            isResolveLoading ? "Resolving..." : "Resolve Emergency",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isResolveLoading ? null : handleResolve,
                        ),
                      ),
                    ],

                    if (isResolved)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [successGreen.withOpacity(0.1), successGreenLight.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: successGreen.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: successGreen.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [successGreen, successGreenLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Emergency Resolved",
                                    style: TextStyle(
                                      color: successGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "This emergency has been successfully resolved",
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
>>>>>>> fik
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
=======
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue.withOpacity(0.1), lightBlue.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: primaryBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
>>>>>>> fik
            ),
          ),
        ],
      ),
    );
  }
}
