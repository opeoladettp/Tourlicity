
/// Comprehensive input validation and sanitization service
class InputValidator {
  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
  
  static final RegExp _alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s\-\.\u0027\u00C0-\u017F]+$');
  
  static final RegExp _sqlInjectionRegex = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)',
    caseSensitive: false,
  );
  
  static final RegExp _xssRegex = RegExp(
    r'(<script|javascript:|on\w+\s*=|<iframe|<object|<embed)',
    caseSensitive: false,
  );

  /// Validates email format
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.invalid('Email is required');
    }
    
    final sanitized = sanitizeInput(email);
    if (!_emailRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }
    
    if (sanitized.length > 254) {
      return ValidationResult.invalid('Email address is too long');
    }
    
    return ValidationResult.valid(sanitized);
  }

  /// Validates phone number format
  static ValidationResult validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }
    
    final sanitized = sanitizePhoneNumber(phone);
    if (!_phoneRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Please enter a valid phone number');
    }
    
    return ValidationResult.valid(sanitized);
  }

  /// Validates name (first name, last name, etc.)
  static ValidationResult validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.isEmpty) {
      return ValidationResult.invalid('$fieldName is required');
    }
    
    final sanitized = sanitizeInput(name);
    if (sanitized.length < 2) {
      return ValidationResult.invalid('$fieldName must be at least 2 characters');
    }
    
    if (sanitized.length > 50) {
      return ValidationResult.invalid('$fieldName must be less than 50 characters');
    }
    
    if (!_nameRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('$fieldName contains invalid characters');
    }
    
    return ValidationResult.valid(sanitized);
  }

  /// Validates password strength
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }
    
    if (password.length < 8) {
      return ValidationResult.invalid('Password must be at least 8 characters');
    }
    
    if (password.length > 128) {
      return ValidationResult.invalid('Password must be less than 128 characters');
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return ValidationResult.invalid('Password must contain at least one uppercase letter');
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return ValidationResult.invalid('Password must contain at least one lowercase letter');
    }
    
    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(password)) {
      return ValidationResult.invalid('Password must contain at least one number');
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return ValidationResult.invalid('Password must contain at least one special character');
    }
    
    return ValidationResult.valid(password);
  }

  /// Validates join code format
  static ValidationResult validateJoinCode(String? joinCode) {
    if (joinCode == null || joinCode.isEmpty) {
      return ValidationResult.invalid('Join code is required');
    }
    
    final sanitized = sanitizeInput(joinCode).toUpperCase();
    if (sanitized.length != 8) {
      return ValidationResult.invalid('Join code must be 8 characters');
    }
    
    if (!_alphanumericRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Join code must contain only letters and numbers');
    }
    
    return ValidationResult.valid(sanitized);
  }

  /// Validates text input with length constraints
  static ValidationResult validateText(
    String? text, {
    required String fieldName,
    int minLength = 1,
    int maxLength = 1000,
    bool allowEmpty = false,
  }) {
    if (text == null || text.isEmpty) {
      if (allowEmpty) {
        return ValidationResult.valid('');
      }
      return ValidationResult.invalid('$fieldName is required');
    }
    
    final sanitized = sanitizeInput(text);
    
    if (sanitized.length < minLength) {
      return ValidationResult.invalid('$fieldName must be at least $minLength characters');
    }
    
    if (sanitized.length > maxLength) {
      return ValidationResult.invalid('$fieldName must be less than $maxLength characters');
    }
    
    return ValidationResult.valid(sanitized);
  }

  /// Validates URL format
  static ValidationResult validateUrl(String? url, {bool allowEmpty = true}) {
    if (url == null || url.isEmpty) {
      if (allowEmpty) {
        return ValidationResult.valid('');
      }
      return ValidationResult.invalid('URL is required');
    }
    
    final sanitized = sanitizeInput(url);
    
    try {
      final uri = Uri.parse(sanitized);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return ValidationResult.invalid('Please enter a valid URL');
      }
      return ValidationResult.valid(sanitized);
    } catch (e) {
      return ValidationResult.invalid('Please enter a valid URL');
    }
  }

  /// Sanitizes general text input
  static String sanitizeInput(String input) {
    // Remove null bytes and control characters
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    
    // Remove zero-width and invisible characters
    sanitized = sanitized.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
    
    // Remove command injection characters
    sanitized = sanitized.replaceAll(RegExp(r'[;&|`$(){}]'), '');
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    // Remove potential XSS patterns
    sanitized = sanitized.replaceAll(_xssRegex, '');
    
    // Remove potential SQL injection patterns
    sanitized = sanitized.replaceAll(_sqlInjectionRegex, '');
    
    // Normalize unicode characters
    sanitized = _normalizeUnicode(sanitized);
    
    return sanitized;
  }

  /// Sanitizes phone number input
  static String sanitizePhoneNumber(String phone) {
    // Remove all non-digit characters except + at the beginning
    String sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure + is only at the beginning
    if (sanitized.contains('+')) {
      final parts = sanitized.split('+');
      sanitized = '+${parts.where((p) => p.isNotEmpty).join('')}';
    }
    
    return sanitized;
  }

  /// Sanitizes HTML content (removes potentially dangerous tags)
  static String sanitizeHtml(String html) {
    // Remove script tags and their content
    String sanitized = html.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
    
    // Remove dangerous attributes
    sanitized = sanitized.replaceAll(RegExp(r'\son\w+\s*=\s*["\u0027][^"\u0027]*["\u0027]', caseSensitive: false), '');
    
    // Remove javascript: protocols
    sanitized = sanitized.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    
    return sanitized;
  }

  /// Validates file upload security
  static ValidationResult validateFileUpload({
    required String fileName,
    required int fileSize,
    required List<String> allowedExtensions,
    int maxSizeBytes = 10 * 1024 * 1024, // 10MB default
  }) {
    // Sanitize filename
    final sanitizedName = sanitizeFileName(fileName);
    
    // Check file extension
    final extension = sanitizedName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return ValidationResult.invalid('File type not allowed. Allowed types: ${allowedExtensions.join(', ')}');
    }
    
    // Check file size
    if (fileSize > maxSizeBytes) {
      final maxSizeMB = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return ValidationResult.invalid('File size must be less than ${maxSizeMB}MB');
    }
    
    // Check for dangerous filenames
    if (_isDangerousFileName(sanitizedName)) {
      return ValidationResult.invalid('Filename contains potentially dangerous content');
    }
    
    return ValidationResult.valid(sanitizedName);
  }

  /// Sanitizes filename for safe storage
  static String sanitizeFileName(String fileName) {
    // Remove path traversal attempts
    String sanitized = fileName.replaceAll(RegExp(r'[\/\\]'), '');
    
    // Remove dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"|?*\x00-\x1f]'), '');
    
    // Limit length
    if (sanitized.length > 255) {
      final extension = sanitized.split('.').last;
      final nameWithoutExt = sanitized.substring(0, sanitized.length - extension.length - 1);
      sanitized = '${nameWithoutExt.substring(0, 255 - extension.length - 1)}.$extension';
    }
    
    return sanitized;
  }

  /// Checks if filename is potentially dangerous
  static bool _isDangerousFileName(String fileName) {
    final dangerous = [
      'con', 'prn', 'aux', 'nul', 'com1', 'com2', 'com3', 'com4', 'com5',
      'com6', 'com7', 'com8', 'com9', 'lpt1', 'lpt2', 'lpt3', 'lpt4',
      'lpt5', 'lpt6', 'lpt7', 'lpt8', 'lpt9'
    ];
    
    final nameWithoutExt = fileName.split('.').first.toLowerCase();
    return dangerous.contains(nameWithoutExt);
  }

  /// Normalizes unicode characters to prevent bypass attempts
  static String _normalizeUnicode(String input) {
    // Convert to NFC (Canonical Decomposition, followed by Canonical Composition)
    return input.split('').map((char) {
      final codeUnit = char.codeUnitAt(0);
      // Replace common unicode bypass attempts
      if (codeUnit >= 0xFF01 && codeUnit <= 0xFF5E) {
        // Full-width characters to ASCII
        return String.fromCharCode(codeUnit - 0xFEE0);
      }
      return char;
    }).join('');
  }
}

/// Result of input validation
class ValidationResult {
  const ValidationResult._({
    required this.isValid,
    required this.value,
    this.errorMessage,
  });

  final bool isValid;
  final String value;
  final String? errorMessage;

  factory ValidationResult.valid(String value) {
    return ValidationResult._(
      isValid: true,
      value: value,
    );
  }

  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult._(
      isValid: false,
      value: '',
      errorMessage: errorMessage,
    );
  }
}