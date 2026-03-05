# Geo-Fenced Attendance System

A production-ready Flutter application for location-based attendance marking. This system ensures that attendance can only be marked when the user is physically within a 50-meter radius of the designated office location.

## Technical Stack
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC Pattern)
- **Local Storage**: [Hive](https://pub.dev/packages/hive)
- **Location Services**: [geolocator](https://pub.dev/packages/geolocator)
- **Functional Programming**: [dartz](https://pub.dev/packages/dartz) (Either for error handling)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Object Comparison**: [equatable](https://pub.dev/packages/equatable)

## Project Structure / Approaches
The project is built using **Clean Architecture** principles to ensure scalability and maintainability.

### Architecture Layers:
1. **Domain Layer**: Contains the core business logic, entities (`LocationEntity`), and abstract repository definitions. Use cases like `GetLocationStream` and `SetOfficeLocation` are defined here.
2. **Data Layer**: Implements the repositories. It manages data from the `LocationDeviceDataSource` (Geolocator API) and `AttendanceLocalDataSource` (Hive persistence).
3. **Presentation Layer**: Handles the UI and state. The `AttendanceBloc` manages real-time location events and updates the UI state dynamically.

### Key Classes:
- `AttendanceBloc`: Manages all location-based states (Initial, Loading, Loaded, Success, Error).
- `LocationDeviceDataSourceImpl`: Handles high-frequency GPS updates and permission requests.
- `AttendanceRepositoryImpl`: Coordinates the flow between location hardware and local storage.

## Generative AI Usage
This project was developed with the assistance of Generative AI (Antigravity). AI was utilized for architectural planning, implementing the real-time location stream, and optimizing GPS accuracy.

### Essential Prompts Used:
1. *"Act as a senior Flutter developer. Generate a clean architecture structure for a Geo-Fenced Attendance system using BLoC."*
2. *"Implement a real-time location stream using the geolocator package that updates every meter for footstep-level sensitivity."*
3. *"The GPS distance is flickering while the phone is stationary. How can I implement a distance filter and rounded display to stabilize the UI?"*
4. *"Use Geolocator.distanceBetween() for the most accurate calculation and explain how to add platform-specific settings for Android."*
5. *"Help me organize the final README.md following specific documentation guidelines including screenshots and APK links."*

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

## Screenshots
<p align="center">
  <img src="assets/screenshots/scene_1_location_permission.jpg" width="200" alt="Location Permission">
  <img src="assets/screenshots/scene_2_location_not_set_yet.jpg" width="200" alt="Location Not Set">
  <img src="assets/screenshots/scene_3_location_set_success.jpg" width="200" alt="Location Set Success">
  <img src="assets/screenshots/scene_4_attendance_taken.jpg" width="200" alt="Attendance Taken">
</p>

## Deliverables & APK Submission
### Release APK
The production-ready release APK is included in the repository for easy access.
- **[🚀 Download Release APK](https://github.com/rktuhinbd/Geo-Fenced-Attendance-System/raw/master/assets/apk/app-release.apk)**

*Note: The APK is hosted within the `assets/apk/` directory of the master branch. The link above will be active once the code is pushed to GitHub.*

---
Developed as a demonstration of Clean Architecture and Real-Time Geo-Fencing in Flutter.
