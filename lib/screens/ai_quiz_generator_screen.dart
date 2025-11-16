import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';

class AIQuizGeneratorScreen extends StatelessWidget {
  const AIQuizGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quiz Generator'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.s5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 120,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              SizedBox(height: spacing.s5),
              Text(
                'Coming Soon!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.s3),
              Text(
                'AI-Powered Quiz Generator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.s4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s4),
                child: Text(
                  'Upload your study materials and let our AI (powered by Gemini) generate custom quiz questions for you!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing.s5),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(spacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: spacing.s2),
                          Text(
                            'Features:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.s3),
                      _buildFeatureItem(context, 'Upload PDFs, text files, or images'),
                      _buildFeatureItem(context, 'AI generates relevant questions'),
                      _buildFeatureItem(context, 'Automatic answer validation'),
                      _buildFeatureItem(context, 'Save quizzes for offline use'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
