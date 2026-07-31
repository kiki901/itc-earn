import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class AppHelpers {
  static String _getLocaleCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return '${locale.languageCode}_${locale.countryCode ?? ''}'.trimRight();
  }

  static String formatNumber(BuildContext context, int number) {
    return NumberFormat('#,##0', _getLocaleCode(context)).format(number);
  }

  static String formatCurrency(double amount, String currency) {
    return NumberFormat.currency(symbol: currency).format(amount);
  }

  static String formatDate(BuildContext context, DateTime date) {
    return DateFormat('yyyy-MM-dd', _getLocaleCode(context)).format(date);
  }

  static String formatTime(BuildContext context, DateTime date) {
    return DateFormat('HH:mm', _getLocaleCode(context)).format(date);
  }

  static String formatDateTime(BuildContext context, DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm', _getLocaleCode(context)).format(date);
  }

  static String timeAgo(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final loc = AppLocalizations.of(context);

    if (difference.inDays > 365) {
      return loc.timeAgoYears(difference.inDays ~/ 365);
    } else if (difference.inDays > 30) {
      return loc.timeAgoMonths(difference.inDays ~/ 30);
    } else if (difference.inDays > 0) {
      return loc.timeAgoDays(difference.inDays);
    } else if (difference.inHours > 0) {
      return loc.timeAgoHours(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return loc.timeAgoMinutes(difference.inMinutes);
    } else {
      return loc.timeAgoNow;
    }
  }

  static String timeUntilNextCollection(BuildContext context, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final loc = AppLocalizations.of(context);

    if (hours > 0) {
      return loc.timeUntilHoursMinutes(hours, minutes);
    }
    return loc.timeUntilMinutesOnly(minutes);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) async {
    final loc = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText ?? loc.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> launchExternalUrl(String url) async {
    // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
