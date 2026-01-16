import 'package:flutter/material.dart';

enum ErrorActionType {
  retry,
  forgotPassword,
  switchToOfflineMode,
  contactSupport,
  signIn,
  none,
}

class ErrorAction {
  final String label;
  final ErrorActionType type;
  final VoidCallback? onTap;

  const ErrorAction({
    required this.label,
    required this.type,
    this.onTap,
  });
}

class ErrorMessage {
  final String title;
  final String message;
  final List<ErrorAction> actions;

  const ErrorMessage({
    required this.title,
    required this.message,
    this.actions = const [],
  });
}
