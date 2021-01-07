#### Install

```bash
yarn add -D @jest jest-extende @types/jest babel-jest ts-node
```

Init

```bash
yarn jest --init
```

Update config file `jest.config.ts`

```js
export default {
  //...
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
};
```

Create setup file

```bash
touch jest.setup.js
```

```js
import "jest-extended";
```

#### Module resolver

Update `jest.config.ts`

```ts
export default {
  // ...
  moduleNameMapper: {
    "^@src/(.*)$": "<rootDir>/your/folder/$1",
  },
};
```

#### Extend jest matchers

```ts
export declare global {
  declare namespace jest {
    interface Expect {
      toBeRenderedWith(expected: RegExp | string): any;
    }
  }
}
```
