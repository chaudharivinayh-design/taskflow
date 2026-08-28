import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/smart_parser.dart';

void main() {
  group('SmartParser', () {
    test('detects alarm intent from "wake me up"', () {
      final result = SmartParser.parse('Wake me up at 6 AM');
      expect(result.type, SmartIntentType.alarm);
      expect(result.dateTime, isNotNull);
      expect(result.dateTime!.hour, 6);
      expect(result.dateTime!.minute, 0);
    });

    test('detects reminder intent from "remind me"', () {
      final result = SmartParser.parse('Remind me to call the bank at 3 PM');
      expect(result.type, SmartIntentType.reminder);
      expect(result.dateTime!.hour, 15);
      expect(result.title.toLowerCase(), contains('call the bank'));
    });

    test('defaults to task intent with tomorrow + time', () {
      final result = SmartParser.parse('Pay electricity bill tomorrow 7 PM');
      expect(result.type, SmartIntentType.task);
      expect(result.dateTime!.hour, 19);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(result.dateTime!.day, tomorrow.day);
      expect(result.title.toLowerCase(), contains('pay electricity bill'));
    });

    test('resolves a weekday name to the next matching date', () {
      final result = SmartParser.parse('Call Rahul Friday 5 PM');
      expect(result.dateTime!.weekday, DateTime.friday);
      expect(result.dateTime!.hour, 17);
    });

    test('handles 12-hour edge cases (12 AM / 12 PM)', () {
      final noon = SmartParser.parse('Lunch today 12 PM');
      expect(noon.dateTime!.hour, 12);
      final midnight = SmartParser.parse('Reset counters 12 AM');
      expect(midnight.dateTime!.hour, 0);
    });

    test('falls back to a placeholder title when nothing is left', () {
      final result = SmartParser.parse('wake me up at 6 am');
      expect(result.title, isNotEmpty);
    });
  });
}
