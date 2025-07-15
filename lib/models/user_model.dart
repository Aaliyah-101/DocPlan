class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String country;
  final String role; // 'patient', 'doctor', 'admin'
  final DateTime createdAt;
  final Map<String, dynamic>? doctorInfo; // Only for doctors
  final String? specialty; // For doctors: Cardiologist, Endocrinologist, etc.
  final Map<String, List<String>>? availability; // For doctors: days -> time slots
  final String? profilePictureUrl; // Profile picture URL
  final String? bio; // Doctor bio
  final double? rating; // Doctor rating
  final int? totalRatings; // Total number of ratings

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.country,
    required this.role,
    required this.createdAt,
    this.doctorInfo,
    this.specialty,
    this.availability,
    this.profilePictureUrl,
    this.bio,
    this.rating,
    this.totalRatings,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'country': country,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'doctorInfo': doctorInfo,
      'specialty': specialty,
      'availability': availability,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Safely convert availability map
    Map<String, List<String>>? availability;
    if (map['availability'] != null) {
      try {
        availability = <String, List<String>>{};
        final availabilityMap = map['availability'] as Map<String, dynamic>;
        availabilityMap.forEach((key, value) {
          if (value is List) {
            availability![key] = value.map((item) => item.toString()).toList();
          } else {
            availability![key] = [];
          }
        });
      } catch (e) {
        print('DEBUG: Error parsing availability: $e');
        availability = null;
      }
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      country: map['country'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      doctorInfo: map['doctorInfo'],
      specialty: map['specialty'],
      availability: availability,
      profilePictureUrl: map['profilePictureUrl'],
      bio: map['bio'],
      rating: map['rating']?.toDouble(),
      totalRatings: map['totalRatings'],
    );
  }
} 