
class DateTimeUtils {
  /// Parses a date string, assuming UTC if no timezone is provided,
  /// and returns a [DateTime] converted to the local timezone.
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    String normalized = dateStr;
    // If no timezone indicator is present, assume UTC by appending 'Z'
    // This handles cases where Supabase/DB might return raw timestamps without offset
    if (!dateStr.contains('Z') && !dateStr.contains('+') && !dateStr.contains(RegExp(r'-\d\d:'))) {
      normalized = '${dateStr}Z';
    }

    try {
      return DateTime.parse(normalized).toLocal();
    } catch (e) {
      // Fallback or rethrow depending on needs. For now, try raw parse
      try {
        return DateTime.parse(dateStr).toLocal();
      } catch (_) {
        return null;
      }
    }
  }

  /// Returns a 'time ago' string (e.g., "5 mins ago", "just now").
  /// Ensures comparison is done safely in local time.
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now(); // Local
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final difference = now.difference(localDateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  /// Returns current time in UTC formatted as ISO8601 string.
  /// Use this when sending timestamps to the server.
  static String nowUtcIso() {
    return DateTime.now().toUtc().toIso8601String();
  }
}
