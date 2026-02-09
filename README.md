# Motion Sickness Diagnostic Tool

A first-person Godot 4.5 scene for exploring which visual and movement effects trigger motion sickness. Walk through indoor corridors and an outdoor area while toggling 11 parameters — or let the automated demo loop escalate them for you.

## Running

Open the project in Godot 4.5+ and press F5, or run the exported binary directly.

## Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Look |
| Tab | Open/close settings panel |
| Escape | Stop demo loop (during demo) |

## Settings Panel

Press **Tab** to open the settings panel on the right side of the screen. From here you can adjust:

**Display** — Resolution, Fullscreen

**Camera & Visual Effects** — Field of View, Head Bob, Mouse Smoothing, Motion Blur, Chromatic Aberration, Depth of Field

**Performance** — Frame Rate Cap, Frame Pacing

**Movement** — Movement Speed, Acceleration, Reference Point

Use **Reset All to Defaults** to return every motion sickness parameter to its safe starting value.

## Demo Loop

Click **Start Demo Loop** at the bottom of the settings panel. The player auto-walks through the scene while effects are enabled one at a time every 8 seconds, in order of increasing intensity:

1. FOV narrowed to 70°
2. Subtle head bob
3. Low mouse smoothing
4. Weapon reference point
5. Fast movement speed
6. Chromatic aberration
7. Subtle depth of field
8. Low motion blur
9. Aggressive head bob
10. High motion blur
11. FOV narrowed to 60°
12. 30 FPS frame rate cap
13. Jittery frame pacing
14. Delayed acceleration
15. Aggressive depth of field

Press **Escape** when you start feeling sick. A results screen shows which step you reached, how long you lasted, and every effect that was active. Click **Close & Reset** to return to normal play with defaults restored.

If you survive all 15 steps, the demo ends automatically with a completion message.

## Concept

Motion sickness in first-person games is caused by a mismatch between what the eyes see and what the inner ear expects. Different people are sensitive to different triggers. This tool isolates common offenders — low FOV, head bob, motion blur, input latency, frame rate issues — so you can identify your personal thresholds and communicate them to game developers or use them to configure comfort settings.
