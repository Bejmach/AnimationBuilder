# Animation Builder – JSON Format Documentation

This document describes the JSON format used by Animation Builder to generate 2D animations in Godot.

The builder reads a spritesheet and a JSON file, then creates animations inside an AnimationPlayer.

## 1. High-level structure

The JSON file contains one or more animation libraries, keyed by library name:
``` json
{
  "character": {
    "fps": 12,
    "texture": "res://sprites/character.png",
    "animations": [
      { ... }
    ]
  }
}
```


Each top-level key represents a single animation library.

## 2. Library properties
fps (required)
``` json
"fps": 12
```

Frames per second for all animations in this library

Used to calculate animation length and timing

texture (required)
``` json
"texture": "res://sprites/character.png"
```

Path to the spritesheet texture

Must exist and must be a .png file

animations (required)
``` json
"animations": [ ... ]
```

An array of animation definitions (see below).

## 3. Animation definition

Example:

``` json
{
  "name": "walk",
  "start": 0,
  "length": 6,
  "loop": true,
  "directions": 8,
  "functions": [ ... ]
}
```

name (required)
``` json
"name": "walk"
```

Base name of the animation

The builder automatically creates one animation per direction

Final animation names will be:

walk0, walk1, walk2, ...

start (required)
``` json
"start": 0
```

Horizontal frame index where this animation starts

Measured in frames, not pixels

length (required)
``` json
"length": 6
```

Number of frames in this animation

Frames are read horizontally from the spritesheet

### ⚠ Animation frame rules (VERY IMPORTANT)

Animations must not overlap

If animation A ends at frame 5, animation B must not start at 5

#### Example (❌ invalid):

```
walk: start 0, length 6  → frames 0–5
run:  start 5, length 6  → overlaps at frame 5
```


#### Correct version (✅ valid):
```
run: start 6
```

No gaps or overlaps are allowed

The builder validates that frames are continuous and non-overlapping

If this rule is violated, the builder will fail with an error.

loop (optional)
``` json
"loop": true
```

Whether the animation loops
Default: true

directions (optional, but critical)
``` json
"directions": 8
```

Number of directional variants (e.g. 4, 8, 16)

Controls vertical frames (vframes)

### ⚠ Direction rule (VERY IMPORTANT)

ALL animations in the same library MUST use the SAME directions value

Reason:

All animations share the same spritesheet layout

Mixed direction counts will break frame indexing

#### Example (❌ invalid):

``` json
{
  "name": "walk",
  "directions": 8
},
{
  "name": "idle",
  "directions": 16
}
```


#### Example (✅ valid):

``` json
{
  "name": "walk",
  "directions": 8
},
{
  "name": "idle",
  "directions": 8
}
```

Default value (if omitted): 16

## 4. Values (value tracks)

Values still needs to be improved and for now I wouldn't encourage you to use them. It's better to use functions for now

Values change on frame

Example:

``` json
"values": [
    {
        "path": "Sprite2D:rotation",
        "frame": 2.0,
        "value": "$rotation",
    },
    { ... }
]
```

> if you want multiple changes of the same value, you need to make multiple elements with same path (temporary)

### Value properties

path (required)

``` json
"path": "Sprite2D:rotation",
```

Path to node value in scene

frame (required)

``` json
"frame": "2.5",
```

Time of value change in frames

value (required)

``` json
"value": "$b:true",
```

Value to change as param from Parameter System (Read more in section 6.)

## 5. Functions (method tracks)

Animations may define method calls that are triggered at specific frames.

Example:

``` json
"functions": [
  {
    "name": "play_sound",
    "start": 2,
    "params": ["$s:footstep"]
  }
]
```

### Function properties
name (required)
``` json
"name": "play_sound"
```

Name of the method to call

Must exist on the animated node

start (required)
``` json
"start": 2
```

Frame index at which the method is called

params (optional)
``` json
"params": [ ... ]
```

Array of parameters passed to the method

Parameters are defined using typed tokens (see below)

## 6. Parameter system

Parameters are written as strings and parsed by the builder.

Supported parameter types
### Tween constants

You can directly use tween constants by name:
```
"tween.trans_linear"
"tween.ease_in_out"
```

Supported values:
- ``tween.trans_linear``
- ``tween.trans_sine``
- ``tween.trans_quint``
- ``tween.trans_quart``
- ``tween.trans_quad``
- ``tween.trans_expo``
- ``tween.trans_elastic``
- ``tween.trans_cubic``
- ``tween.trans_circ``
- ``tween.trans_bounce``
- ``tween.trans_back``
- ``tween.trans_spring``
- ``tween.ease_in``
- ``tween.ease_out``
- ``tween.ease_in_out``
- ``tween.ease_out_in``

### $rotation(_angle)
``` json
"$rotation(_angle)"
```

rotation / rotation angle of current direction in float

Rotation formula:
``angle = (current_direction / total_directions)``

Rotation is clockwise

### $rotatable:(x, y)
``` json
"$rotatable:(1, 0)"
```

A Vector2 that is rotated per direction

Rotation formula:

``angle = (current_direction / total_directions) * 360°``


Rotation is clockwise

Useful for directional movement, offsets, impulses, etc.

### $frametime:value
``` json
"$frametime:2"
```

A float multiplied by the animation’s frame time

Allows specifying timing in frames instead of seconds

Example:


fps = 12

$frametime:2 → 2 * (1 / 12) seconds

### $i:value (Integer)
``` json
"$i:5"
```

### $f:value (Float)
``` json
"$f:0.75"
```

### $s:value (String)
``` json
"$s:footstep"
```

### $v2:(x, y) (Vector2)
``` json
"$v2:(32, -16)"
```

Plain Vector2

Not direction-rotated

### $b:value (Boolean)
``` json
"$b:true"
"$b:false"
```

Accepted values:

``true, t``

``false, f``

## 7. Example animation entry
``` json
{
  "name": "attack",
  "start": 12,
  "length": 4,
  "loop": false,
  "directions": 8,
  "functions": [
    {
      "name": "apply_impulse",
      "start": 1,
      "params": [
        "$rotatable:(200, 0)",
        "$frametime:1"
      ]
    }
  ]
}
```

8. Common errors
Error	Cause
- Animations overlap	start + length conflicts
- Missing frames	Gaps between animations
- Wrong directions	Animations use different directions
- Invalid param	Unsupported $type:
- Method not called	Method name not found on node
9. Summary of critical rules

- ✔ All animations must use the same directions value
- ✔ Animations must not overlap
- ✔ Frame indices must be continuous
- ✔ Spritesheet must be correctly aligned
- ✔ Parameters must follow the supported formats
