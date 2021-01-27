#### Install

```bash
yarn add -D eslint
yarn eslint --init

yarn add -D prettier
```

#### Prettier config

```bash
touch .prettierrc.yml
```

```yml
singleQuote: true
printWidth: 120
semi: false
trailingComma: es5
```

###### Install eslint plugin

```bash
yarn add -D eslint-config-prettier eslint-plugin-prettier
```

```bash
# .eslintrc.yml
extends: 
	- "plugin:prettier/recommended"
```



