import 'package:flutter/material.dart';
import '../../../core/models/opening_hours_model.dart';
import '../../../core/services/opening_hours_service.dart';

class OpeningHoursSelectorWidget extends StatefulWidget {
  final Map<String, dynamic>? initialHoursJson;
  final ValueChanged<Map<String, dynamic>> onHoursChanged;
  final bool enabled;

  const OpeningHoursSelectorWidget({
    Key? key,
    this.initialHoursJson,
    required this.onHoursChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<OpeningHoursSelectorWidget> createState() => _OpeningHoursSelectorWidgetState();
}

class _OpeningHoursSelectorWidgetState extends State<OpeningHoursSelectorWidget> {
  late OpeningHours _openingHours;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _openingHours = _initializeOpeningHours();
  }

  OpeningHours _initializeOpeningHours() {
    if (widget.initialHoursJson != null) {
      final fromNewFormat = OpeningHoursService.openingHoursFromMap(widget.initialHoursJson);
      if (fromNewFormat != null) {
        return fromNewFormat;
      }

      // Try legacy format
      final fromLegacy = OpeningHours.fromLegacyJson(widget.initialHoursJson);
      return fromLegacy;
    }

    return OpeningHoursService.createDefaultOpeningHours();
  }

  void _onOpeningHoursChanged(OpeningHours newHours) {
    setState(() {
      _openingHours = newHours;
    });
    widget.onHoursChanged(_openingHours.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),

        if (!_showAdvanced)
          _buildSimpleMode()
        else
          _buildAdvancedMode(),

        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: widget.enabled ? () {
              setState(() {
                _showAdvanced = !_showAdvanced;
              });
            } : null,
            icon: Icon(_showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            label: Text(_showAdvanced ? 'Show Less' : 'Advanced Settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Business Hours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final statusText = OpeningHoursService.getNextStatusDisplay(_openingHours);
    final isOpen = _openingHours.isOpenToday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isOpen ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildSimpleMode() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickPresets(),
            const SizedBox(height: 16),
            _buildBasicHoursGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Presets',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetButton('24/7', () => _apply247Preset()),
            _buildPresetButton('Standard', () => _applyStandardPreset()),
            _buildPresetButton('Weekends Only', () => _applyWeekendsPreset()),
            _buildPresetButton('Evenings Only', () => _applyEveningsPreset()),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: widget.enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildBasicHoursGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Basic Hours',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildDayHoursToggle(DayOfWeek.monday, 'Mon'),
            _buildDayHoursToggle(DayOfWeek.tuesday, 'Tue'),
            _buildDayHoursToggle(DayOfWeek.wednesday, 'Wed'),
            _buildDayHoursToggle(DayOfWeek.thursday, 'Thu'),
            _buildDayHoursToggle(DayOfWeek.friday, 'Fri'),
            _buildDayHoursToggle(DayOfWeek.saturday, 'Sat'),
            _buildDayHoursToggle(DayOfWeek.sunday, 'Sun'),
            _buildWeekdayToggle(),
          ],
        ),
      ],
    );
  }

  Widget _buildDayHoursToggle(DayOfWeek day, String label) {
    final dayHours = _openingHours.getHoursForDay(day) ??
                    DayOpeningHours(day: day);
    final isOpen = dayHours.isOpen;

    return InkWell(
      onTap: widget.enabled ? () {
        if (isOpen) {
          // Close the day
          _onOpeningHoursChanged(_openingHours.setHoursForDay(
            day,
            dayHours.copyWith(isOpen: false),
          ));
        } else {
          // Open the day with default hours
          _onOpeningHoursChanged(_openingHours.setHoursForDay(
            day,
            dayHours.copyWith(
              isOpen: true,
              openTime: '09:00',
              closeTime: '17:00',
            ),
          ));
        }
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isOpen ? Colors.green.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isOpen ? Colors.green.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isOpen ? Colors.green.shade700 : Colors.grey.shade700,
                ),
              ),
            ),
            if (isOpen && dayHours.openTime != null && dayHours.closeTime != null)
              Expanded(
                child: Text(
                  '${dayHours.openTime}-${dayHours.closeTime}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayToggle() {
    final weekdays = [DayOfWeek.monday, DayOfWeek.tuesday, DayOfWeek.wednesday, DayOfWeek.thursday, DayOfWeek.friday];
    final allWeekdaysOpen = weekdays.every((day) {
      final dayHours = _openingHours.getHoursForDay(day);
      return dayHours?.isOpen == true;
    });

    return InkWell(
      onTap: widget.enabled ? () {
        final targetState = !allWeekdaysOpen;
        OpeningHours newHours = _openingHours;

        for (final day in weekdays) {
          final currentHours = _openingHours.getHoursForDay(day) ??
                              DayOpeningHours(day: day);
          newHours = newHours.setHoursForDay(
            day,
            currentHours.copyWith(
              isOpen: targetState,
              openTime: targetState ? '09:00' : null,
              closeTime: targetState ? '17:00' : null,
            ),
          );
        }

        _onOpeningHoursChanged(newHours);
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: allWeekdaysOpen ? Colors.blue.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: allWeekdaysOpen ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Weekdays',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: allWeekdaysOpen ? Colors.blue.shade700 : Colors.grey.shade700,
                ),
              ),
            ),
            Icon(
              allWeekdaysOpen ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: allWeekdaysOpen ? Colors.blue.shade600 : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedMode() {
    return Column(
      children: [
        _buildCustomHoursToggle(),
        const SizedBox(height: 16),
        if (!_openingHours.is24Hours)
          _buildAdvancedHoursGrid(),
      ],
    );
  }

  Widget _buildCustomHoursToggle() {
    return SwitchListTile(
      title: const Text('Open 24/7'),
      subtitle: Text(_openingHours.is24Hours ? 'Always open' : 'Set specific hours'),
      value: _openingHours.is24Hours,
      onChanged: widget.enabled ? (value) {
        if (value) {
          _onOpeningHoursChanged(OpeningHours(
            weeklyHours: _openingHours.weeklyHours,
            is24Hours: true,
            timezone: _openingHours.timezone,
          ));
        } else {
          _onOpeningHoursChanged(_openingHours.copyWith(is24Hours: false));
        }
      } : null,
    );
  }

  Widget _buildAdvancedHoursGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Hours',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...DayOfWeek.values.map((day) => _buildAdvancedDayRow(day)),
      ],
    );
  }

  Widget _buildAdvancedDayRow(DayOfWeek day) {
    final dayHours = _openingHours.getHoursForDay(day) ??
                    DayOpeningHours(day: day);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 80,
            child: Text(
              day.displayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // Open/Closed toggle
          Switch(
            value: dayHours.isOpen,
            onChanged: widget.enabled ? (value) {
              final updatedHours = dayHours.copyWith(
                isOpen: value,
                openTime: value ? (dayHours.openTime ?? '09:00') : null,
                closeTime: value ? (dayHours.closeTime ?? '17:00') : null,
              );
              _onOpeningHoursChanged(_openingHours.setHoursForDay(day, updatedHours));
            } : null,
          ),

          const SizedBox(width: 8),

          if (dayHours.isOpen) ...[
            // Open time
            Expanded(
              child: DropdownButtonFormField<String>(
                value: dayHours.openTime,
                decoration: const InputDecoration(
                  labelText: 'Open',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                items: OpeningHoursService.timeSlots.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: widget.enabled ? (newTime) {
                  if (newTime != null) {
                    final updatedHours = dayHours.copyWith(openTime: newTime);
                    _onOpeningHoursChanged(_openingHours.setHoursForDay(day, updatedHours));
                  }
                } : null,
              ),
            ),

            const SizedBox(width: 8),

            // Close time
            Expanded(
              child: DropdownButtonFormField<String>(
                value: dayHours.closeTime,
                decoration: const InputDecoration(
                  labelText: 'Close',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                items: OpeningHoursService.timeSlots.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: widget.enabled ? (newTime) {
                  if (newTime != null) {
                    final updatedHours = dayHours.copyWith(closeTime: newTime);
                    _onOpeningHoursChanged(_openingHours.setHoursForDay(day, updatedHours));
                  }
                } : null,
              ),
            ),
          ] else ...[
            const Expanded(
              child: Text(
                'Closed',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _apply247Preset() {
    _onOpeningHoursChanged(OpeningHours(
      weeklyHours: _openingHours.weeklyHours,
      is24Hours: true,
      timezone: _openingHours.timezone,
    ));
  }

  void _applyStandardPreset() {
    final standardHours = DayOpeningHours(
      day: DayOfWeek.monday,
      isOpen: true,
      openTime: '09:00',
      closeTime: '17:00',
    );

    OpeningHours newHours = _openingHours.copyWith(is24Hours: false);
    for (final day in DayOfWeek.values) {
      if (day == DayOfWeek.saturday || day == DayOfWeek.sunday) {
        newHours = newHours.setHoursForDay(day, standardHours.copyWith(
          day: day,
          openTime: '10:00',
          closeTime: '15:00',
        ));
      } else {
        newHours = newHours.setHoursForDay(day, standardHours.copyWith(day: day));
      }
    }

    _onOpeningHoursChanged(newHours);
  }

  void _applyWeekendsPreset() {
    OpeningHours newHours = _openingHours.copyWith(is24Hours: false);

    for (final day in DayOfWeek.values) {
      if (day == DayOfWeek.saturday || day == DayOfWeek.sunday) {
        newHours = newHours.setHoursForDay(day, DayOpeningHours(
          day: day,
          isOpen: true,
          openTime: '10:00',
          closeTime: '18:00',
        ));
      } else {
        newHours = newHours.setHoursForDay(day, DayOpeningHours(day: day, isOpen: false));
      }
    }

    _onOpeningHoursChanged(newHours);
  }

  void _applyEveningsPreset() {
    OpeningHours newHours = _openingHours.copyWith(is24Hours: false);

    for (final day in DayOfWeek.values) {
      if (day == DayOfWeek.saturday || day == DayOfWeek.sunday) {
        newHours = newHours.setHoursForDay(day, DayOpeningHours(day: day, isOpen: false));
      } else {
        newHours = newHours.setHoursForDay(day, DayOpeningHours(
          day: day,
          isOpen: true,
          openTime: '17:00',
          closeTime: '22:00',
        ));
      }
    }

    _onOpeningHoursChanged(newHours);
  }
}