import 'package:flutter/material.dart';

// Create a placeholder for your image asset.
// Create a folder named `assets` in your project root and add an image
// named `cracked_road.jpg`.
 const String crackedRoadImageAsset = 'assets/cracked_road.jpg';

// Add these two lists for dropdown options
const List<String> issueTypes = ['Pothole', 'Broken Streetlight', 'Garbage', 'Water Logging'];
const List<String> priorityLevels = ['Low', 'Medium', 'High'];

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  String selectedIssueType = issueTypes[0];
  String selectedPriority = priorityLevels[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
    
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Fix My Nagar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 40),

                // ## 1. Upload Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoUpload(),
                    const SizedBox(width: 40),
                    _buildVoiceNoteUpload(),
                  ],
                ),
                const SizedBox(height: 40),

                // ## 2. Description Field
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Describe the issue briefly...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFFF7F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                //  const Text(
                //   'Fix My Nagar',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 26,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF1E3A5F),
                //   ),// ## 3. Issue Type Dropdown


                 const Text(
                  '  Select issue',
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),),


                DropdownButtonFormField<String>(
                  value: selectedIssueType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: issueTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIssueType = value!;
                    });
                  },
                  hint: const Text('Select Issue Type'),
                ),
                const SizedBox(height: 20),

                   const Text(
                  '  Select risk',
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),),

                // ## 4. Priority Level Dropdown
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: priorityLevels
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                  hint: const Text('Select Priority Level'),
                ),
                const SizedBox(height: 40),

                // ## 5. Location Section
                _buildLocationInfo(),
                const SizedBox(height: 60),

                // ## 6. Submit Button
                _buildSubmitButton(),
                  const SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: const DecorationImage(
            image: AssetImage(crackedRoadImageAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.black.withOpacity(0.3),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.white, size: 30),
              SizedBox(height: 4),
              Text(
                'Upload Photo',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceNoteUpload() {
    return Column(
      children: [
        const Icon(Icons.mic_none_outlined, color: Colors.grey, size: 28),
        const SizedBox(height: 8),
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF56D3A0), Color(0xFF33C08D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: Colors.white),
              SizedBox(height: 4),
              Text(
                'Upload\nVoice Note',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
              ),
              SizedBox(height: 4),
              Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF4CAF50),
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Current Location: ',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              children: [
                TextSpan(
                  text: 'Geo-tagged',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF37A4F5), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement submit logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'Submit Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
