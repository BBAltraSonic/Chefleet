import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../router/app_router.dart';

class DeepLinkService {
  static const String _baseUrl = 'https://chefleet.app';

  /// Generate a shareable deep link for a dish
  static String generateDishDeepLink(String dishId) {
    return '$_baseUrl${AppRouter.dishDetailRoute}/$dishId';
  }

  /// Generate a shareable deep link for a vendor
  static String generateVendorDeepLink(String vendorId) {
    return '$_baseUrl${AppRouter.mapRoute}?vendor=$vendorId';
  }

  /// Share a dish link with other apps
  static Future<void> shareDishLink({
    required String dishId,
    required String dishName,
    String? vendorName,
  }) async {
    final deepLink = generateDishDeepLink(dishId);
    final shareText = vendorName != null
        ? 'Check out $dishName from $vendorName on Chefleet!\n$deepLink'
        : 'Check out $dishName on Chefleet!\n$deepLink';

    try {
      await Share.share(
        shareText,
        subject: '$dishName on Chefleet',
      );
    } catch (e) {
      debugPrint('Error sharing dish link: $e');
    }
  }

  /// Open a deep link in the browser
  static Future<bool> openDeepLink(String url) async {
    final uri = Uri.parse(url);

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error opening deep link: $e');
      return false;
    }
  }

  /// Copy deep link to clipboard
  static Future<void> copyDeepLinkToClipboard({
    required String dishId,
    required String dishName,
    BuildContext? context,
  }) async {
    final deepLink = generateDishDeepLink(dishId);

    // This would need a clipboard service - for now just share
    await shareDishLink(
      dishId: dishId,
      dishName: dishName,
    );

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Parse incoming deep link and extract parameters
  static Map<String, String?> parseDeepLink(String url) {
    final uri = Uri.parse(url);

    // Handle dish detail links
    if (uri.path.startsWith(AppRouter.dishDetailRoute)) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length > 1) {
        return {
          'type': 'dish',
          'dishId': pathSegments.last,
        };
      }
    }

    // Handle vendor links
    if (uri.path == AppRouter.mapRoute) {
      return {
        'type': 'vendor',
        'vendorId': uri.queryParameters['vendor'],
      };
    }

    return {'type': 'unknown'};
  }

  /// Validate if a deep link is from Chefleet
  static bool isValidChefleetLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('chefleet.app') ||
             uri.host.contains('localhost') ||
             uri.scheme == 'chefleet';
    } catch (e) {
      return false;
    }
  }
}