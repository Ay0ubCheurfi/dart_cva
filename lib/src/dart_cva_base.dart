// Copyright 2024. Port of Class Variance Authority to Dart.
// Original Class Variance Authority by Joe Bell licensed under Apache License, Version 2.0

/// Class Variance Authority (CVA) for Dart
///
/// A utility for managing component variants through class names. This is a Dart port
/// of the original JavaScript Class Variance Authority library by Joe Bell.
///
/// Example usage:
/// ```dart
/// final buttonCva = cva(
///   base: ['button', 'font-semibold'],
///   variants: {
///     'type': {
///       'primary': 'bg-blue-500 text-white',
///       'secondary': 'bg-gray-200 text-gray-900',
///     },
///     'size': {
///       'sm': 'text-sm px-2 py-1',
///       'lg': 'text-lg px-4 py-2',
///     },
///   },
///   defaultVariants: {
///     'type': 'primary',
///     'size': 'sm',
///   },
/// );
///
/// // Usage:
/// buttonCva({'type': 'secondary', 'size': 'lg'});
/// ```
library;

/// Represents a single CSS class name or multiple space-separated class names
typedef ClassValue = String;

/// Defines a mapping of variant values to their corresponding class names
///
/// For example: `{'sm': 'text-sm', 'lg': 'text-lg'}`
typedef VariantConfig = Map<String, ClassValue>;

/// Defines the complete schema of all variants and their possible values
///
/// For example:
/// ```dart
/// {
///   'size': {'sm': 'text-sm', 'lg': 'text-lg'},
///   'color': {'primary': 'text-blue-500', 'secondary': 'text-gray-500'},
/// }
/// ```
typedef ConfigSchema = Map<String, VariantConfig>;

/// Represents the variant properties that must match keys from the schema
///
/// Used when calling the CVA instance with specific variant values
typedef ConfigVariants<T extends ConfigSchema> = Map<String, Object?>;

/// Defines a compound variant configuration that combines multiple variant conditions
///
/// Must include a 'class' key with the classes to apply when all conditions match
typedef CompoundVariant<T extends ConfigSchema> = Map<String, Object?>;

/// Main CVA class to handle variant generation for components
class CVA<T extends ConfigSchema> {
  /// Base classes that are always applied
  final List<String> baseClasses;

  /// Configuration of all possible variants and their class names
  final T? variants;

  /// Default variant values to use when none are specified
  final ConfigVariants<T>? defaultVariants;

  /// List of compound variants that apply additional classes when multiple conditions match
  final List<CompoundVariant<T>>? compoundVariants;

  /// Creates a new CVA instance
  ///
  /// - [base]: List of class names that are always applied
  /// - [variants]: Configuration of all possible variants
  /// - [defaultVariants]: Default values for variants when none specified
  /// - [compoundVariants]: Additional classes applied when multiple conditions match
  CVA({
    List<String>? base,
    this.variants,
    this.defaultVariants,
    this.compoundVariants,
  }) : baseClasses = base ?? [];

  /// Converts values to strings consistently
  String _valueToString(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value.toString();
    if (value == 0) return '0';
    return value.toString();
  }

  /// Combines class names and returns a String for Jaspr
  String _combineClasses(List<dynamic> classes) {
    return classes
        .where((cls) => cls != null && cls.toString().isNotEmpty)
        .map((cls) => cls.toString().trim())
        .join(' ')
        .trim();
  }

  /// Generates the final class string based on the provided parameters
  ///
  /// [parameters] is a map of variant names to their values. Also accepts a special
  /// 'class' key for additional classes that should be appended to the result.
  ///
  /// Returns a space-separated string of class names.
  String call([Map<String, dynamic>? parameters]) {
    if (variants == null) {
      return _combineClasses([
        ...baseClasses,
        parameters?['class'],
      ]);
    }

    // Handle variant class names
    final variantClassNames = variants!.keys.map((variant) {
      final variantParameter = parameters?[variant];
      final defaultVariantParameter = defaultVariants?[variant];

      // Use default variant if no parameter is provided or parameter is empty string
      final variantKey =
          (variantParameter == null || _valueToString(variantParameter).isEmpty)
              ? defaultVariantParameter
              : variantParameter;

      return variants![variant]?[variantKey];
    }).toList();

    // Remove undefined values from parameters and apply defaults
    final parametersWithDefaults = Map<String, dynamic>.from(parameters ?? {});
    defaultVariants?.forEach((key, defaultValue) {
      if (!parametersWithDefaults.containsKey(key) ||
          parametersWithDefaults[key] == null ||
          _valueToString(parametersWithDefaults[key]).isEmpty) {
        parametersWithDefaults[key] = defaultValue;
      }
    });

    // Handle compound variants
    final compoundVariantClassNames = compoundVariants?.fold<List<String>>(
      [],
      (acc, compound) {
        final compoundClass = compound['class'];
        final options = Map<String, dynamic>.from(compound)..remove('class');

        final matches = options.entries.every((entry) {
          final key = entry.key;
          final value = entry.value;
          final parameterValue = parametersWithDefaults[key];

          if (value is List) {
            return value.contains(parameterValue);
          }
          return parameterValue == value;
        });
        if (matches && compoundClass != null) {
          acc.add(compoundClass.toString());
        }

        return acc;
      },
    );

    return _combineClasses([
      ...baseClasses,
      ...variantClassNames,
      ...?compoundVariantClassNames,
      parameters?['class'],
    ]);
  }

  /// Generates all possible combinations of the configured variants
  ///
  /// This is useful for testing or generating documentation of all possible states.
  ///
  /// Returns a list of maps, where each map represents one possible combination
  /// of variant values.
  List<Map<String, dynamic>> getAllVariantCombinations() {
    if (variants == null || variants!.isEmpty) {
      return [{}];
    }

    // Get all possible values for each variant
    final variantEntries = variants!.entries.map((entry) {
      final variantName = entry.key;
      final variantValues = entry.value.keys.toList();
      return MapEntry(variantName, variantValues);
    }).toList();

    // Start with an empty combination
    List<Map<String, dynamic>> combinations = [{}];

    // Generate all possible combinations
    for (final entry in variantEntries) {
      final variantName = entry.key;
      final variantValues = entry.value;

      final newCombinations = <Map<String, dynamic>>[];

      for (final combo in combinations) {
        for (final value in variantValues) {
          newCombinations.add({
            ...combo,
            variantName: value,
          });
        }
      }

      combinations = newCombinations;
    }

    return combinations;
  }

  @override
  String toString() {
    return 'CVA(base: $baseClasses, variants: $variants, defaultVariants: $defaultVariants, compoundVariants: $compoundVariants)';
  }
}

/// Creates a new CVA instance with type safety
///
/// This is the recommended way to create a new CVA instance as it provides
/// better type inference than using the constructor directly.
///
/// Example:
/// ```dart
/// final button = cva(
///   base: ['button'],
///   variants: {
///     'size': {'small': 'text-sm', 'large': 'text-lg'},
///   },
/// );
/// ```
CVA<T> cva<T extends ConfigSchema>({
  List<String>? base,
  T? variants,
  ConfigVariants<T>? defaultVariants,
  List<CompoundVariant<T>>? compoundVariants,
}) {
  return CVA<T>(
    base: base,
    variants: variants,
    defaultVariants: defaultVariants,
    compoundVariants: compoundVariants,
  );
}
