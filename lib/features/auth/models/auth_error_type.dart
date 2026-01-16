enum AuthErrorType {
  invalidCredentials,    // Wrong email/password
  networkError,          // No internet or connection issues
  serverError,           // 500 errors, backend issues
  rateLimited,           // Too many attempts
  emailExists,           // Signup with existing email
  weakPassword,          // Password doesn't meet requirements
  sessionExpired,        // Token expired
  firebaseInit,          // Firebase initialization failed (Supabase in this case)
  profileCreation,       // Profile creation failed
  unknown,               // Unexpected errors
}
