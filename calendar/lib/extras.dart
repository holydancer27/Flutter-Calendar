import 'package:flutter/material.dart';

Map<DateTime, List<Event>> events = {};

class Event {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final TimeOfDay? timeOfDay_;
  final String title;
  final String? description;
  const Event({required this.title, required this.description, this.timeOfDay_, this.rangeStart, this.rangeEnd});
}

List<DateTime> daysInRange(DateTime first, DateTime last){
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
  dayCount, 
  (index) => DateTime.utc(first.year, first.month, first.day + index)
  );
}
