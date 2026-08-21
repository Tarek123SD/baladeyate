/// Parsed segments of a complaint [description] field.
class ComplaintDescriptionParts {
  const ComplaintDescriptionParts({
    required this.subject,
    required this.details,
    this.attachmentCount = 0,
    this.addressLine,
    this.locationLine,
  });

  final String subject;
  final String details;
  final int attachmentCount;
  final String? addressLine;
  final String? locationLine;
}

final _attachmentCountPattern = RegExp(r'\s*عدد المرفقات:\s*(\d+)');
final _addressPattern = RegExp(
  r'(?:عنوان الموقع|العنوان):\s*(.+?)(?=\s*الموقع:|\s*عدد المرفقات:|$)',
  unicode: true,
);
final _locationPattern = RegExp(
  r'الموقع:\s*(-?\d+(?:\.\d+)?\s*,\s*-?\d+(?:\.\d+)?)',
);

ComplaintDescriptionParts parseComplaintDescription(String raw) {
  if (raw.trim().isEmpty) {
    return const ComplaintDescriptionParts(subject: '', details: '');
  }

  var text = raw;
  var attachmentCount = 0;
  String? addressLine;
  String? locationLine;

  final attachmentMatch = _attachmentCountPattern.firstMatch(text);
  if (attachmentMatch != null) {
    attachmentCount = int.tryParse(attachmentMatch.group(1) ?? '') ?? 0;
    text = text.replaceRange(attachmentMatch.start, attachmentMatch.end, '');
  }

  final addressMatch = _addressPattern.firstMatch(text);
  if (addressMatch != null) {
    final value = addressMatch.group(1)?.trim();
    if (value != null && value.isNotEmpty) {
      addressLine = 'عنوان الموقع: $value';
    }
    text = text.replaceRange(addressMatch.start, addressMatch.end, '');
  }

  final locationMatch = _locationPattern.firstMatch(text);
  if (locationMatch != null) {
    final value = locationMatch.group(1)?.trim();
    if (value != null && value.isNotEmpty) {
      locationLine = 'الموقع: $value';
    }
    text = text.replaceRange(locationMatch.start, locationMatch.end, '');
  }

  final remaining = text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  final subject = remaining.isEmpty ? '' : remaining.first;
  final details = remaining.length <= 1 ? '' : remaining.sublist(1).join('\n');

  return ComplaintDescriptionParts(
    subject: subject,
    details: details,
    attachmentCount: attachmentCount,
    addressLine: addressLine,
    locationLine: locationLine,
  );
}

String composeComplaintDescription({
  required String subject,
  required String details,
  int attachmentCount = 0,
  String? addressLine,
  String? locationLine,
}) {
  final trimmedSubject = subject.trim();
  final trimmedDetails = details.trim();
  final buffer = StringBuffer();

  if (trimmedSubject.isNotEmpty && trimmedDetails.isNotEmpty) {
    buffer.write('$trimmedSubject\n$trimmedDetails');
  } else if (trimmedSubject.isNotEmpty) {
    buffer.write(trimmedSubject);
  } else {
    buffer.write(trimmedDetails);
  }

  if (addressLine != null && addressLine.trim().isNotEmpty) {
    buffer.write('\n${addressLine.trim()}');
  }
  if (locationLine != null && locationLine.trim().isNotEmpty) {
    buffer.write('\n${locationLine.trim()}');
  }
  if (attachmentCount > 0) {
    buffer.write('\nعدد المرفقات: $attachmentCount');
  }

  return buffer.toString().trim();
}

/// Strips legacy `العنوان:` / `عنوان الموقع:` prefixes from a stored address line.
String? addressValueFromLine(String? line) {
  if (line == null || line.trim().isEmpty) return null;

  final trimmed = line.trim();
  if (trimmed.startsWith('العنوان:')) {
    return trimmed.replaceFirst('العنوان:', '').trim();
  }
  if (trimmed.startsWith('عنوان الموقع:')) {
    return trimmed.replaceFirst('عنوان الموقع:', '').trim();
  }

  return trimmed;
}

/// Formats the location section for cards: manual address, map pin, or both.
String? locationDisplayFromParts(ComplaintDescriptionParts parts) {
  final address = addressValueFromLine(parts.addressLine);
  final coordinates = coordinatesDisplayFromLine(parts.locationLine);

  if (address != null && address.isNotEmpty) {
    if (coordinates != null) {
      return '$address\n$coordinates';
    }
    return address;
  }

  return coordinates;
}

/// Formats a stored `الموقع: lat, lng` line for display.
String? coordinatesDisplayFromLine(String? line) {
  if (line == null || line.trim().isEmpty) return null;

  final trimmed = line.trim();
  if (!trimmed.startsWith('الموقع:')) return null;

  final raw = trimmed.replaceFirst('الموقع:', '').trim();
  if (raw.isEmpty) return null;

  return 'تم تحديد العنوان على الخريطة مباشرة';
}

/// Parses `lat, lng` from a stored location line, swapping Syria lng/lat if needed.
({double latitude, double longitude})? coordinatesFromLine(String? line) {
  if (line == null || line.trim().isEmpty) {
    return null;
  }

  final match = _locationPattern.firstMatch(line);
  if (match == null) {
    return null;
  }

  final first = double.tryParse(match.group(1)!.split(',').first.trim());
  final second = double.tryParse(match.group(1)!.split(',').last.trim());
  if (first == null || second == null) {
    return null;
  }

  return _normalizeLatLng(first, second);
}

({double latitude, double longitude})? _normalizeLatLng(
  double first,
  double second,
) {
  final looksLikeLngLat =
      first >= 35.0 && first <= 42.5 && second >= 32.0 && second <= 37.7;
  final looksLikeLatLng =
      first >= 32.0 && first <= 37.7 && second >= 35.0 && second <= 42.5;

  var latitude = first;
  var longitude = second;
  if (looksLikeLngLat && !looksLikeLatLng) {
    latitude = second;
    longitude = first;
  }

  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return null;
  }

  return (latitude: latitude, longitude: longitude);
}
