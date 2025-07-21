import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyResponseScreen extends StatefulWidget {
  final String appointmentId;

  const EmergencyResponseScreen({super.key, required this.appointmentId});

  @override
  State<EmergencyResponseScreen> createState() => _EmergencyResponseScreenState();
}

class _EmergencyResponseScreenState extends State<EmergencyResponseScreen> {
  bool isLoading = true;
  bool isAcknowledged = false;
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
          isAcknowledged = data['status'] == 'acknowledged';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load emergency';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Something went wrong: $e';
        isLoading = false;
      });
    }
  }

  Future<void> handleAcknowledge() async {
    final res = await http.post(
      Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/acknowledge'),
    );

    if (res.statusCode == 200) {
      setState(() => isAcknowledged = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Emergency acknowledged")),
      );
    } else {
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
      final res = await http.post(
        Uri.parse('https://docplan-backend.onrender.com/api/emergencies/${widget.appointmentId}/resolve'),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Emergency resolved")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to resolve")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text("🚨 Emergency Response"),
        backgroundColor: Colors.red,
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
          ? Center(child: Text(error!))
          : emergencyData == null
          ? const Center(child: Text("No emergency data found."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🚑 Emergency Assigned",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.black54),
                const SizedBox(width: 8),
                Text("Patient: ${emergencyData!['patientName'] ?? 'Unknown'}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(child: Text("Reason: ${emergencyData!['reason']}")),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.black54),
                const SizedBox(width: 8),
                Text("Notes: ${emergencyData!['notes'] ?? 'None'}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                const SizedBox(width: 8),
                Text("Started: ${emergencyData!['dateTime']}"),
              ],
            ),
            const SizedBox(height: 30),
            if (!isAcknowledged)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.verified),
                  label: const Text("Acknowledge Emergency"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: handleAcknowledge,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Resolve Emergency"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: handleResolve,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
