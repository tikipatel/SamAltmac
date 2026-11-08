# Memory Drop Alert

A tiny macOS menu bar app that monitors memory usage and alerts you when usage **drops below** a threshold (80% by default).

It does not alert when memory goes *above* the threshold. The alert fires when usage crosses from at/above the threshold to below it.

## How it works

- Shows current memory usage in the menu bar (for example `Mem 83%`).
- Samples memory every 5 seconds (configurable: 2, 5, 15 or 60 s).
- Memory used is calculated the same way as Activity Monitor's "Memory Used": app memory + wired + compressed, divided by physical RAM.
- When usage drops below the threshold, it posts a macOS notification. It re-arms once usage climbs back to the threshold or higher.
- A 60-second cooldown prevents a burst of alerts if usage hovers right around the threshold.
- Optional: "Alert at launch if already below" fires an alert on the first reading if usage is already under the threshold.
- The threshold is adjustable from 10% to 95% using the slider in the menu.

## Requirements

- macOS 13 Ventura or later
- Xcode 15+ (or the Swift 5.9+ toolchain)

## Build and run

```bash
./scripts/build-app.sh
open build/MemoryDropAlert.app
```

The first time it runs, macOS asks for permission to show notifications. Allow it, then click **Test Alert** in the menu to confirm.

To install it, drag `build/MemoryDropAlert.app` into `/Applications`. To launch it at login, add it under System Settings > General > Login Items.

You can also run it with `swift run` during development. Outside an `.app` bundle, macOS notifications aren't available, so the app beeps and logs to the console instead.

Each push to `main` builds the app on GitHub Actions. You can download the zipped app from the workflow run's artifacts. It is ad-hoc signed and not notarized, so on first launch you may need to right-click it and choose **Open**.

## Tests

```bash
swift test
```

The threshold-crossing logic lives in `BelowThresholdDetector` and is covered by unit tests.
