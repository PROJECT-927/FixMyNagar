import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


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

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Function to handle picking an image from the gallery
  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      // Use setState to update the UI with the new image
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }


 // State variables to hold location data and loading state
  String _currentAddress = "Fetching location...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  
  Future<void> _getCurrentLocation() async {
    // Show loading indicator immediately upon tap
    setState(() {
      _isLoading = true;
      _currentAddress = "Fetching...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
        _isLoading = false;
      });
      await Geolocator.openAppSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permissions denied.";
          _isLoading = false;
        });
        await Geolocator.openAppSettings();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Permissions permanently denied.";
        _isLoading = false;
      });
      await Geolocator.openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final address = '${place.street}, ${place.locality}, ${place.postalCode}';
        setState(() {
          _currentAddress = address;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Failed to get location.";
        _isLoading = false;
      });
    }
  }
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
                // const SizedBox(height: 40),

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
                const SizedBox(height: 25),

                // ## 6. Submit Button
                _buildSubmitButton(),
            
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Expanded(
      // Use GestureDetector to make the container tappable
      child: GestureDetector(
        onTap: _pickImage, // Call the image picker function on tap
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            // Conditionally display the selected image or the placeholder
            image: DecorationImage(
              // Use FileImage for the selected image, otherwise use the asset
              image: _imageFile == null
                  ? const AssetImage(crackedRoadImageAsset) as ImageProvider
                  : FileImage(File(_imageFile!.path)),
              fit: BoxFit.cover,
            ),
          ),
          // Only show the overlay if no image has been selected
          child: _imageFile == null
              ? Container(
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
                )
              : null, // Render nothing if an image is selected
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

  Widget _buildLocationInfo(){

   return GestureDetector(
      // Call the location function when the widget is tapped
      onTap: _getCurrentLocation,
      child: Row(
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
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Current Location: ',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                children: [
                  TextSpan(
                    text: _currentAddress,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isLoading ? Colors.grey : const Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
