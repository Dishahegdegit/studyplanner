import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7F3),
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Study Statistics",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Track your learning progress over time.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 70,
                      color: Colors.teal.shade700,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "No Statistics Available",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Complete study sessions to view your progress here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.timer,
                      "Study Hours",
                      "0 hrs",
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatCard(
                      Icons.task_alt,
                      "Completed",
                      "0",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.local_fire_department,
                      "Streak",
                      "0",
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatCard(
                      Icons.emoji_events,
                      "Achievements",
                      "0",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: Colors.teal,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}