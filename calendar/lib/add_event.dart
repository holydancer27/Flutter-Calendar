import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'extras.dart';

class AddEvent extends StatelessWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final DateTime? pickedDate;

  const AddEvent({super.key, this.rangeStart, this.rangeEnd, this.pickedDate});

  @override
  Widget build(BuildContext context) {
    return _buildAddEventScaffold(context);
  }

  Widget _buildAddEventScaffold(BuildContext context) {

    final TextEditingController controller = TextEditingController();
    String? userDescription;
    String userTitle = '';
    TimeOfDay? userTime;
    DateTime pickedDate_ = pickedDate ?? DateTime.now();
    bool allDay = true;
    bool isRange = rangeStart != null && rangeEnd != null; 
    TimeOfDay? timeRangeStart = TimeOfDay.now();
    TimeOfDay? timeRangeEnd = TimeOfDay.now();
    DateTime? rangeStart_ = rangeStart;
    DateTime? rangeEnd_ = rangeEnd;

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
                            Text("Tutto il giorno"),
                            SizedBox(width: 15),
                            Switch(
                              value: isRange, 
                              onChanged: (value) {
                                setState(() {
                                  isRange = value;
                                });
                              },
                            ),
                            Text("Più giorni"),
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
                                        isRange == false
                                        ? pickedDate_ = date
                                        : rangeStart_ = date;
                                      });
                                    }
                                  },
                                  child: Text(
                                    rangeStart_ != null && rangeEnd_ != null
                                      ? rangeStart.toString().split(' ')[0]
                                      : normalizeDate(pickedDate_).toString().split(' ')[0]
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
                                    child: Text("${timeRangeStart!.hour}:${timeRangeStart!.minute}")
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
                                        pickedDate_ = date;
                                      });
                                    }
                                  },
                                  child: Text(
                                    rangeStart_ != null && rangeEnd_ != null
                                      ? rangeEnd_.toString().split(' ')[0]
                                      : normalizeDate(pickedDate_).toString().split(' ')[0]
                                    ),
                                  ),
                                Visibility(
                                  visible: !allDay,
                                  child: TextButton(
                                    onPressed: () async {
                                      // use timeRangeStart + 1 hour if available, otherwise now
                                      final initial = timeRangeEnd != null
                                        ? TimeOfDay(
                                            hour: (timeRangeEnd!.hour + 1) % 24,
                                            minute: timeRangeEnd!.minute,
                                          )
                                        : TimeOfDay.now();

                                      final time = await showAppTimePicker(context, initialTime: initial);
                                      if (time != null) {
                                        setState(() {
                                          timeRangeEnd = time;
                                        });
                                      }
                                    },
                                    child: Text("${timeRangeEnd!.hour}:${timeRangeEnd!.minute}"),
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
          if (userTitle.isEmpty) {
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
                    Text("Titolo è obbligatorio")
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
            if (rangeStart_ != null && rangeEnd_ != null) {
              final event = Event(
                title: userTitle,
                description: userDescription,
                timeRangeStart: userTime,
                rangeStart: rangeStart_,
                rangeEnd: rangeEnd_,
              );

              if(events[normalizeDate(rangeStart_!)] != null){
                events[normalizeDate(rangeStart_!)]!.add(event);
              } else{
                events[normalizeDate(rangeStart_!)] = [event];
              }
              if(events[normalizeDate(rangeEnd_)] != null){
                events[normalizeDate(rangeEnd_)]!.add(event);
              } else{
                events[normalizeDate(rangeEnd_)] = [event];
              }

            } else {
              // Single day event
              final event = Event(
                title: userTitle,
                description: userDescription,
                timeRangeStart: userTime,
              );
              final normalized = normalizeDate(pickedDate_);
              if (events[normalized] != null) {
                events[normalized]!.add(event);
              } else {
                events[normalized] = [event];
              }
            }
            Navigator.of(context).pop();
            controller.clear();
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