import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EmergencyResponseScreen extends StatefulWidget {
  final String appointmentId;

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

    try {
      final res = await http.get(
        Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}'),
      );

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
          error = '❌ Failed to load emergency.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '❌ Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> handleAcknowledge() async {
    setState(() => isAckLoading = true);
    final res = await http.post(
      Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/acknowledge'),
    );

    if (res.statusCode == 200) {
      setState(() {
        isAcknowledged = true;
        isAckLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Emergency acknowledged")),
      );
    } else {
      setState(() => isAckLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to acknowledge")),
      );
    }
  }

  Future<void> handleResolve() async {
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

    if (confirmed == true) {
      setState(() => isResolveLoading = true);
      final res = await http.post(
        Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/resolve'),
      );

      if (res.statusCode == 200) {
        setState(() {
          isResolved = true;
          isResolveLoading = false;
        });

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
      }
    }
  }

  String formatTimestamp(Map<String, dynamic> timestamp) {
    try {
      final seconds = timestamp['_seconds'];
      final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return DateFormat('MMMM d, yyyy – h:mm a').format(date.toLocal());
    } catch (e) {
      return "Invalid date";
    }
  }

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
          ],
        ),
      ),
    );
  }

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
            ),
          ),
        ],
      ),
    );
  }
}
