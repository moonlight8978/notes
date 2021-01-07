#### Check current activity name

```bash
adb shell
  > dumpsys window windows | grep -E "mCurrentFocus"
```

#### Screenshot

```bash
adb exec-out screencap -p > screen.png
```
