# dart_cva

**Class Variance Authority (CVA) for Dart** - 🎨 A utility for managing component variants through classes.

## Description

`dart_cva` is a Dart port of the popular CVA (Class Variance Authority) library, originally created by Joe Bell. It provides a type-safe and flexible way to manage component variants through classes, making it particularly useful for styling systems and component libraries. If you're using `jaspr` together with `jaspr_tailwind` for building and styling reactive UIs, `dart_cva` integrates seamlessly! 🚀

## Features

- ✅ Type-safe variant management
- 🔗 Compound variants support
- ⚙️ Default variants configuration
- ➕ Additional class merging
- 🔄 Comprehensive variant combination generation
- 📦 Zero dependencies
- 🌐 Framework agnostic, ideal for `jaspr` and `jaspr_tailwind`

## Installation

To use this package, add `dart_cva` as a dependency in your `pubspec.yaml` file: 📜

```yaml
dependencies:
  dart_cva: ^1.0.0
```

<br>

## Usage

### Basic Example

```dart
import 'package:dart_cva/dart_cva.dart';

final buttonCva = cva(
  base: ['button', 'font-semibold'], // Base classes applied to all variants
  variants: {
    'type': {
      'primary': 'bg-blue-500 text-white hover:bg-blue-600',
      'secondary': 'bg-gray-200 text-gray-900 hover:bg-gray-300',
      'danger': 'bg-red-500 text-white hover:bg-red-600',
    },
    'size': {
      'sm': 'text-sm px-2 py-1',
      'md': 'text-base px-3 py-2',
      'lg': 'text-lg px-4 py-2',
    },
  },
  defaultVariants: {
    'type': 'primary',
    'size': 'md',
  },
);

void main() {
  print(buttonCva()); // Using defaults: 'button font-semibold bg-blue-500 text-white hover:bg-blue-600 text-base px-3 py-2'
  print(buttonCva({'type': 'secondary', 'size': 'lg'})); // Custom variants: 'button font-semibold bg-gray-200 text-gray-900 hover:bg-gray-300 text-lg px-4 py-2'
}
```

### Compound Variants

Compound variants allow you to apply additional classes when multiple conditions are met:

```dart
final buttonCva = cva(
  base: ['button'],
  variants: {
    'type': {
      'primary': 'bg-blue-500',
      'secondary': 'bg-gray-200',
    },
    'size': {
      'sm': 'text-sm',
      'lg': 'text-lg',
    },
  },
  compoundVariants: [
    {
      'type': 'primary',
      'size': 'lg',
      'class': 'uppercase tracking-wider',
    },
  ],
);

// The uppercase and tracking-wider classes will only be applied
// when type is 'primary' AND size is 'lg'
print(
  buttonCva({
    'type': 'primary',
    'size': 'lg',
  }),
);
```

### Variant Combinations

The `getAllVariantCombinations()` method is a powerful utility that generates all possible combinations of your variants. This is particularly useful for:

- Testing all possible variant states
- Generating documentation
- Creating component showcases
- Visual regression testing

```dart
// Define button styles using cva
final buttonStyles = cva(
  base: ['button'], // Base class applied to all variants
  variants: {
    'type': {
      'primary': 'bg-blue-500', // Primary type style
      'secondary': 'bg-gray-200', // Secondary type style
    },
    'size': {
      'sm': 'text-sm', // Small size style
      'lg': 'text-lg', // Large size style
    },
  },
);

void main() {
  // Get all possible combinations of variants
  final combinations = buttonStyles.getAllVariantCombinations();

  // Print the generated combinations
  print(combinations);

  // Iterate over each combination to render all variants
  for (final combo in combinations) {
    print('Variant: $combo'); // Print the current variant combination
    print('Classes: ${buttonStyles(combo)}'); // Print the classes for the current combination
  }
}
```

### Additional Classes

You can add extra classes using the special 'class' key:

```dart
print(
  buttonCva({
    'type': 'primary',
    'class': 'custom-class another-class',
  }),
);
```

## Framework Integration

### Jaspr

```dart
import 'package:jaspr/jaspr.dart';
import 'package:dart_cva/dart_cva.dart';

// Enum for button types with associated classes
// Enums provide a bit more type-safety by restricting the values to predefined options
enum CvaButtonType {
  primary('bg-emerald-600 text-white hover:bg-emerald-700'),
  secondary('bg-gray-200 text-gray-900 hover:bg-gray-300'),
  danger('bg-red-600 text-white hover:bg-red-700'),
  plain('bg-transparent text-white hover:bg-white hover:text-gray-900');

  final String classes;
  const CvaButtonType(this.classes);
}

// Enum for button sizes with associated classes
// Enums ensure that only valid sizes are used, enhancing type-safety
enum ButtonSize {
  sm('h-8 px-3 text-sm'),
  md('h-10 px-4 text-base'),
  lg('h-12 px-6 text-lg');

  final String classes;
  const ButtonSize(this.classes);
}

// Define button styles using cva
final buttonStyles = cva(
  base: [
    'inline-flex',
    'items-center',
    'justify-center',
    'rounded-full',
    'font-medium',
    'transition-colors'
  ],
  variants: {
    'type': {
      for (final type in CvaButtonType.values) type.name: type.classes,
    },
    'size': {
      for (final size in ButtonSize.values) size.name: size.classes,
    },
    'fullWidth': {
      'true': 'w-full',
      'false': '',
    },
  },
  defaultVariants: {
    'type': CvaButtonType.primary.name,
    'size': ButtonSize.lg.name,
    'fullWidth': 'false',
  },
  compoundVariants: [
    {
      'type': 'primary',
      'size': 'lg',
      'class': 'font-bold',
    },
    {
      'disabled': 'true',
      'class': 'opacity-50 cursor-not-allowed',
    },
  ],
);

// Button component class
class Button extends StatelessComponent {
  final CvaButtonType? type; // Button type
  final ButtonSize? size; // Button size
  final bool? fullWidth; // Full width flag
  final String? classes; // Additional classes
  final List<Component> children; // Child components
  final void Function()? onClick; // Click event handler
  final bool disabled; // Disabled state

  Button(
    this.children, {
    super.key,
    this.type,
    this.size,
    this.fullWidth,
    this.classes,
    this.onClick,
    this.disabled = false,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
      events: events(
        onClick: (onClick != null && !disabled) ? onClick : null,
      ),
      classes: buttonStyles({
        'type': type?.name,
        'size': size?.name,
        'fullWidth': fullWidth?.toString(),
        'class': classes,
      }),
      disabled: disabled,
      children,
    );
  }
}

// Usage

// Example usage of the Button component inside a ShowCase stateless component

class ShowCase extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      [
        Text('Click Me'),
      ],
      type: CvaButtonType.primary,
      size: ButtonSize.medium,
      fullWidth: true,
      classes: 'custom-class',
      onClick: () {
        print('Button clicked!');
      },
      disabled: false,
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments

- Original [CVA](https://github.com/joe-bell/cva) by Joe Bell
- Inspired by [clsx](https://github.com/lukeed/clsx) and [classnames](https://github.com/JedWatson/classnames)
