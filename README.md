# Geo-Fenced Attendance System

A production-ready Flutter application for location-based attendance marking. The system ensures that employees can only mark their attendance when they are physically within a 50-meter radius of the designated office location.

## Features
- **Office Setup**: Set the current GPS location as the "Office Location".
- **Real-Time Tracking**: Live distance indicator that updates as the user moves.
- **Geo-Fencing**: Dynamic "Mark Attendance" button enabled only within a 50m radius.
- **Persistence**: Office location is saved locally using Hive.
- **Permissions**: Graceful handling of location permissions and GPS service status.

## Technical Stack
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC Pattern)
- **Local Storage**: [Hive](https://pub.dev/packages/hive)
- **Location Services**: [geolocator](https://pub.dev/packages/geolocator)
- **Functional Programming**: [dartz](https://pub.dev/packages/dartz) (Either for error handling)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Object Comparison**: [equatable](https://pub.dev/packages/equatable)

## Project Structure / Approaches
The project follows **Clean Architecture** principles, separated into three main layers:

1. **Domain Layer**: Contains Business Logic.
   - **Entities**: Simple data objects (`LocationEntity`).
   - **Repositories**: Abstract definitions of data operations.
   - **Use Cases**: Specific business rules (`MarkAttendance`, `SetOfficeLocation`, `GetLocationStream`).

2. **Data Layer**: Handles data retrieval and storage.
   - **Models**: Data transfer objects with JSON/Hive serialization.
   - **Data Sources**: Remote (Geolocator) and Local (Hive) implementations.
   - **Repository Implementation**: Coordinates between different data sources.

3. **Presentation Layer**: UI and State Management.
   - **BLoC**: `AttendanceBloc` manages all events like `CheckInitialLocationEvent`, `SetOfficeLocationEvent`, and `RealTimeLocationUpdateEvent`.
   - **Widgets**: Reusable components and the main `AttendanceScreen`.

## Screenshots

<p align="center">
  <img src="assets/screenshots/scene_1_location_permission.jpg" width="200" alt="Location Permission">
  <img src="assets/screenshots/scene_2_location_not_set_yet.jpg" width="200" alt="Location Not Set">
  <img src="assets/screenshots/scene_3_location_set_success.jpg" width="200" alt="Location Set Success">
  <img src="assets/screenshots/scene_4_attendance_taken.jpg" width="200" alt="Attendance Taken">
</p>

## Download APK
You can download the latest release APK from the link below:
- [🚀 Download Release APK](https://github.com/rktuhinbd/Geo-Fenced-Attendance-System/raw/master/assets/apk/app-release.apk)

*Note: I have moved the built APK to `assets/apk/app-release.apk`. As soon as you push your code to GitHub, the link above will work instantly!*

## How to Run
1. **Clone the repository**:
   ```bash
   git clone https://github.com/rktuhinbd/Geo-Fenced-Attendance-System.git
   cd Geo-Fenced-Attendance-System
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the application**:
   ```bash
   flutter run
   ```

---
Developed as a demonstration of Clean Architecture and Real-Time Geo-Fencing in Flutter.
