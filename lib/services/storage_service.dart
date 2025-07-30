import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    final ref = _storage.ref().child('profile_pictures/$userId.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload medical record attachment
  Future<String> uploadMedicalRecordAttachment(File file, String recordId, String fileName) async {
    final ref = _storage.ref().child('medical_records/$recordId/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    final ref = _storage.ref().child('profile_pictures/$userId.jpg');
    await ref.delete();
  }

  // Delete medical record attachment
  Future<void> deleteMedicalRecordAttachment(String recordId, String fileName) async {
    final ref = _storage.ref().child('medical_records/$recordId/$fileName');
    await ref.delete();
  }
} 