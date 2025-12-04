import 'package:flutter/material.dart';

class TermOfServicePage extends StatelessWidget {
  static const String routeName = '/term-of-service';

  const TermOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated march 12,2012',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Introduction
                  _buildSection(
                    title: 'Introduction',
                    content:
                        'Our app brings together three powerful features to elevate your digital experience. Enjoy seamless YouTube viewing, stay informed with curated news articles, and explore interactive 3D models—all in one place. Designed for convenience and versatility, it\'s your all-in-one hub for learning, entertainment, and discovery.',
                  ),
                  const SizedBox(height: 24),
                  // Disclaimer
                  _buildSection(
                    title: 'Disclaimer',
                    content:
                        'Developed by TTTL Studio, this app combines three essential features to enhance your digital experience. Watch YouTube effortlessly, read curated news, and explore interactive 3D models—all in one seamless platform. With a focus on simplicity and performance, TTTL Studio delivers a reliable and modern tool for learning, entertainment, and discovery.',
                  ),
                  const SizedBox(height: 24),
                  // Copyright Notice
                  _buildCopyrightSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Agree Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Agree',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyrightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Copyright Notice',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '© 2025 TTTL Studio. All rights reserved.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This application is developed solely for educational purposes as part of a university course project.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All YouTube content displayed within the app is owned by their respective creators and streamed directly through official YouTube APIs.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All news content belongs to their original publishers.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All 3D models loaded into the app remain the property of their respective owners unless otherwise stated.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No part of this application may be reproduced, distributed, or used for commercial purposes without permission from the developer(s).',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
