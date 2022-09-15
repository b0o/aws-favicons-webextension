import globals from "globals"
import prettier from "eslint-config-prettier"

export default [
  "eslint:recommended",
  prettier,
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "module",
    },
    rules: {
      "prefer-const": "error",
      "no-var": "error",
    },
  },
  {
    files: ["src/*.js"],
    languageOptions: {
      globals: {
        ...globals.es2021,
        ...globals.browser,
        ...globals.webextensions,
      },
    },
  },
  {
    files: ["scripts/*.js"],
    languageOptions: {
      globals: {
        ...globals.es2021,
        ...globals.builtin,
        ...globals.nodeBuiltin,
      },
    },
  },
]
