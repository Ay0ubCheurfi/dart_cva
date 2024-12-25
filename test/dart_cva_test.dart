import 'package:dart_cva/dart_cva.dart';
import 'package:test/test.dart';

void main() {
  group('CVA Tests', () {
    test('basic cva creation and usage', () {
      final buttonCva = cva(
        base: ['button', 'font-semibold'],
        variants: {
          'size': {
            'sm': 'text-sm px-2 py-1',
            'lg': 'text-lg px-4 py-2',
          },
          'type': {
            'primary': 'bg-blue-500 text-white',
            'secondary': 'bg-gray-200 text-gray-900',
          },
        },
      );

      expect(buttonCva({}), contains('button'));
      expect(buttonCva({}), contains('font-semibold'));
      expect(buttonCva({'size': 'sm'}), contains('text-sm'));
      expect(buttonCva({'size': 'lg'}), contains('text-lg'));
      expect(buttonCva({'type': 'primary'}), contains('bg-blue-500'));
      expect(buttonCva({'type': 'secondary'}), contains('bg-gray-200'));
    });

    test('handles default variants', () {
      final buttonCva = cva(
        base: ['button'],
        variants: {
          'size': {
            'sm': 'text-sm',
            'lg': 'text-lg',
          },
        },
        defaultVariants: {
          'size': 'sm',
        },
      );

      print(buttonCva({}));

      expect(buttonCva({}), contains('text-sm'));
      expect(buttonCva({'size': 'lg'}), contains('text-lg'));
      expect(buttonCva({'size': null}), contains('text-sm'));
    });

    test('handles compound variants', () {
      final buttonCva = cva(
        base: ['button'],
        variants: {
          'size': {
            'sm': 'text-sm',
            'lg': 'text-lg',
          },
          'type': {
            'primary': 'bg-blue-500',
            'secondary': 'bg-gray-200',
          },
        },
        compoundVariants: [
          {
            'size': 'sm',
            'type': 'primary',
            'class': 'uppercase font-bold',
          },
        ],
      );

      expect(
        buttonCva({'size': 'sm', 'type': 'primary'}),
        allOf([contains('uppercase'), contains('font-bold')]),
      );
      expect(
        buttonCva({'size': 'lg', 'type': 'primary'}),
        isNot(contains('uppercase')),
      );
    });

    test('getAllVariantCombinations generates all possibilities', () {
      final buttonCva = cva(
        variants: {
          'size': {
            'sm': 'text-sm',
            'lg': 'text-lg',
          },
          'type': {
            'primary': 'bg-blue-500',
            'secondary': 'bg-gray-200',
          },
        },
      );

      final combinations = buttonCva.getAllVariantCombinations();
      expect(combinations.length, equals(4)); // 2 sizes * 2 types
      expect(
        combinations,
        containsAll([
          {'size': 'sm', 'type': 'primary'},
          {'size': 'sm', 'type': 'secondary'},
          {'size': 'lg', 'type': 'primary'},
          {'size': 'lg', 'type': 'secondary'},
        ]),
      );
    });
  });
}
