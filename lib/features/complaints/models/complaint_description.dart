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

ComplaintDescriptionParts parseComplaintDescription(String raw) {
  final lines = raw.split('\n');
  if (lines.isEmpty || raw.trim().isEmpty) {
    return const ComplaintDescriptionParts(subject: '', details: '');
  }

  final subject = lines.first.trim();
  final bodyLines = <String>[];
  String? addressLine;
  String? locationLine;
  var attachmentCount = 0;

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('العنوان:') || line.startsWith('عنوان الموقع:')) {
      addressLine = lines[i];
    } else if (line.startsWith('الموقع:')) {
      locationLine = lines[i];
    } else if (line.startsWith('عدد المرفقات:')) {
      final countRaw = line.replaceFirst('عدد المرفقات:', '').trim();
      attachmentCount = int.tryParse(countRaw) ?? 0;
    } else {
      bodyLines.add(lines[i]);
    }
  }

  return ComplaintDescriptionParts(
    subject: subject,
    details: bodyLines.join('\n').trim(),
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
