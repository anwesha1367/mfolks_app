import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'About MFolks',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.teal.shade900,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            // Intro card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Who we are',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'MFolks is a modern metals marketplace and tooling suite built for procurement teams, fabricators, and suppliers. We simplify sourcing, offer transparent pricing, and provide tools like live analytics and a professional metal calculator to help you work faster and smarter.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mission & Values
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoCard(
                  title: 'Our Mission',
                  description:
                      'To streamline the metals supply chain with technology, data, and delightful user experiences.',
                  icon: Icons.flag_outlined,
                ),
                _InfoCard(
                  title: 'Our Values',
                  description:
                      'Transparency, reliability, and continuous improvement. We believe great partnerships are built on trust and results.',
                  icon: Icons.handshake_outlined,
                ),
                _InfoCard(
                  title: 'What We Offer',
                  description:
                      'Live market insights, accurate calculators, simple ordering, and tools that save your team time every day.',
                  icon: Icons.insights_outlined,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _StatTile(label: 'Partners', value: '250+'),
                _StatTile(label: 'Orders Delivered', value: '10k+'),
                _StatTile(label: 'On-time Delivery', value: '98.6%'),
              ],
            ),

            const SizedBox(height: 16),

            // Contact
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.email_outlined, color: Colors.teal),
                        SizedBox(width: 8),
                        Expanded(child: Text('support@mfolks.app')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.phone_outlined, color: Colors.teal),
                        SizedBox(width: 8),
                        Expanded(child: Text('+91 98765 43210')),
                      ],
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
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  const _InfoCard({required this.title, required this.description, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 900
          ? (MediaQuery.of(context).size.width - 16 * 2 - 12 * 2) / 3
          : MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.teal.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(description),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 900
          ? (MediaQuery.of(context).size.width - 16 * 2 - 12 * 2) / 3
          : MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}


