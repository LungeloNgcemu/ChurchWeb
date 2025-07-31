

import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../componants/global_booking.dart';
import '../providers/url_provider.dart';

class Calender {
  String selectedYear = "";
  String selectedMonth = "";
  String selectedDay = "";
  Map<String, dynamic> myMap = {};

  List<Event> eventList = [];

  void getEvents(BuildContext context) async {
    final events = await supabase.from("Events").select().eq(
        'ChurchName',
        Provider.of<christProvider>(context, listen: false).myMap['Project']
            ?['ChurchName']);

    for (var item in events) {
      Event(
        child: SizedBox(),
        dateTime: CalendarDateTime(
          year: 2024,
          month: 5,
          day: 14,
          calendarType: CalendarType.GREGORIAN,
        ),
      );
    }
  }

  Future<bool?> alertReturn(BuildContext context, String message) {
    return Alert(
      context: context,
      type: AlertType.info,
      title: "ALERT",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Widget calenderReturn(Function(CalendarDateTime) onDateChanged,BuildContext context,Function(void Function() ) setState) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 5),
            ),
          ]),
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: ClipRect(
          child: EventCalendar(
            showEvents: false,
            calendarType: CalendarType.GREGORIAN,
            headerOptions: HeaderOptions(
                weekDayStringType: WeekDayStringTypes.SHORT,
                monthStringType: MonthStringTypes.SHORT),
            calendarOptions: CalendarOptions(
              viewType: ViewType.DAILY,
            ),
            // calendarLanguage: 'en',
            eventOptions: EventOptions(emptyText: ""),
            events: [
              Event(
                child: SizedBox(),
                dateTime: CalendarDateTime(
                  year: 2024,
                  month: 5,
                  day: 14,
                  calendarType: CalendarType.GREGORIAN,
                ),
              ),
            ],
            onChangeDateTime: (CalendarDateTime date) {

              print("Selected date: ${date.year}-${date.month}-${date.day}");

              context.read<SelectedDateProvider>().updatemyMap(year: date.year.toString(), month: date.month.toString(), day: date.day.toString());

            //  alertReturn( context,  "You have selected a day");

              // setState((){});
            },
            dayOptions: DayOptions(selectedBackgroundColor: Colors.red),
          ),
        ),
      ),
    );
  }
}
