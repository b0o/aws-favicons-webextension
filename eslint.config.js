import globals from "globals"
import prettier from "eslint-config-prettier"

export default [
  "eslint:recommended",
  prettier,
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.webextensions,
      },
    },
    rules: {},
  },
  // {
  //   languageOptions: {},
  //   env: {
  //     browser: true,
  //     webextensions: true,
  //     es2022: true,
  //   },
  //   extends: ["eslint:recommended", "prettier"],
  //   overrides: [],
  //   parserOptions: {
  //     ecmaVersion: "latest",
  //     sourceType: "module",
  //   },
  //   globals: {
  //     app: true,
  //     request: true,
  //     moment: true,
  //   },
  //   rules: {},
  // },
]
