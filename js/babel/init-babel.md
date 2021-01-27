#### Init

```bash
yarn add -D @babel/core @babel/preset-env @babel/plugin-transform-runtime
```

```bash
touch babel.config.js
```

```js
# babel.config.js
module.exports = {
  presets: [
    ["@babel/preset-env", { targets: "defaults" }],
  ],
  plugins: ["@babel/plugin-transform-runtime"],
};
```

#### Add typescript

```bash
yarn add -D @babel/preset-typescript typescript
```

```js
# babel.config.js
module.exports = {
  presets: [
    "@babel/preset-typescript",
  ],
};
```

```
yarn tsc --init
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "lib": ["ESNext"],
    "allowJs": true,
  }
}
```



###### Typescript eslint

```yml
# .eslintrc.yml
rules:
  no-use-before-define: 'off'
  '@typescript-eslint/no-use-before-define': error
  no-unused-vars: 'off'
  '@typescript-eslint/no-unused-vars':
    - error
    - args: none
      varsIgnorePattern: '^_'
  no-useless-constructor: 'off'
  '@typescript-eslint/no-useless-constructor':
    - error
  no-shadow: 'off'
  '@typescript-eslint/no-shadow':
    - error
```

