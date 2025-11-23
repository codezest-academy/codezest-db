import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';

export default [
  {
    files: ['**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module',
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      // TypeScript specific
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],

      // Naming conventions enforcement
      '@typescript-eslint/naming-convention': [
        'error',
        // Classes, Enums, TypeAliases, Interfaces use PascalCase
        {
          selector: ['class', 'enum', 'typeAlias', 'interface'],
          format: ['PascalCase'],
        },
        // Variables and functions use camelCase
        {
          selector: ['variable', 'function'],
          format: ['camelCase'],
          leadingUnderscore: 'allow',
        },
        // Constants use SCREAMING_SNAKE_CASE or camelCase
        {
          selector: 'variable',
          modifiers: ['const'],
          format: ['camelCase', 'UPPER_CASE'],
        },
        // Enum members use PascalCase
        {
          selector: 'enumMember',
          format: ['PascalCase'],
        },
      ],

      // General best practices
      'no-console': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
  {
    ignores: [
      'dist/**',
      'node_modules/**',
      '*.config.js',
      '*.config.ts',
      '**/*.test.ts',
      '**/*.spec.ts',
    ],
  },
];
