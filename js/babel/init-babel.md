Init

```bash
yarn add -D @babel/core @babel/preset-env @babel/plugin-transform-runtime
```

Add typescript

```bash
yarn add -D @babel/preset-typescript typescript
```

Create config file with following content

```bash
touch babel.config.js
```

```js
module.exports = {
  presets: [
    ["@babel/preset-env", { targets: "defaults" }],
    "@babel/preset-typescript",
  ],
  plugins: ["@babel/plugin-transform-runtime"],
};
```
