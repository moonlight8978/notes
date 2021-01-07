#### Install

```bash
yarn add --dev babel-plugin-module-resolver
```

Update `babel.config.js`

```js
module.exports = {
  // ....
  plugins: [
    [
      "module-resolver",
      {
        root: ["."],
        extensions: [".ts", ".tsx", ".js", ".jsx", "json"],
        alias: {
          "@src": "./src",
        },
      },
    ],
  ],
};
```

#### VSCode

Update `tsconfig.json`

```json
{
  "compilerOptions": {
    // ...
    "baseUrl": "./",
    "paths": {
      "@src/*": ["./src/*"]
    }
  }
}
```

#### ESLint

```bash
yarn add -D eslint-import-resolver-typescript eslint-plugin-import
```

```yml
settings:
  import/resolver:
    typescript: {}
rules:
  import/order:
    - error
    - pathGroups:
        - pattern: "@src/**"
          group: parent
      groups:
        - builtin
        - external
        - parent
        - sibling
        - index
      newlines-between: always
```
