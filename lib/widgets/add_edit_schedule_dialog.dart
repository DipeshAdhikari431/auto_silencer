import 'package:auto_silencer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class AddEditScheduleDialog extends StatefulWidget {
  final Schedule? schedule;
  const AddEditScheduleDialog({this.schedule, super.key});

  @override
  State<AddEditScheduleDialog> createState() => _AddEditScheduleDialogState();
}

class _AddEditScheduleDialogState extends State<AddEditScheduleDialog> {
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final TextEditingController _titleController = TextEditingController();
  late VoidCallback _titleListener;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _startDateTime = widget.schedule!.startDateTime;
      _endDateTime = widget.schedule!.endDateTime;
      _titleController.text = widget.schedule!.title ?? '';
    }
    _titleListener = () => setState(() {});
    _titleController.addListener(_titleListener);
  }

  @override
  void dispose() {
    _titleController.removeListener(_titleListener);
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDateTime ?? now)
        : (_endDateTime ?? _startDateTime ?? now);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _startDateTime = combined;
          } else {
            _endDateTime = combined;
          }
        });
      }
    }
  }

  String? _getDateTimeError() {
    if (_startDateTime != null && _endDateTime != null) {
      if (!_endDateTime!.isAfter(_startDateTime!)) {
        return AppLocalizations.of(context).endAfterStart;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeError = _getDateTimeError();
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.schedule == null
            ? localizations.addSchedule
            : localizations.editSchedule,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: localizations.scheduleTitle),
          ),
          ListTile(
            title: Text(
              _startDateTime == null
                  ? localizations.selectStart
                  : '${localizations.start}: ${_startDateTime!.toLocal().toString().substring(0, 16)}',
            ),
            trailing: const Icon(Icons.event),
            onTap: () => _pickDateTime(true),
          ),
          ListTile(
            title: Text(
              _endDateTime == null
                  ? localizations.selectEnd
                  : '${localizations.end}: ${_endDateTime!.toLocal().toString().substring(0, 16)}',
            ),
            trailing: const Icon(Icons.event),
            onTap: () => _pickDateTime(false),
          ),
          if (dateTimeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                dateTimeError,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed:
              _startDateTime != null &&
                  _endDateTime != null &&
                  _titleController.text.trim().isNotEmpty &&
                  dateTimeError == null
              ? () {
                  Navigator.of(context).pop(
                    Schedule(
                      _startDateTime!,
                      _endDateTime!,
                      title: _titleController.text.trim(),
                    ),
                  );
                }
              : null,
          child: Text(
            widget.schedule == null ? localizations.add : localizations.save,
          ),
        ),
      ],
    );
  }
}
