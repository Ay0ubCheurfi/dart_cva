import 'package:dart_cva/dart_cva.dart';

void main() {
  final buttonCva = cva(
    base: ['button', 'font-semibold'],
    variants: {
      'type': {
        'primary': 'bg-blue-500 text-white',
        'secondary': 'bg-gray-200 text-gray-900',
      },
      'size': {
        'sm': 'text-sm px-2 py-1',
        'lg': 'text-lg px-4 py-2',
      },
    },
    defaultVariants: {
      'type': 'primary',
      'size': 'sm',
    },
  );

  print(buttonCva()); // Default variants
  print(buttonCva({'type': 'secondary', 'size': 'lg'})); // Custom variants
}
