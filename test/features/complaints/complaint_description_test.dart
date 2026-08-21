import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses inline address and coordinates from Flutter client text', () {
    const raw =
        'مضروب خط الكهربا بالهمك عنوان الموقع: كلية الهمك الموقع: 33.49457 , 36.31702';

    final parts = parseComplaintDescription(raw);

    expect(parts.subject, 'مضروب خط الكهربا بالهمك');
    expect(addressValueFromLine(parts.addressLine), 'كلية الهمك');
    expect(
      coordinatesFromLine(parts.locationLine)?.latitude,
      closeTo(33.49457, 0.0001),
    );
    expect(
      coordinatesFromLine(parts.locationLine)?.longitude,
      closeTo(36.31702, 0.0001),
    );
  });

  test('complaint uses stored coordinates and citizen photos', () {
    const complaint = Complaint(
      id: 18,
      description:
          'مضروب خط الكهربا بالهمك عنوان الموقع: كلية الهمك الموقع: 33.49457 , 36.31702',
      priority: 'medium',
      status: 'in_progress',
      latitude: 33.49457,
      longitude: 36.31702,
      attachments: [
        'https://example.com/storage/complaints/attachments/leak.jpg',
        'https://example.com/storage/complaints/attachments/note.pdf',
      ],
      citizenName: 'وليد',
    );

    expect(complaint.citizenMessage, 'مضروب خط الكهربا بالهمك');
    expect(complaint.mapCoordinates?.latitude, closeTo(33.49457, 0.0001));
    expect(complaint.imageAttachments, hasLength(1));
    expect(complaint.fileAttachments, hasLength(1));
    expect(complaint.citizenName, 'وليد');
  });
}
