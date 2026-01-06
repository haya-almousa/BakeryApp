BakerApp 🥯
A native iOS application built with SwiftUI for browsing baking courses, managing bookings, and handling user profiles. This project follows the MVVM (Model-View-ViewModel) architectural pattern to ensure clean separation of logic, UI, and data.
____________________________________________________________
📱 Features
Browse Courses: View a list of available baking classes with difficulty levels.

User Authentication: Secure Sign-In and Profile management.

Bookings Management: Full CRUD capabilities for course bookings.

Custom Navigation: A custom tab bar implementation for seamless navigation.
____________________________________________________________
🛠 Tech Stack
Language: Swift

UI Framework: SwiftUI

Architecture: MVVM (Model-View-ViewModel)

Networking: URLSession, Codable, Async/Await

Platform: iOS 16.0+
____________________________________________________________
CRUD Operations & API Integration
The application interacts with a remote backend service to manage data. The networking logic is isolated within the Services/ directory to maintain separation of concerns.

Implementation Details:
HTTP Client: Native URLSession is used with Swift's modern concurrency model (async/await) to perform non-blocking network requests.

Data Parsing: JSON responses are decoded into strict Swift structs (Models/) using the Codable protocol.

Error Handling: Custom error types manage network failures (e.g., invalidURL, decodingError) and present user-friendly messages.
____________________________________________________________
Key Operations:

READ (Get Data):
Fetches the list of available baking courses upon app launch.
Retrieves user profile details and existing bookings.

CREATE (Post Data):
Sign In: Posts user credentials to the auth endpoint.
Book Course: Sends a POST request with the courseID to reserve a spot.

UPDATE (Put/Patch Data):
Allows users to update their profile information (name, email).

DELETE (Remove Data):
Cancel Booking: Sends a DELETE request for a specific booking ID to remove it from the user's schedule.
