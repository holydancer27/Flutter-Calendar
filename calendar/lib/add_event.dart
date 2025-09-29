import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'extras.dart';
import 'main.dart';

class AddEvent extends StatelessWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const AddEvent({super.key, this.rangeStart, this.rangeEnd});

  @override
  Widget build(BuildContext context) {
    return _buildAddEventScaffold(context);
  }

  Widget _buildAddEventScaffold(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    String? userDescription;
    String userTitle = '';
    TimeOfDay? userTime;
    DateTime pickedDate = DateTime.now();
    bool allDay = true;
    TimeOfDay? timeRangeStart;
    TimeOfDay? timeRangeEnd;

    // Function for showing the date picker
    Future<DateTime?> showAppDatePicker(BuildContext context, {DateTime? initialDate}) async {
      return await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        locale: const Locale('it', 'IT'),
        firstDate: DateTime(1970, 1, 1),
        lastDate: DateTime(DateTime.now().year + 10, 1, 1),
      );
    }

    // Function for showing the time picker
    Future<TimeOfDay?> showAppTimePicker(BuildContext context, {TimeOfDay? initialTime}) async {
      return await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.dialOnly,
        initialTime: initialTime ?? TimeOfDay.now(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                        Text("Titolo", textAlign: TextAlign.start),
                        TextField(
                          onChanged: (userText) {
                            setState(() {
                              userTitle = userText;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                            hintText: "Necessario"
                          ),
                        ),
                        SizedBox(height: 15),
                        Text("Descrizione"),
                        TextField(
                          maxLines: 8,
                          textAlignVertical: TextAlignVertical(y: 0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(width: 1))
                          ),
                          onChanged: (userText) {
                            setState(() {
                              userDescription = userText;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        Row(
                          spacing: 15,
                          children: [
                            Switch(
                              value: allDay,
                              onChanged: (value) {
                                setState(() {
                                  allDay = value;
                                });
                              },
                            ),
                            Text("Tutto il giorno")
                          ],
                        ),
                        SizedBox(height: 15),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final date = await showAppDatePicker(context, initialDate: pickedDate);
                                    if (date != null) {
                                      setState(() {
                                        pickedDate = date;
                                      });
                                    }
                                  },
                                  child: Text(
                                    rangeStart != null && rangeEnd != null
                                      ? rangeStart.toString().split(' ')[0]
                                      : normalizeDate(pickedDate).toString().split(' ')[0]
                                    ),
                                  ),
                                Visibility(
                                  visible: !allDay,
                                  child: TextButton(
                                    onPressed: () async {
                                      final time = await showAppTimePicker(context, initialTime: timeRangeStart);
                                      if (time != null) {
                                        setState(() {
                                          timeRangeStart = time;
                                        });
                                      }
                                      
                                    }, 
                                    child: Text(
                                      timeRangeStart.toString() == 'null'
                                        ? "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}"
                                        : "${timeRangeStart!.hour}:${timeRangeStart!.minute}",
                                    )
                                  )
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final date = await showAppDatePicker(context, initialDate: pickedDate);
                                    if (date != null) {
                                      setState(() {
                                        pickedDate = date;
                                      });
                                    }
                                  },
                                  child: Text(
                                    rangeStart != null && rangeEnd != null
                                      ? rangeEnd.toString().split(' ')[0]
                                      : normalizeDate(pickedDate).toString().split(' ')[0]
                                    ),
                                  ),
                                Visibility(
                                  visible: !allDay,
                                  child: TextButton(
                                    onPressed: () async {
                                      final time = await showAppTimePicker(context, initialTime: timeRangeStart);
                                      if (time != null) {
                                        setState(() {
                                          timeRangeEnd = time;
                                        });
                                      }
                                      
                                    }, 
                                    child: Text(
                                      timeRangeEnd.toString() == 'null'
                                        ? "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}"
                                        : "${timeRangeEnd!.hour}:${timeRangeEnd!.minute}", 
                                    ),
                                  )
                                ),
                              ],
                            )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userTitle.isEmpty || (rangeStart == null && pickedDate == null)) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 32,),
                    Text("Errore")
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Titolo e data sono campi obbligatori")
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK")
                  )
                ],
              ),
            );
            return;
          } else {
            if (allDay) {
              userTime = null;
            }
            // If range is provided, add event for all days in range
            if (rangeStart != null && rangeEnd != null) {
              final event = Event(
                title: userTitle,
                description: userDescription,
                timeOfDay_: userTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
              );
            
              if(events[normalizeDate(rangeStart!)] != null){
                events[normalizeDate(rangeStart!)]!.add(event);
              }
              if(events[normalizeDate(rangeEnd!)] != null){
                events[normalizeDate(rangeEnd!)]!.add(event);
              }

            } else {
              // Single day event
              final event = Event(
                title: userTitle,
                description: userDescription,
                timeOfDay_: userTime,
              );
              final normalized = normalizeDate(pickedDate);
              if (events[normalized] != null) {
                events[normalized]!.add(event);
              } else {
                events[normalized] = [event];
              }
            }
            Navigator.of(context).pop();
            _controller.clear();
            userTitle = '';
            userDescription = null;
          }
        },
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(Icons.check),
      ),
    );
  }
}