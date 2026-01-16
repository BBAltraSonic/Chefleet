import '../models/auth_error_type.dart';
import '../models/error_message.dart';

// User-friendly error messages with recovery actions
final Map<AuthErrorType, ErrorMessage> authErrorMessages = {
  AuthErrorType.invalidCredentials: const ErrorMessage(
    title: "Incorrect email or password",
    message: "Please check your credentials and try again.",
    actions: [
      ErrorAction(
        label: "Try Again",
        type: ErrorActionType.retry,
      ),
      ErrorAction(
        label: "Forgot Password?",
        type: ErrorActionType.forgotPassword,
      ),
    ],
  ),
  AuthErrorType.networkError: const ErrorMessage(
    title: "Connection issue",
    message: "Check your internet connection and try again.",
    actions: [
      ErrorAction(
        label: "Try Again",
        type: ErrorActionType.retry,
      ),
    ],
  ),
  AuthErrorType.serverError: const ErrorMessage(
    title: "Server error",
    message: "Something went wrong on our end. Please try again later.",
    actions: [
      ErrorAction(
        label: "Try Again",
        type: ErrorActionType.retry,
      ),
    ],
  ),
  AuthErrorType.rateLimited: const ErrorMessage(
    title: "Too many attempts",
    message: "Please wait a moment before trying again.",
    actions: [
      ErrorAction(
        label: "Contact Support",
        type: ErrorActionType.contactSupport,
      ),
    ],
  ),
  AuthErrorType.emailExists: const ErrorMessage(
    title: "Email already registered",
    message: "This email is already associated with an account.",
    actions: [
      ErrorAction(
        label: "Sign In",
        type: ErrorActionType.signIn,
      ),
      ErrorAction(
        label: "Forgot Password?",
        type: ErrorActionType.forgotPassword,
      ),
    ],
  ),
  AuthErrorType.weakPassword: const ErrorMessage(
    title: "Password too weak",
    message: "Password must be at least 6 characters.",
    actions: [
      ErrorAction(
        label: "Try Again",
        type: ErrorActionType.retry,
      ),
    ],
  ),
  AuthErrorType.sessionExpired: const ErrorMessage(
    title: "Session expired",
    message: "Please sign in again to continue.",
    actions: [
      ErrorAction(
        label: "Sign In",
        type: ErrorActionType.signIn,
      ),
    ],
  ),
  AuthErrorType.firebaseInit: const ErrorMessage(
    title: "Initialization failed",
    message: "We couldn't initialize the app services. Please restart the app.",
    actions: [
      ErrorAction(
        label: "Retry",
        type: ErrorActionType.retry,
      ),
    ],
  ),
  AuthErrorType.profileCreation: const ErrorMessage(
    title: "Profile setup failed",
    message: "Your account was created but we couldn't set up your profile.",
    actions: [
      ErrorAction(
        label: "Retry",
        type: ErrorActionType.retry,
      ),
    ],
  ),
  AuthErrorType.unknown: const ErrorMessage(
    title: "Something went wrong",
    message: "An unexpected error occurred. Please try again.",
    actions: [
      ErrorAction(
        label: "Try Again",
        type: ErrorActionType.retry,
      ),
    ],
  ),
};
