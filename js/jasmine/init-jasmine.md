#### Install

```bash
yarn add jasmine @types/jasmine -D
yarn jasmine init
```

#### Babel integration

```bash
yarn add -D @babel/register
```

```json
// spec/support/jasmine.json
{
  "helpers": [
    "../node_modules/@babel/register/lib/node.js"
  ]
}
```

