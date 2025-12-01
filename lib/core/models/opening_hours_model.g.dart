// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_hours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayOpeningHours _$DayOpeningHoursFromJson(Map<String, dynamic> json) =>
    DayOpeningHours(
      day: $enumDecode(_$DayOfWeekEnumMap, json['day']),
      isOpen: json['isOpen'] as bool? ?? false,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      breaks: (json['breaks'] as List<dynamic>?)
          ?.map((e) => TimeBreak.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DayOpeningHoursToJson(DayOpeningHours instance) =>
    <String, dynamic>{
      'day': _$DayOfWeekEnumMap[instance.day]!,
      'isOpen': instance.isOpen,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'breaks': instance.breaks,
    };

const _$DayOfWeekEnumMap = {
  DayOfWeek.monday: 'monday',
  DayOfWeek.tuesday: 'tuesday',
  DayOfWeek.wednesday: 'wednesday',
  DayOfWeek.thursday: 'thursday',
  DayOfWeek.friday: 'friday',
  DayOfWeek.saturday: 'saturday',
  DayOfWeek.sunday: 'sunday',
};

TimeBreak _$TimeBreakFromJson(Map<String, dynamic> json) => TimeBreak(
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$TimeBreakToJson(TimeBreak instance) => <String, dynamic>{
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'description': instance.description,
};

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) => OpeningHours(
  weeklyHours: (json['weeklyHours'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, DayOpeningHours.fromJson(e as Map<String, dynamic>)),
  ),
  timezone: json['timezone'] as String?,
  is24Hours: json['is24Hours'] as bool? ?? false,
  allowSpecialHours: json['allowSpecialHours'] as bool? ?? false,
);

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'weeklyHours': instance.weeklyHours,
      'timezone': instance.timezone,
      'is24Hours': instance.is24Hours,
      'allowSpecialHours': instance.allowSpecialHours,
    };
