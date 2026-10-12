import 'package:flutter/material.dart';

class VisualImpairmentSurveyPage extends StatefulWidget {
  const VisualImpairmentSurveyPage({super.key});

  @override
  _VisualImpairmentSurveyPageState createState() => _VisualImpairmentSurveyPageState();
}

class _VisualImpairmentSurveyPageState extends State<VisualImpairmentSurveyPage> {
  // Store selected visual impairment type
  String? _selectedImpairmentType;

  // List of visual impairment types
  final List<String> _impairmentTypes = [
    'Complete Blindness',
    'Partial Vision',
    'Low Vision',
    'Color Blindness',
    'Night Blindness',
    'Peripheral Vision Loss',
    'Other'
  ];

  // Handle the submission
  void _handleSubmit() {
    if (_selectedImpairmentType != null) {
      // Navigate to the next page or perform necessary action
      print('Selected Impairment: $_selectedImpairmentType');
      Navigator.pushNamed(context, '/nextScreen'); // Navigate to next page
    } else {
      // Show a message to select an option
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your type of visual impairment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Impairment Survey'),
        backgroundColor: const Color.fromARGB(255, 18, 32, 47), // Custom color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select your type of visual impairment:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Radio buttons for visual impairment types
            Expanded(
              child: ListView.builder(
                itemCount: _impairmentTypes.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(_impairmentTypes[index]),
                    value: _impairmentTypes[index],
                    groupValue: _selectedImpairmentType,
                    onChanged: (value) {
                      setState(() {
                        _selectedImpairmentType = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 32, 47),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
