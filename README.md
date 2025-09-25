<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# libkoala

A spiritual successor to [Koala](https://github.com/betterbearmetalcode/koala), libkoala is a shared library for Bear Metal's Flutter apps that includes auth pages, API abstractions, and other shared components.

## Features

- **Authentication**: Microsoft Azure AD integration with token management
- **User Info Caching**: Intelligent caching of user profile data with SQLite
- **Device Info**: Cross-platform device detection and information
- **UI Components**: Reusable widgets like ProfilePicture, TileableCard, etc.
- **Database Integration**: SQLite database providers with Riverpod integration
- **State Management**: Built on Riverpod 3.0 with modern patterns

## Recent Updates (v1.1.0)

- Upgraded to Riverpod 3.0.0 with new syntax and patterns
- Added riverpod_sqflite integration for database caching
- Enhanced ProfilePicture widget with cached user data
- Improved performance with 24-hour user info caching
- Added comprehensive database providers and cache management