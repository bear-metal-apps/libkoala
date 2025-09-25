## 1.1.0

- **BREAKING**: Upgraded to Riverpod 3.0.0
- **BREAKING**: Migrated `authStatusProvider` from `StateProvider` to new class-based notifier pattern
- Added riverpod_sqflite integration for database caching
- Added `cachedUserInfoProvider` for improved user info caching with 24-hour expiration
- Added `databaseProvider` for SQLite database access
- Added `dataCacheProvider` for generic data caching capabilities
- Enhanced `ProfilePicture` widget to use cached user data
- Added automatic cache clearing on user logout
- Updated all providers to use new Riverpod 3.0 syntax
- Added comprehensive tests for new caching functionality
- Updated build dependencies to support Riverpod 3.0

## 1.0.0

- Initial release of libkoala
- Added auth_provider
- Added team_provider
