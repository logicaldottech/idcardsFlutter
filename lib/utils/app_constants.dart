import 'package:flutter/material.dart';

import '../data/data_sources/local/preference_utils.dart';

class AppConstants {
  static String authToken = "Bearer";
  static String schoolId = "schoolId";
  static String userId = "userId";
  static String employeeDetailsId = "employeeDetailsId";
  static String employeeName = "employeeName";
  static String employeeDesignation = "employeeDesignation";
  static String employeePhoto = "employeePhoto";
  static String employeeId = "employeeId";
  static String employeeOfficeId = "employeeOfficeId";
  static String dateOfJoining = "dateOfJoining";
  static String photo = "photo";
  static late String selectedMonth;
  static int id = 114;
  bool isInitialLoad = true;
}

Future<String?> _getEmployeeDesignation() async {
  // Simulate a network call or database fetch with a delay
  await Future.delayed(Duration(seconds: 0));
  return PreferencesUtil.getString(AppConstants
      .employeeDesignation); // Replace this with actual data fetching logic
}

Widget buildEmployeeDesignationText() {
  return Container(
    height: 50,
    width: 150,
    child: FutureBuilder<String?>(
      future: _getEmployeeDesignation(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red));
        } else if (snapshot.hasData) {
          return Text(
            snapshot.data ?? 'No name found',
            // Display the fetched name or a default message
            style: TextStyle(color: Colors.black, fontSize: 14),
          );
        } else {
          return Text('No data found', style: TextStyle(color: Colors.grey));
        }
      },
    ),
  );
}

Widget buildEmployeeOfficeText() {
  return FutureBuilder<String?>(
    future: _getEmployeeofficeid(),
    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}',
            style: TextStyle(color: Colors.red));
      } else if (snapshot.hasData) {
        return Text(
          snapshot.data ?? 'No name found',
          // Display the fetched name or a default message
          style: TextStyle(color: Colors.black, fontSize: 16),
        );
      } else {
        return Text('No data found', style: TextStyle(color: Colors.grey));
      }
    },
  );
}

Future<String?> _getEmployeeofficeid() async {
  // Simulate a network call or database fetch with a delay
  await Future.delayed(Duration(seconds: 0));
  return PreferencesUtil.getString(AppConstants
      .employeeOfficeId); // Replace this with actual data fetching logic
}

Future<String?> _getEmployeeName() async {
  // Simulate a network call or database fetch with a delay
  await Future.delayed(Duration(seconds: 0));
  return PreferencesUtil.getString(AppConstants
      .employeeName); // Replace this with actual data fetching logic
}

Widget buildEmployeeNameText() {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Container(
      width: 120,
      child: FutureBuilder<String?>(
        future: _getEmployeeName(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red));
          } else if (snapshot.hasData) {
            return Text(
              snapshot.data ?? 'No name found',
              // Display the fetched name or a default message
              style: TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 2,
              softWrap: true,
            );
          } else {
            return Text('No data found', style: TextStyle(color: Colors.grey));
          }
        },
      ),
    ),
  );
}
