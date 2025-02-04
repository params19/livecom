String formatDate(DateTime date) {
  String formatTime(int hour, int minute) {
    String period = hour >= 12 ? 'PM' : 'AM';
    int formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String formattedMinute = minute < 10 ? '0$minute' : '$minute';
    return '$formattedHour:$formattedMinute $period';
  }

  DateTime now = DateTime.now();

  if (date.year == now.year && date.month == now.month) {
    if (date.day == now.day) {
      return 'Today ${formatTime(date.hour, date.minute)}';
    } else if (date.day == now.day - 1) {
      return 'Yesterday ${formatTime(date.hour, date.minute)}';
    }
  }

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${formatTime(date.hour, date.minute)}';
}
