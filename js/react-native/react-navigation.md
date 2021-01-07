# 5.8.10

#### Install

1. Base

```bash
yarn add @react-navigation/native
yarn add react-native-reanimated react-native-gesture-handler react-native-screens react-native-safe-area-context @react-native-community/masked-view
```

See [here](/react-native/gesture-handler.md) to install gesture-handler

Usage

```js
const App = () => {
  <NavigationContainer>{/* Rest of your app code */}</NavigationContainer>;
};
```

2. Stack

```bash
yarn add @react-navigation/stack
```

Usage

```js
const Stack = createStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

3. Tabs

```bash
yarn add @react-navigation/bottom-tabs
```

Usage

```js
const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator>
        <Tab.Screen name="Home" component={HomeScreen} />
        <Tab.Screen name="Settings" component={SettingsScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
```

4. Drawer

```bash
yarn add @react-navigation/drawer
```

Usage

```js
const Drawer = createDrawerNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Drawer.Navigator initialRouteName="Home">
        <Drawer.Screen name="Home" component={HomeScreen} />
        <Drawer.Screen name="Notifications" component={NotificationsScreen} />
      </Drawer.Navigator>
    </NavigationContainer>
  );
}
```

#### Typescript

- Root

```ts
type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  Feed: { sort: "latest" | "top" } | undefined;
};

import { createStackNavigator } from "@react-navigation/stack";

const RootStack = createStackNavigator<RootStackParamList>();
```

- `navigation` prop

```ts
import { StackNavigationProp } from "@react-navigation/stack";

type ProfileScreenNavigationProp = StackNavigationProp<
  RootStackParamList,
  "Profile"
>;

type Props = {
  navigation: ProfileScreenNavigationProp;
};
```

- `route` prop

```ts
import { RouteProp } from "@react-navigation/native";

type ProfileScreenRouteProp = RouteProp<RootStackParamList, "Profile">;

type Props = {
  route: ProfileScreenRouteProp;
};
```

#### Common libs:

- react-native-modal-datetime-picker
- react-native-picker-select
- react-navigation
- react-native-portalize + react-native-modalize (Bottom sheet)
