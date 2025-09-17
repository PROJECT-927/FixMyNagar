// lib/report.dart
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

const String crackedRoadImageAsset = 'assets/cracked_road.jpg';
const List<String> issueTypes = ['Pothole', 'Broken Streetlight', 'Garbage', 'Water Logging', 'Possible Stampade'];
const List<String> priorityLevels = ['Low', 'Medium', 'High'];

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String _currentAddress = "Fetching location...";
  bool _isLoading = true;

  String selectedIssueType = issueTypes[0];
  String selectedPriority = priorityLevels[0];

  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
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
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

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

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/my_voice_note.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      await _audioPlayer.play(UrlSource(_audioPath!));
    }
  }

  void _deleteRecording() {
    setState(() {
      _audioPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B222F),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3445),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'REPORT ISSUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoUpload(),
                    const SizedBox(width: 30),
                    _buildVoiceNoteUpload(),
                  ],
                ),
                const SizedBox(height: 30),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                _buildDropdown('Select Issue', issueTypes, selectedIssueType, (val) {
                  setState(() => selectedIssueType = val!);
                }),
                const SizedBox(height: 20),
                _buildDropdown('Select Risk', priorityLevels, selectedPriority, (val) {
                  setState(() => selectedPriority = val!);
                }),
                const SizedBox(height: 30),
                _buildLocationInfo(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Describe the issue briefly...',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A3445),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF2A3445),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A3445),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Expanded(
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: _imageFile == null
                  ? const AssetImage(crackedRoadImageAsset) as ImageProvider
                  : FileImage(File(_imageFile!.path)),
              fit: BoxFit.cover,
            ),
          ),
          child: _imageFile == null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.25),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text('Upload Photo', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildVoiceNoteUpload() {
    return Column(
      children: [
        if (_audioPath != null)
          Column(
            children: [
              const Text("Voice Note Added", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.green, size: 35), onPressed: _playRecording),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 35), onPressed: _deleteRecording),
                ],
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [Colors.red.shade400, Colors.red.shade700]
                      : [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    _isRecording ? 'Stop\nRecording' : 'Record\nVoice Note',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3445),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF00C6FF), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isLoading ? 'Fetching location...' : _currentAddress,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0072FF).withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Submit Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
