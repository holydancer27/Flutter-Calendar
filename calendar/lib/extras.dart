import 'package:flutter/material.dart';

Map<DateTime, List<Event>> events = {};

class Event {
  final int id;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final TimeOfDay? timeRangeStart;
  final TimeOfDay? timeRangeEnd;
  final String title;
  final String? description;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.timeRangeStart,
    this.timeRangeEnd,
    this.rangeStart,
    this.rangeEnd,
  });

  // Convert Event to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rangeStart': rangeStart?.toIso8601String(),
      'rangeEnd': rangeEnd?.toIso8601String(),
      'timeRangeStart': timeRangeStart != null
          ? '${timeRangeStart!.hour}:${timeRangeStart!.minute}'
          : null,
      'timeRangeEnd': timeRangeEnd != null
          ? '${timeRangeEnd!.hour}:${timeRangeEnd!.minute}'
          : null,
    };
  }

  // Create Event from Map retrieved from database
  factory Event.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    }

    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      rangeStart: parseDate(map['rangeStart']),
      rangeEnd: parseDate(map['rangeEnd']),
      timeRangeStart: parseTime(map['timeRangeStart']),
      timeRangeEnd: parseTime(map['timeRangeEnd']),
    );
  }
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
