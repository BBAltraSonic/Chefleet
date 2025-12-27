
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/core/utils/date_time_utils.dart'; // Adjust path if needed for test

void main() {
  test('DateTimeUtils handles standard UTC strings correctly', () {
    // 2023-01-01 12:00:00 UTC
    const serverTimeStr = '2023-01-01T12:00:00Z'; 
    final parsed = DateTimeUtils.parse(serverTimeStr);
    
    expect(parsed, isNotNull);
    // Should be converted to Local
    // We can't assert exact hour without knowing machine timezone, 
    // but we can assert it represents the same instant.
    expect(parsed!.isUtc, isFalse);
    expect(parsed.toUtc().hour, 12);
  });

  test('DateTimeUtils handles missing Z by assuming UTC', () {
    // 2023-01-01 12:00:00 (Implied UTC)
    const serverTimeStr = '2023-01-01T12:00:00'; 
    
    // Default DateTime.parse would treat this as Local 12:00
    // If Local is UTC+2, that is 10:00 UTC.
    
    // DateTimeUtils should treat it as UTC 12:00
    final parsed = DateTimeUtils.parse(serverTimeStr);
    
    expect(parsed, isNotNull);
    expect(parsed!.isUtc, isFalse); // Result is Local
    expect(parsed.toUtc().hour, 12); // But value matches UTC input
  });
  
  test('formatTimeAgo handles offsets correctly', () {
    // Create a time 5 minutes ago in UTC
    final nowUtc = DateTime.now().toUtc();
    final fiveMinsAgoUtc = nowUtc.subtract(const Duration(minutes: 5));
    
    final formatted = DateTimeUtils.formatTimeAgo(fiveMinsAgoUtc);
    expect(formatted, contains('5 min'));
  });
}
