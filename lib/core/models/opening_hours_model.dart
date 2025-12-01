import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'opening_hours_model.g.dart';

enum DayOfWeek {
  monday(1, 'Monday'),
  tuesday(2, 'Tuesday'),
  wednesday(3, 'Wednesday'),
  thursday(4, 'Thursday'),
  friday(5, 'Friday'),
  saturday(6, 'Saturday'),
  sunday(7, 'Sunday');

  const DayOfWeek(this.value, this.displayName);

  final int value;
  final String displayName;

  static DayOfWeek fromInt(int value) {
    return DayOfWeek.values.firstWhere(
      (day) => day.value == value,
      orElse: () => DayOfWeek.monday,
    );
  }

  static DayOfWeek fromString(String name) {
    return DayOfWeek.values.firstWhere(
      (day) => day.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DayOfWeek.monday,
    );
  }
}

@JsonSerializable()
class DayOpeningHours extends Equatable {
  final DayOfWeek day;
  final bool isOpen;
  final String? openTime; // Format: "HH:MM"
  final String? closeTime; // Format: "HH:MM"
  final List<TimeBreak>? breaks; // Multiple breaks during the day

  const DayOpeningHours({
    required this.day,
    this.isOpen = false,
    this.openTime,
    this.closeTime,
    this.breaks,
  });

  factory DayOpeningHours.fromJson(Map<String, dynamic> json) =>
      _$DayOpeningHoursFromJson(json);

  Map<String, dynamic> toJson() => _$DayOpeningHoursToJson(this);

  DayOpeningHours copyWith({
    DayOfWeek? day,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    List<TimeBreak>? breaks,
  }) {
    return DayOpeningHours(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      breaks: breaks ?? this.breaks,
    );
  }

  @override
  List<Object?> get props => [day, isOpen, openTime, closeTime, breaks];

  bool get isValid {
    if (!isOpen) return true;
    if (openTime == null || closeTime == null) return false;

    try {
      final open = DateTime.parse('2024-01-01T${openTime!}:00');
      final close = DateTime.parse('2024-01-01T${closeTime!}:00');

      if (close.isBefore(open)) {
        // Handle overnight hours (e.g., open 22:00, close 02:00)
        final nextDayClose = close.add(const Duration(days: 1));
        return nextDayClose.isAfter(open);
      }

      return close.isAfter(open);
    } catch (e) {
      return false;
    }
  }

  String get displayHours {
    if (!isOpen) return 'Closed';
    if (openTime == null || closeTime == null) return 'Hours not set';

    return '$openTime - $closeTime';
  }
}

@JsonSerializable()
class TimeBreak extends Equatable {
  final String startTime; // Format: "HH:MM"
  final String endTime; // Format: "HH:MM"
  final String? description;

  const TimeBreak({
    required this.startTime,
    required this.endTime,
    this.description,
  });

  factory TimeBreak.fromJson(Map<String, dynamic> json) =>
      _$TimeBreakFromJson(json);

  Map<String, dynamic> toJson() => _$TimeBreakToJson(this);

  TimeBreak copyWith({
    String? startTime,
    String? endTime,
    String? description,
  }) {
    return TimeBreak(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [startTime, endTime, description];

  bool get isValid {
    try {
      final start = DateTime.parse('2024-01-01T$startTime:00');
      final end = DateTime.parse('2024-01-01T$endTime:00');
      return end.isAfter(start);
    } catch (e) {
      return false;
    }
  }

  String get displayText {
    if (description != null && description!.isNotEmpty) {
      return '$startTime - $endTime ($description)';
    }
    return '$startTime - $endTime';
  }
}

@JsonSerializable()
class OpeningHours extends Equatable {
  final Map<String, DayOpeningHours> weeklyHours;
  final String? timezone;
  final bool is24Hours;
  final bool allowSpecialHours;

  const OpeningHours({
    required this.weeklyHours,
    this.timezone,
    this.is24Hours = false,
    this.allowSpecialHours = false,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);

  Map<String, dynamic> toJson() => _$OpeningHoursToJson(this);

  OpeningHours copyWith({
    Map<String, DayOpeningHours>? weeklyHours,
    String? timezone,
    bool? is24Hours,
    bool? allowSpecialHours,
  }) {
    return OpeningHours(
      weeklyHours: weeklyHours ?? this.weeklyHours,
      timezone: timezone ?? this.timezone,
      is24Hours: is24Hours ?? this.is24Hours,
      allowSpecialHours: allowSpecialHours ?? this.allowSpecialHours,
    );
  }

  @override
  List<Object?> get props => [weeklyHours, timezone, is24Hours, allowSpecialHours];

  factory OpeningHours.defaultHours() {
    final Map<String, DayOpeningHours> defaultHours = {};

    for (final day in DayOfWeek.values) {
      defaultHours[day.name] = DayOpeningHours(
        day: day,
        isOpen: day != DayOfWeek.sunday, // Closed on Sundays by default
        openTime: '09:00',
        closeTime: '17:00',
      );
    }

    return OpeningHours(weeklyHours: defaultHours);
  }

  factory OpeningHours.empty() {
    final Map<String, DayOpeningHours> emptyHours = {};

    for (final day in DayOfWeek.values) {
      emptyHours[day.name] = DayOpeningHours(
        day: day,
        isOpen: false,
      );
    }

    return OpeningHours(weeklyHours: emptyHours);
  }

  DayOpeningHours? getHoursForDay(DayOfWeek day) {
    return weeklyHours[day.name];
  }

  OpeningHours setHoursForDay(DayOfWeek day, DayOpeningHours hours) {
    final newHours = Map<String, DayOpeningHours>.from(weeklyHours);
    newHours[day.name] = hours;
    return copyWith(weeklyHours: newHours);
  }

  Map<String, dynamic> toLegacyJson() {
    if (is24Hours) {
      return {
        'type': '24_hours',
        'timezone': timezone,
      };
    }

    final Map<String, dynamic> legacyData = {
      'timezone': timezone,
      'schedule': {},
    };

    for (final entry in weeklyHours.entries) {
      final dayHours = entry.value;
      if (dayHours.isOpen && dayHours.isValid) {
        legacyData['schedule'][entry.key] = {
          'open': dayHours.openTime,
          'close': dayHours.closeTime,
          'breaks': dayHours.breaks?.map((b) => b.toJson()).toList(),
        };
      } else {
        legacyData['schedule'][entry.key] = null; // Closed
      }
    }

    return legacyData;
  }

  factory OpeningHours.fromLegacyJson(Map<String, dynamic>? json) {
    if (json == null) return OpeningHours.empty();

    if (json['type'] == '24_hours') {
      final Map<String, DayOpeningHours> hours24 = {};
      for (final day in DayOfWeek.values) {
        hours24[day.name] = DayOpeningHours(
          day: day,
          isOpen: true,
          openTime: '00:00',
          closeTime: '23:59',
        );
      }
      return OpeningHours(
        weeklyHours: hours24,
        timezone: json['timezone'],
        is24Hours: true,
      );
    }

    final Map<String, DayOpeningHours> weeklyHours = {};
    final schedule = json['schedule'] as Map<String, dynamic>? ?? {};

    for (final day in DayOfWeek.values) {
      final dayData = schedule[day.name];
      if (dayData == null) {
        weeklyHours[day.name] = DayOpeningHours(day: day, isOpen: false);
      } else {
        final List<dynamic>? breaksData = dayData['breaks'];
        final List<TimeBreak>? breaks = breaksData?.map((b) => TimeBreak.fromJson(b)).toList();

        weeklyHours[day.name] = DayOpeningHours(
          day: day,
          isOpen: true,
          openTime: dayData['open'],
          closeTime: dayData['close'],
          breaks: breaks,
        );
      }
    }

    return OpeningHours(
      weeklyHours: weeklyHours,
      timezone: json['timezone'],
    );
  }

  bool get isValid {
    for (final hours in weeklyHours.values) {
      if (!hours.isValid) return false;
    }
    return true;
  }

  bool get isOpenToday {
    final now = DateTime.now();
    final today = DayOfWeek.values[now.weekday - 1];
    return isOpenAtTime(now, today);
  }

  bool isOpenAtTime(DateTime dateTime, DayOfWeek? day) {
    final targetDay = day ?? DayOfWeek.values[dateTime.weekday - 1];
    final dayHours = getHoursForDay(targetDay);

    if (dayHours == null || !dayHours.isOpen) return false;
    if (is24Hours) return true;

    if (dayHours.openTime == null || dayHours.closeTime == null) return false;

    try {
      final currentTime = DateTime.parse('2024-01-01T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00');
      final openTime = DateTime.parse('2024-01-01T${dayHours.openTime!}:00');
      var closeTime = DateTime.parse('2024-01-01T${dayHours.closeTime!}:00');

      // Handle overnight hours
      if (closeTime.isBefore(openTime)) {
        closeTime = closeTime.add(const Duration(days: 1));
        if (currentTime.isBefore(openTime)) {
          final adjustedCurrentTime = currentTime.add(const Duration(days: 1));
          return adjustedCurrentTime.isAfter(openTime) && adjustedCurrentTime.isBefore(closeTime);
        }
      }

      // Check breaks
      if (dayHours.breaks != null) {
        for (final breakPeriod in dayHours.breaks!) {
          if (breakPeriod.isValid) {
            final breakStart = DateTime.parse('2024-01-01T${breakPeriod.startTime}:00');
            var breakEnd = DateTime.parse('2024-01-01T${breakPeriod.endTime}:00');

            // Handle overnight breaks
            if (breakEnd.isBefore(breakStart)) {
              breakEnd = breakEnd.add(const Duration(days: 1));
              if (currentTime.isBefore(breakStart)) {
                final adjustedCurrentTime = currentTime.add(const Duration(days: 1));
                if (adjustedCurrentTime.isAfter(breakStart) && adjustedCurrentTime.isBefore(breakEnd)) {
                  return false; // Closed during break
                }
              }
            } else if (currentTime.isAfter(breakStart) && currentTime.isBefore(breakEnd)) {
              return false; // Closed during break
            }
          }
        }
      }

      return currentTime.isAfter(openTime) && currentTime.isBefore(closeTime);
    } catch (e) {
      return false;
    }
  }

  String? getNextOpenTime(DateTime from) {
    DateTime checkTime = from;

    // Check next 7 days
    for (int i = 0; i < 7; i++) {
      final checkDay = DayOfWeek.values[(checkTime.weekday - 1 + i) % 7];
      final dayHours = getHoursForDay(checkDay);

      if (dayHours != null && dayHours.isOpen && dayHours.openTime != null) {
        if (i == 0) {
          // Check if it's still opening today
          try {
            final openTime = DateTime.parse('2024-01-01T${dayHours.openTime!}:00');
            final currentTime = DateTime.parse('2024-01-01T${checkTime.hour.toString().padLeft(2, '0')}:${checkTime.minute.toString().padLeft(2, '0')}:00');

            if (currentTime.isBefore(openTime)) {
              final openDate = DateTime(checkTime.year, checkTime.month, checkTime.day, openTime.hour, openTime.minute);
              if (openDate.isAfter(checkTime)) {
                return 'Opens today at ${dayHours.openTime}';
              }
            }
          } catch (e) {
            // Continue to next day
          }
        }

        // Return future opening time
        final openDate = DateTime(
          checkTime.year,
          checkTime.month,
          checkTime.day + i,
          int.parse(dayHours.openTime!.split(':')[0]),
          int.parse(dayHours.openTime!.split(':')[1]),
        );

        final dayName = i == 0 ? 'today' : i == 1 ? 'tomorrow' : checkDay.displayName;
        return 'Opens $dayName at ${dayHours.openTime}';
      }
    }

    return null;
  }
}