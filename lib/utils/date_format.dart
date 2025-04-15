class IndianDateFormat {
  static String getFormattedDate(String dateFormat) {
    if (dateFormat.isEmpty) {
      return "";
    }
    try {
      DateTime date = DateTime.parse(dateFormat);
      String indianFormattedDate = formatDate(date);
      return indianFormattedDate;
    } catch (e) {
      print("Error parsing date: $e");
      return ""; // Return empty string or handle error accordingly
    }
  }

  static String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day-$month-$year';
  }

  static String getBackendFormattedDate(String dateFormat) {
    if (dateFormat.isEmpty) {
      return "";
    }
    try {
      DateTime date = DateTime.parse(dateFormat);
      String indianFormattedDate = backEndFormatDate(date);
      return indianFormattedDate;
    } catch (e) {
      print("Error parsing date: $e");
      return ""; // Return empty string or handle error accordingly
    }
  }

  static String backEndFormatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$year-$month-$day';
  }
}
