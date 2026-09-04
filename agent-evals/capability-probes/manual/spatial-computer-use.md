# Spatial computer-use protocol

Use this protocol on a real 3D editor or viewer with a known-good reference image and scene
asset. The operator chooses the project and explicitly authorizes edits before the trial.

## Fixed inputs

- Pin the project commit, app/browser version, model ID, effort, viewport, scene, and
  reference image.
- Seed one visual defect, one interaction defect, and one malformed or missing asset.
- Define measurable acceptance checks before the model sees the task.

## Trial

1. Launch through the real UI in an isolated browser or desktop session.
2. Ask the model to inspect the reference and scene, navigate the UI, manipulate the camera,
   reproduce all three defects, and identify their sources.
3. Allow repairs, then require a fresh launch and exact replay of orbit, zoom, reset, asset
   reload, and viewport-resize journeys.
4. Break one dependency slowly and one completely. Record whether the UI exposes and recovers
   from each failure.

## PASS evidence

- Before/after screenshots from the fixed viewport plus a short interaction recording.
- Console and network logs with no unexplained errors.
- Correct object count, transform, material, camera state, and interaction state after replay.
- File-scoped change list and passing project-native checks.
- Measured completion time and intervention count versus the same-model baseline task.

A prose diagnosis without direct UI actions is not computer-use evidence. Reading SVG, OBJ,
or scene source without inspecting the rendered result is not vision evidence.
