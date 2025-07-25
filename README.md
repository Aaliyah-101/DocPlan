# DocPlan - Smart Healthcare Scheduling

A Flutter-based healthcare appointment scheduling application with role-based access control and emergency management.

## Features

### 🔐 Authentication & Role Management
- **Multi-role signup**: Users can register as Patient, Doctor, 
- **Role-based dashboards**: Different interfaces for each user type
- **Secure authentication**: Firebase Authentication integration

### 👨‍⚕️ Doctor Features
- **Specialty selection**: Choose from 9 medical specialties:

  - Cardiologist
  - Endocrinologist
  - Gastroenterologist
  - Pulmonologist
  - Nephrologist
  - Hematologist
  - Neurosurgeon
  - Cardiothoracic Surgeon
  - Plastic Surgeon
  - Dermatologistgit 
  - Oncologist 
  - Radiologist
  - Pathologist
  - Ophthalmologist
  - Psychiatrist
  - Urologist
  - Trauma Surgeon
  - Allergist
  - toxicologist
- **Availability management**: Set weekly schedule with hourly time slots
- **Appointment viewing**: View and manage patient appointments
- **Patient location tracking**: Check if patients are within service radius

### 👤 Patient Features
- **Specialty-based doctor selection**: Choose doctor by medical specialty
- **Availability-based booking**: See doctor's available time slots
- **Appointment booking**: Book appointments with reason/reasoning
- **Appointment viewing**: View upcoming and past appointments
- **emergency access**: Patients can declare emergencie



### 🚨 Emergency System
- **Admin-only emergency declaration**: Only admins can declare emergencies
- **Appointment freezing**: All appointments are frozen during emergencies
- **Patient notification**: Affected patients are notified of emergencies
- **Emergency resolution**: Admins can resolve emergencies and restore normal operations

### 🎨 UI/UX Features
- **DocPlan branding**: Light blue color scheme throughout the app
- **Consistent branding**: "DocPlan" displayed prominently on all screens
- **Doctor background**: Subtle doctor-patient background image
- **Modern design**: Clean, intuitive interface with Material Design

## Technical Stack

- **Frontend**: Flutter
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Notifications**: Firebase Messaging
- **Location Services**: Geolocator

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd docplan22
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up Firebase project
   - Add configuration files (google-services.json, etc.)
   - Enable Authentication and Firestore

4. **Add background image**
   - Replace `assets/images/doctor_background.jpg` with actual image
   - Image should show a doctor working on a patient

5. **Run the app**
   ```bash
   flutter run
   ```

## Database Structure

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "phoneNumber": "string",
  "country": "string",
  "role": "patient|doctor|admin",
  "createdAt": "timestamp",
  "specialty": "string (doctors only)",
  "availability": "map (doctors only)"
}
```

### Doctors Collection
```json
{
  "userId": "string",
  "name": "string",
  "specialty": "string",
  "availability": "map",
  "status": "available|emergency",
  "location": "map",
  "radius": "number"
}
```

### Appointments Collection
```json
{
  "id": "string",
  "doctorId": "string",
  "patientId": "string",
  "doctorName": "string",
  "patientName": "string",
  "dateTime": "timestamp",
  "status": "upcoming|completed|cancelled|rescheduled|frozen",
  "reason": "string",
  "notes": "string",
  "createdAt": "timestamp",
  "location": "map",
  "isEmergency": "boolean"
}
```

### Emergencies Collection
```json
{
  "id": "string",
  "doctorId": "string",
  "doctorName": "string",
  "reason": "string",
  "timestamp": "timestamp",
  "status": "active|resolved",
  "affectedAppointments": "array"
}
```

## Key Changes Made

1. **Role-based signup**: Added dropdown for role selection during registration
2. **Doctor specialty and availability**: Doctors can set their specialty and weekly schedule
3. **Specialty-based booking**: Patients select doctors by specialty first
4. **Availability-based time slots**: Patients see only available time slots for selected doctor
5. **Emergency management**: Admin-only emergency system with appointment freezing
6. **DocPlan branding**: Consistent light blue branding throughout the app
7. **Removed patient emergency access**: Patients can no longer declare emergencies
8. **Enhanced appointment booking**: Added reason field for appointments
9. **Improved UI**: Better visual hierarchy and user experience

## Future Enhancements

- Real-time chat between doctors and patients
- Video consultation integration
- Payment processing
- video consultation
- Medical records integration
- Advanced analytics and reporting
- Multi-language support
- Push notifications for appointment reminders


## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
