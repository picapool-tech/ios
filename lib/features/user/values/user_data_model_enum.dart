import 'package:picapool/models/user_model.dart';

enum UserField {
  name('name'),
  pic('pic'),
  age('age'),
  gender('gender'),
  username('username'),
  bio('bio'),
  location('location'),
  tag('tagList'),
  fcmToken('fcmToken'),
  isVerified('isVerified');

  final String apiField;
  const UserField(this.apiField);
}

extension GetUpdatedUser on User {
  /// Creates a JSON map with only the specified fields for API updates
  Map<String, dynamic> toUpdateJson({
    List<UserField>? includeFields,
    User? originalUser,
    MapEntry<String, dynamic> Function(UserField)? customExecution,
  }) {
    // Assert that customExecution is provided when updating location field
    final processingLocation =
        includeFields?.contains(UserField.location) ?? true;
    assert(!processingLocation || customExecution != null,
        'customExecution must not be null when updating location field');
    // Use provided fields or all fields
    final fieldsToCheck = includeFields ?? UserField.values;
    print(
        'DEBUG: Processing fields: ${fieldsToCheck.map((f) => f.name).join(', ')}');
    print('DEBUG: Original user provided: ${originalUser != null}');

    var result = Map.fromEntries(fieldsToCheck.map((field) {
      if (processingLocation) {
        return customExecution?.call(field);
      }
      final value = _getFieldValue(field);
      final originalValue = originalUser?._getFieldValue(field);

      final willInclude =
          value != null && (originalUser == null || value != originalValue);
      print(
          'DEBUG: Field ${field.name}: current=$value, original=$originalValue, include=$willInclude');

      if (willInclude) {
        if (customExecution != null) {
          final entry = customExecution(field);
          return entry;
        }
        return MapEntry(field.apiField, value);
      }
      return null;
    }).whereType<MapEntry<String, dynamic>>());

    print('DEBUG: Final update map: $result');
    return result;
  }

  /// Helper to get a field value based on enum
  dynamic _getFieldValue(UserField field) {
    switch (field) {
      case UserField.name:
        return name;
      case UserField.pic:
        return pic;
      case UserField.age:
        return age;
      case UserField.gender:
        return gender;
      case UserField.username:
        return username;
      case UserField.bio:
        return bio;
      case UserField.location:
        return location;
      case UserField.fcmToken:
        return fcmToken;
      case UserField.tag:
        return tags ?? [];
      case UserField.isVerified:
        return isVerified;
    }
  }
}
