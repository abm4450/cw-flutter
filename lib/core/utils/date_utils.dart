import 'package:intl/intl.dart';

String formatShortDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('yyyy/MM/dd').format(date);
}

String formatTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('hh:mm a').format(date);
}

String formatRelativeDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) {
    return formatTime(timestamp);
  } else if (diff.inDays == 1) {
    return 'أمس';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} أيام';
  } else {
    return formatShortDate(timestamp);
  }
}
