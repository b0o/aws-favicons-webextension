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
]
