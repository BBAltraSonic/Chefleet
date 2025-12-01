import '../models/opening_hours_model.dart';

class OpeningHoursService {
  static const List<String> _timeSlots = [
    '00:00', '00:30', '01:00', '01:30', '02:00', '02:30',
    '03:00', '03:30', '04:00', '04:30', '05:00', '05:30',
    '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
  ];

  static List<String> get timeSlots => _timeSlots;

  static bool isValidTimeFormat(String? time) {
    if (time == null || time.isEmpty) return false;

    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    if (!regex.hasMatch(time)) return false;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  static bool isValidTimeRange(String openTime, String closeTime) {
    if (!isValidTimeFormat(openTime) || !isValidTimeFormat(closeTime)) {
      return false;
    }

    try {
      final open = DateTime.parse('2024-01-01T$openTime:00');
      final close = DateTime.parse('2024-01-01T$closeTime:00');

      // For overnight hours (e.g., 22:00 to 02:00), this is valid
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidTimeBreak(TimeBreak timeBreak) {
    return isValidTimeFormat(timeBreak.startTime) &&
           isValidTimeFormat(timeBreak.endTime) &&
           timeBreak.isValid;
  }

  static bool isValidDayHours(DayOpeningHours dayHours) {
    if (!dayHours.isOpen) return true;

    if (dayHours.openTime == null || dayHours.closeTime == null) return false;

    if (!isValidTimeFormat(dayHours.openTime!) || !isValidTimeFormat(dayHours.closeTime!)) {
      return false;
    }

    if (dayHours.breaks != null) {
      for (final breakPeriod in dayHours.breaks!) {
        if (!isValidTimeBreak(breakPeriod)) return false;
      }
    }

    return dayHours.isValid;
  }

  static bool isValidOpeningHours(OpeningHours openingHours) {
    if (openingHours.is24Hours) return true;

    for (final dayHours in openingHours.weeklyHours.values) {
      if (!isValidDayHours(dayHours)) return false;
    }

    return openingHours.isValid;
  }

  static OpeningHoursValidationResult validateOpeningHours(OpeningHours openingHours) {
    final errors = <String, List<String>>{};
    final warnings = <String>[];

    if (openingHours.is24Hours) {
      return OpeningHoursValidationResult(
        isValid: true,
        errors: errors,
        warnings: warnings,
      );
    }

    for (final entry in openingHours.weeklyHours.entries) {
      final dayName = entry.key;
      final dayHours = entry.value;
      final dayErrors = <String>[];

      if (dayHours.isOpen) {
        if (dayHours.openTime == null) {
          dayErrors.add('Open time is required when day is marked as open');
        }
        if (dayHours.closeTime == null) {
          dayErrors.add('Close time is required when day is marked as open');
        }

        if (dayHours.openTime != null && dayHours.closeTime != null) {
          if (!isValidTimeFormat(dayHours.openTime!)) {
            dayErrors.add('Invalid open time format. Use HH:MM format.');
          }
          if (!isValidTimeFormat(dayHours.closeTime!)) {
            dayErrors.add('Invalid close time format. Use HH:MM format.');
          }

          if (dayHours.breaks != null) {
            for (int i = 0; i < dayHours.breaks!.length; i++) {
              final breakPeriod = dayHours.breaks![i];
              if (!isValidTimeFormat(breakPeriod.startTime)) {
                dayErrors.add('Invalid break start time format. Use HH:MM format.');
              }
              if (!isValidTimeFormat(breakPeriod.endTime)) {
                dayErrors.add('Invalid break end time format. Use HH:MM format.');
              }
              if (!breakPeriod.isValid) {
                dayErrors.add('Break ${i + 1} has invalid time range.');
              }
            }
          }
        }
      }

      if (dayErrors.isNotEmpty) {
        errors[dayName] = dayErrors;
      }
    }

    // Check for consistent patterns
    final openDaysCount = openingHours.weeklyHours.values
        .where((day) => day.isOpen)
        .length;

    if (openDaysCount == 0) {
      warnings.add('No days are marked as open. Your business will appear as always closed.');
    } else if (openDaysCount <= 2) {
      warnings.add('Very few operating hours are set. Consider adding more open days.');
    }

    // Check for unusual hours
    for (final dayHours in openingHours.weeklyHours.values) {
      if (dayHours.isOpen && dayHours.openTime != null && dayHours.closeTime != null) {
        try {
          final open = DateTime.parse('2024-01-01T${dayHours.openTime!}:00');
          final close = DateTime.parse('2024-01-01T${dayHours.closeTime!}:00');

          if (dayHours.openTime!.startsWith('00:00') && dayHours.closeTime!.startsWith('23:59')) {
            // This might be intended as 24 hours
            continue;
          }

          final duration = close.difference(open);
          if (duration.inHours > 16) {
            warnings.add('Unusually long operating hours on ${dayHours.day.displayName}.');
          } else if (duration.inHours < 4 && !dayHours.openTime!.startsWith('22:') && !dayHours.closeTime!.startsWith('02:')) {
            warnings.add('Very short operating hours on ${dayHours.day.displayName}.');
          }
        } catch (e) {
          // Already caught in validation above
        }
      }
    }

    return OpeningHoursValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  static DayOpeningHours createDefaultDayHours(DayOfWeek day) {
    return DayOpeningHours(
      day: day,
      isOpen: day != DayOfWeek.sunday, // Closed on Sundays by default
      openTime: '09:00',
      closeTime: '17:00',
    );
  }

  static OpeningHours createDefaultOpeningHours() {
    return OpeningHours.defaultHours();
  }

  static OpeningHours copyHoursToOtherDays(OpeningHours source, DayOfWeek sourceDay, List<DayOfWeek> targetDays) {
    final sourceHours = source.getHoursForDay(sourceDay);
    if (sourceHours == null) return source;

    OpeningHours result = source;
    for (final targetDay in targetDays) {
      result = result.setHoursForDay(targetDay, sourceHours.copyWith(day: targetDay));
    }

    return result;
  }

  static List<String> getCommonOpeningTimes() {
    return [
      '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
      '09:00', '09:30', '10:00', '10:30', '11:00',
    ];
  }

  static List<String> getCommonClosingTimes() {
    return [
      '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30', '21:00', '21:30', '22:00', '22:30',
      '23:00', '23:30',
    ];
  }

  static Map<String, dynamic> openingHoursToMap(OpeningHours? openingHours) {
    if (openingHours == null) return {};

    return openingHours.toJson();
  }

  static OpeningHours? openingHoursFromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;

    try {
      return OpeningHours.fromJson(map);
    } catch (e) {
      // Try legacy format
      try {
        return OpeningHours.fromLegacyJson(map);
      } catch (e2) {
        return null;
      }
    }
  }

  static String getOperatingHoursDisplay(OpeningHours openingHours) {
    if (openingHours.is24Hours) {
      return 'Open 24/7';
    }

    final openDays = openingHours.weeklyHours.values
        .where((day) => day.isOpen)
        .toList();

    if (openDays.isEmpty) {
      return 'Closed';
    }

    // Check for consistent hours
    final firstOpenDay = openDays.first;
    bool isConsistent = openDays.every((day) =>
        day.openTime == firstOpenDay.openTime &&
        day.closeTime == firstOpenDay.closeTime &&
        day.breaks?.length == firstOpenDay.breaks?.length);

    if (isConsistent) {
      final dayNames = openDays.map((day) => day.day.displayName.substring(0, 3)).join(', ');
      return '$dayNames: ${firstOpenDay.displayHours}';
    }

    // Return summary
    final openDayCount = openDays.length;
    return 'Open $openDayCount days a week';
  }

  static String getNextStatusDisplay(OpeningHours openingHours) {
    if (openingHours.isOpenToday) {
      return 'Open now';
    }

    final now = DateTime.now();
    final nextOpen = openingHours.getNextOpenTime(now);

    if (nextOpen != null) {
      return nextOpen;
    }

    return 'Currently closed';
  }
}

class OpeningHoursValidationResult {
  final bool isValid;
  final Map<String, List<String>> errors;
  final List<String> warnings;

  const OpeningHoursValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  int get totalErrors => errors.values.fold(0, (sum, errors) => sum + errors.length);
}