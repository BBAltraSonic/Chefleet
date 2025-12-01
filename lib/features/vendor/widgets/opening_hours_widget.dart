import 'package:flutter/material.dart';
import '../../core/models/opening_hours_model.dart';
import '../../core/services/opening_hours_service.dart';

class OpeningHoursWidget extends StatefulWidget {
  final OpeningHours openingHours;
  final ValueChanged<OpeningHours> onChanged;
  final bool enabled;
  final bool showValidation;

  const OpeningHoursWidget({
    Key? key,
    required this.openingHours,
    required this.onChanged,
    this.enabled = true,
    this.showValidation = true,
  }) : super(key: key);

  @override
  State<OpeningHoursWidget> createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends State<OpeningHoursWidget> {
  late OpeningHours _openingHours;
  Map<String, bool> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _openingHours = widget.openingHours;

    // Initialize expanded state
    for (final day in DayOfWeek.values) {
      _expandedDays[day.name] = false;
    }
  }

  @override
  void didUpdateWidget(OpeningHoursWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openingHours != _openingHours) {
      setState(() {
        _openingHours = widget.openingHours;
      });
    }
  }

  void _updateOpeningHours(OpeningHours newHours) {
    setState(() {
      _openingHours = newHours;
    });
    widget.onChanged(newHours);
  }

  void _updateDayHours(DayOfWeek day, DayOpeningHours dayHours) {
    _updateOpeningHours(_openingHours.setHoursForDay(day, dayHours));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showValidation)
          _buildValidationStatus(),
        const SizedBox(height: 16),

        // 24 hours option
        _build24HoursOption(),

        const SizedBox(height: 16),

        // Weekly hours
        if (!_openingHours.is24Hours) ...[
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildWeeklyHours(),
        ],
      ],
    );
  }

  Widget _buildValidationStatus() {
    final validation = OpeningHoursService.validateOpeningHours(_openingHours);

    return Card(
      color: validation.isValid ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  validation.isValid ? Icons.check_circle : Icons.error,
                  color: validation.isValid ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  validation.isValid ? 'Opening hours are valid' : 'Please fix the errors below',
                  style: TextStyle(
                    color: validation.isValid ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (!validation.isValid) ...[
              const SizedBox(height: 8),
              ...validation.errors.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DayOfWeek.fromString(entry.key).displayName}: ',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.join(', '),
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            if (validation.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...validation.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _build24HoursOption() {
    return SwitchListTile(
      title: const Text('Open 24/7'),
      subtitle: const Text('Your business is open all day, every day'),
      value: _openingHours.is24Hours,
      onChanged: widget.enabled ? (value) {
        if (value) {
          _updateOpeningHours(OpeningHours(
            weeklyHours: _openingHours.weeklyHours,
            is24Hours: true,
            timezone: _openingHours.timezone,
          ));
        } else {
          _updateOpeningHours(_openingHours.copyWith(is24Hours: false));
        }
      } : null,
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionButton(
                  'Weekdays',
                  'Set Mon-Fri',
                  () => _applyWeekdayHours(),
                ),
                _buildQuickActionButton(
                  'Weekends',
                  'Set Sat-Sun',
                  () => _applyWeekendHours(),
                ),
                _buildQuickActionButton(
                  'All Days',
                  'Same hours',
                  () => _applyToAllDays(),
                ),
                _buildQuickActionButton(
                  'Clear All',
                  'Reset hours',
                  () => _clearAllHours(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: widget.enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Hours',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...DayOfWeek.values.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(DayOfWeek day) {
    final dayHours = _openingHours.getHoursForDay(day) ??
                   DayOpeningHours(day: day);
    final isExpanded = _expandedDays[day.name] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  day.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (dayHours.isOpen) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dayHours.displayHours,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: !dayHours.isOpen
                ? const Text('Closed', style: TextStyle(color: Colors.grey))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: dayHours.isOpen,
                  onChanged: widget.enabled ? (value) {
                    _updateDayHours(day, dayHours.copyWith(isOpen: value));
                  } : null,
                ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expandedDays[day.name] = !isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          if (isExpanded && dayHours.isOpen)
            _buildDayExpandedContent(day, dayHours),
        ],
      ),
    );
  }

  Widget _buildDayExpandedContent(DayOfWeek day, DayOpeningHours dayHours) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimeRangeRow(
            'Operating Hours',
            dayHours.openTime,
            dayHours.closeTime,
            (openTime) => _updateDayHours(day, dayHours.copyWith(openTime: openTime)),
            (closeTime) => _updateDayHours(day, dayHours.copyWith(closeTime: closeTime)),
          ),

          const SizedBox(height: 16),

          _buildBreaksSection(day, dayHours),

          const SizedBox(height: 16),

          _buildCopyToOtherDaysButton(day, dayHours),
        ],
      ),
    );
  }

  Widget _buildTimeRangeRow(
    String label,
    String? startTime,
    String? endTime,
    Function(String?) onStartTimeChanged,
    Function(String?) onEndTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeDropdown(
                'Open',
                startTime,
                OpeningHoursService.getCommonOpeningTimes(),
                onStartTimeChanged,
              ),
            ),
            const SizedBox(width: 16),
            const Text('to'),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeDropdown(
                'Close',
                endTime,
                OpeningHoursService.getCommonClosingTimes(),
                onEndTimeChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDropdown(
    String label,
    String? selectedTime,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedTime,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: options.map((time) {
        return DropdownMenuItem(
          value: time,
          child: Text(time),
        );
      }).toList(),
      onChanged: widget.enabled ? onChanged : null,
      isExpanded: true,
    );
  }

  Widget _buildBreaksSection(DayOfWeek day, DayOpeningHours dayHours) {
    final breaks = dayHours.breaks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Breaks', style: TextStyle(fontWeight: FontWeight.w500)),
            TextButton.icon(
              onPressed: widget.enabled ? () {
                final newBreaks = [...breaks, TimeBreak(startTime: '12:00', endTime: '13:00')];
                _updateDayHours(day, dayHours.copyWith(breaks: newBreaks));
              } : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Break'),
            ),
          ],
        ),

        if (breaks.isEmpty)
          const Text('No breaks scheduled', style: TextStyle(color: Colors.grey))
        else
          ...breaks.asMap().entries.map((entry) =>
            _buildBreakRow(day, dayHours, entry.key, entry.value)),
      ],
    );
  }

  Widget _buildBreakRow(DayOfWeek day, DayOpeningHours dayHours, int index, TimeBreak timeBreak) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeDropdown(
              'Start',
              timeBreak.startTime,
              OpeningHoursService.timeSlots,
              (newTime) {
                final newBreaks = [...(dayHours.breaks ?? [])];
                newBreaks[index] = timeBreak.copyWith(startTime: newTime);
                _updateDayHours(day, dayHours.copyWith(breaks: newBreaks));
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text('to'),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTimeDropdown(
              'End',
              timeBreak.endTime,
              OpeningHoursService.timeSlots,
              (newTime) {
                final newBreaks = [...(dayHours.breaks ?? [])];
                newBreaks[index] = timeBreak.copyWith(endTime: newTime);
                _updateDayHours(day, dayHours.copyWith(breaks: newBreaks));
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.enabled ? () {
              final newBreaks = [...(dayHours.breaks ?? [])];
              newBreaks.removeAt(index);
              _updateDayHours(day, dayHours.copyWith(breaks: newBreaks.isNotEmpty ? newBreaks : null));
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyToOtherDaysButton(DayOfWeek day, DayOpeningHours dayHours) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.enabled ? () {
          _showCopyToDaysDialog(day, dayHours);
        } : null,
        icon: const Icon(Icons.copy, size: 16),
        label: const Text('Copy to other days'),
      ),
    );
  }

  void _applyWeekdayHours() {
    final weekdayHours = DayOpeningHours(
      day: DayOfWeek.monday,
      isOpen: true,
      openTime: '09:00',
      closeTime: '17:00',
    );

    final weekdays = [DayOfWeek.monday, DayOfWeek.tuesday, DayOfWeek.wednesday, DayOfWeek.thursday, DayOfWeek.friday];
    OpeningHours newHours = _openingHours;

    for (final day in weekdays) {
      newHours = newHours.setHoursForDay(day, weekdayHours.copyWith(day: day));
    }

    _updateOpeningHours(newHours);
  }

  void _applyWeekendHours() {
    final weekendHours = DayOpeningHours(
      day: DayOfWeek.saturday,
      isOpen: true,
      openTime: '10:00',
      closeTime: '15:00',
    );

    final weekends = [DayOfWeek.saturday, DayOfWeek.sunday];
    OpeningHours newHours = _openingHours;

    for (final day in weekends) {
      newHours = newHours.setHoursForDay(day, weekendHours.copyWith(day: day));
    }

    _updateOpeningHours(newHours);
  }

  void _applyToAllDays() {
    final mondayHours = _openingHours.getHoursForDay(DayOfWeek.monday) ??
                        OpeningHoursService.createDefaultDayHours(DayOfWeek.monday);

    final days = DayOfWeek.values;
    OpeningHours newHours = _openingHours;

    for (final day in days) {
      newHours = newHours.setHoursForDay(day, mondayHours.copyWith(day: day));
    }

    _updateOpeningHours(newHours);
  }

  void _clearAllHours() {
    _updateOpeningHours(OpeningHours.empty());
  }

  void _showCopyToDaysDialog(DayOfWeek sourceDay, DayOpeningHours sourceHours) {
    final selectedDays = <DayOfWeek>{};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Copy ${sourceDay.displayName} Hours'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Copy hours from ${sourceDay.displayName} to:'),
                const SizedBox(height: 16),
                ...DayOfWeek.values.where((day) => day != sourceDay).map((day) =>
                  CheckboxListTile(
                    title: Text(day.displayName),
                    value: selectedDays.contains(day),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedDays.isEmpty ? null : () {
              OpeningHours newHours = _openingHours;
              for (final day in selectedDays) {
                newHours = newHours.setHoursForDay(day, sourceHours.copyWith(day: day));
              }
              _updateOpeningHours(newHours);
              Navigator.of(context).pop();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}