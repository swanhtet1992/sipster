import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double current;
  final double goal;
  final double kidneyLoad;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.current,
    required this.goal,
    required this.kidneyLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${current.round()}ml / ${goal.round()}ml',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
            ),
            
            const SizedBox(height: 8),
            Text(
              '${progress.round()}% complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            
            if (kidneyLoad > 50) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kidney Load: ${kidneyLoad.round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: kidneyLoad / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  kidneyLoad > 80 ? Colors.red : Colors.orange,
                ),
                minHeight: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }
}