# Coconote AutoRecording Tweak

Automatically starts recording in Coconote app with 1-hour+ support.

## What It Does

1. Auto-taps **Continue** 3 times (skips onboarding/paywall)
2. Taps **New Note** button (pink button)
3. Taps **Record Audio** option
4. Taps **Start Recording**
5. **Prevents screen lock** for long recordings (1+ hours)
6. **Keep-alive timer** prevents app from backgrounding

## Installation to LiveContainer

1. Download `CoconoteAutoRecording.dylib` from [GitHub Actions](../../actions)
2. Copy to: `LiveContainer/Tweaks/com.bbauman.Scripty.app/`
3. Enable "Load Tweaks" in LiveContainer settings
4. Launch via URL:
   ```
   livecontainer://livecontainer-launch?bundle-name=com.bbauman.Scripty.app&container-folder-name=D2BB78F1-7C0D-4C1E-ABF1-2F96155A12B2
   ```

## Building Locally

### macOS with Theos
```bash
make
```

### Windows (via GitHub Actions)
Just push to this repo - GitHub Actions builds automatically!

## Coordinates Used

Based on iPhone screenshots:

| Button | Position |
|--------|----------|
| Continue | Center, 65% down |
| New Note | 75% right, 92% down |
| Record Audio | Center, 35% down |
| Start Recording | Center, 85% down |

## Troubleshooting

- **Build fails**: Check GitHub Actions logs
- **Taps miss**: Adjust coordinates in Tweak.xm
- **Stops after 1 hour**: Check iOS background app refresh settings
