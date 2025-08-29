import 'package:flutter/material.dart';
import '../models/hydration_session.dart';

class SessionControls extends StatelessWidget {
  final HydrationSession? currentSession;
  final List<String> containers;
  final Function(String) onSessionStart;
  final Function(double) onSessionEnd;
  final VoidCallback onSessionCancel;

  const SessionControls({
    super.key,
    required this.currentSession,
    required this.containers,
    required this.onSessionStart,
    required this.onSessionEnd,
    required this.onSessionCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hydration Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (currentSession == null)
              _buildStartSessionControls(context)
            else
              _buildActiveSessionControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSessionControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start drinking from:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: containers.map((container) {
            return ElevatedButton(
              onPressed: () => onSessionStart(container),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(container),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActiveSessionControls(BuildContext context) {
    final session = currentSession!;
    final elapsed = DateTime.now().difference(session.startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active: ${session.containerType}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target: ${session.targetMl.round()}ml',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                'Time: ${hours}h ${minutes}m',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'How much did you drink?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onSessionEnd(session.targetMl * 0.25),
                child: const Text('25%'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onSessionEnd(session.targetMl * 0.5),
                child: const Text('50%'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onSessionEnd(session.targetMl * 0.75),
                child: const Text('75%'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onSessionEnd(session.targetMl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('All'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCustomAmountDialog(context),
                child: const Text('Custom Amount'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onSessionCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    double? customAmount;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Amount'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => customAmount = double.tryParse(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (customAmount != null && customAmount! > 0) {
                Navigator.of(context).pop();
                onSessionEnd(customAmount!);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}