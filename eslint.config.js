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
        "error",

        // ──────────────────────────────────────────────────────────────
        // 1. General PascalCase for types, classes, enums, etc.
        // ──────────────────────────────────────────────────────────────
        {
          "selector": [
            "class",
            "interface",
            "typeAlias",
            "enum",
            "typeParameter"
          ],
          "format": ["PascalCase"],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid"
        },

        // ──────────────────────────────────────────────────────────────
        // 2. Block I-prefix and "Interface" suffix on interfaces
        // ──────────────────────────────────────────────────────────────
        {
          "selector": "interface",
          "format": ["PascalCase"],
          "custom": {
            "regex": "^(I[^a-z]|.*Interface$)",
            "match": false
          }
        },

        // ──────────────────────────────────────────────────────────────
        // 3. Specific suffixes we DO want (DTO, Service, Controller, etc.)
        // ──────────────────────────────────────────────────────────────
        {
          "selector": "class",
          "suffix": ["Dto"],
          "format": ["PascalCase"],
          "custom": {
            "regex": "Dto$",
            "match": true
          }
        },
        {
          "selector": "class",
          "suffix": ["Service", "Controller", "Repository", "Mapper", "Guard", "Interceptor", "Filter", "Provider"],
          "format": ["PascalCase"]
        },

        // ──────────────────────────────────────────────────────────────
        // 4. Variables & functions → camelCase (const allowed UPPER too)
        // ──────────────────────────────────────────────────────────────
        {
          "selector": ["variable", "function", "parameter"],
          "format": ["camelCase", "PascalCase"],        // PascalCase allowed for React components, etc.
          "leadingUnderscore": "allow"
        },

        // Allow UPPER_CASE only for const variables (classic constants)
        {
          "selector": "variable",
          "modifiers": ["const"],
          "format": ["camelCase", "UPPER_CASE"],
          "leadingUnderscore": "allow"
        },

        // Exported const variables (config objects, etc.) → usually camelCase
        {
          "selector": "variable",
          "modifiers": ["const", "exported"],
          "format": ["camelCase", "UPPER_CASE"]
        },

        // ──────────────────────────────────────────────────────────────
        // 5. Enum members → PascalCase (UserRole.Admin)
        // ──────────────────────────────────────────────────────────────
        {
          "selector": "enumMember",
          "format": ["PascalCase"]
        },

        // ──────────────────────────────────────────────────────────────
        // 6. Properties & methods → camelCase
        // ──────────────────────────────────────────────────────────────
        {
          "selector": ["objectLiteralProperty", "classProperty", "classMethod", "objectLiteralMethod", "parameterProperty"],
          "format": ["camelCase", "UPPER_CASE"],
          "leadingUnderscore": "allow"
        },

        // ──────────────────────────────────────────────────────────────
        // 7. Optional: Allow _id style private fields (common in Prisma entities)
        // ──────────────────────────────────────────────────────────────
        {
          "selector": "classProperty",
          "modifiers": ["private"],
          "format": ["camelCase"],
          "leadingUnderscore": "require"
        }
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
