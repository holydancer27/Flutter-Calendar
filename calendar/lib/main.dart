import 'dart:ffi';
import 'dart:math';
import 'add_event.dart';
import 'extras.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'db_manager.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendar',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('it', ''), // Italian
      ],
      theme:
        ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _controller = TextEditingController();
  bool isTimePickerVisible = false;
  DateTime? rangeStart;
  DateTime? rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DatabaseManager db = DatabaseManager();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              rangeSelectionMode: _rangeSelectionMode,
              rangeStartDay: rangeStart,
              rangeEndDay: rangeEnd,
              focusedDay: _focusedDay,
              firstDay: DateTime(1970, 1, 1),
              lastDay: DateTime(DateTime.now().year + 10, 1, 1),
              locale: "it_IT",
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,

              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  shape: BoxShape.rectangle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.rectangle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  shape: BoxShape.rectangle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  shape: BoxShape.rectangle,
                ),
                rangeHighlightColor: Colors.lightBlueAccent.withAlpha(100),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (day) {
                return events[normalizeDate(day)] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    rangeStart = null;
                    rangeEnd = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });
                }
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {              
                  _selectedDay = null;
                  _focusedDay = focusedDay;
                  rangeStart = start;
                  rangeEnd = end;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay){
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, eventsForDay) {
                  if (eventsForDay.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: min(eventsForDay.length, 3),
                      itemBuilder: (context, index) {
                        final event = eventsForDay[index] as Event;
                        return Container(
                          margin: const EdgeInsets.only(top: 40, left: 1),
                          padding: const EdgeInsets.all(1),
                          width: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (event.rangeStart != null && event.rangeEnd != null)
                              ? Colors.grey
                              : Colors.blueAccent,
                          ),
                        );
                      },
                    );
                  }
                  return null;
                },
              ),
            ),
            // Display events for the selected day
            Expanded(
              child: _selectedDay != null && events[normalizeDate(_selectedDay!)] != null
                ? ListView.builder(
                    itemCount: events[normalizeDate(_selectedDay!)]!.length,
                    itemBuilder: (context, index) {
                      final event = events[normalizeDate(_selectedDay!)]![index];
                      String timeRangeStartTxt = '';
                      String timeRangeEndTxt = '';
                      if (event.timeRangeStart != null && event.timeRangeEnd != null) {
                        timeRangeStartTxt = "${event.timeRangeStart!.hour.toString().padLeft(2, '0')}:${event.timeRangeStart!.minute.toString().padLeft(2, '0')} - ";
                        timeRangeEndTxt = "${event.timeRangeEnd!.hour.toString().padLeft(2, '0')}:${event.timeRangeEnd!.minute.toString().padLeft(2, '0')}";
                      }
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(event.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(event.rangeStart != null && event.rangeEnd != null
                                ? normalizeDate(_selectedDay!) == normalizeDate(event.rangeStart!)
                                  ? "$timeRangeStartTxt finisce il ${event.rangeEnd!.day}/${event.rangeEnd!.month}"
                                  : normalizeDate(_selectedDay!) == normalizeDate(event.rangeEnd!)
                                    ? timeRangeEndTxt
                                    : ""
                                : timeRangeStartTxt + timeRangeEndTxt, 
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(event.description ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Rimuovi evento',
                            onPressed: () {
                              setState(() {
                                final ev = events[normalizeDate(_selectedDay!)]![index];
                                events[normalizeDate(_selectedDay!)]!.removeAt(index);
                                
                                if (events[normalizeDate(_selectedDay!)]!.isEmpty) {
                                  events.remove(normalizeDate(_selectedDay!));
                                }
                                if (ev.rangeStart != null && ev.rangeEnd != null) {

                                  if (events[normalizeDate(ev.rangeStart!)] != null) {
                                    events[normalizeDate(ev.rangeStart!)]!.remove(ev);
                                    if (events[normalizeDate(ev.rangeStart!)]!.isEmpty) {
                                      events.remove(normalizeDate(ev.rangeStart!));
                                    }
                                  }
                                  if (events[normalizeDate(ev.rangeEnd!)] != null) {
                                    events[normalizeDate(ev.rangeEnd!)]!.remove(ev);
                                    if (events[normalizeDate(ev.rangeEnd!)]!.isEmpty) {
                                      events.remove(normalizeDate(ev.rangeEnd!));
                                    }
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Nessun evento per questo giorno.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, 
            MaterialPageRoute<Void>(
              builder: (context) => AddEvent(
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                pickedDate: _selectedDay,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        ),
    );
  }
}
