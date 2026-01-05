# Animation Builder – JSON Format Documentation (v1.2.0)

This document describes the JSON format used by Animation Builder to generate 2D animations in Godot.

The builder reads:
- spritesheet
- JSON file
and creates animations inside an AnimationPlayer.

> Rotation is clockwise

## 1. High-level structure

The JSON file contains one or more animation libraries, keyed by library name:
``` json
{
  "character": {
    "fps": 12,
    "texture": "res://sprites/character.png",
    "length": 16,
    "directions": 16,
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

Used to:
- Convert frametime parameter into seconds

texture (required)
``` json
"texture": "res://sprites/character.png"
```

Path to the spritesheet texture

Must exist and should be a .png file

length (required)
``` json
"length": 16
```

Number of horizontal frames in spritesheet
Used to set:
- ``Animation.hframes``

directions (optional)
``` json
"directions": 16
```

Number of directional rows in the spritesheet

Rules:
- Each row represents one direction
- All animation in a library must use the same value

Used to set:
- ``Animations.vframes``

Default: ``16``

start_direction (optional)
``` json
"start_direction": "(1, 0)"
```

Vector2 representing the forward direction

Used by:
- ``to_iso()`` modyfiers on angles

Default: ``(1, 0)``

iso_scale (optional)
``` json
"iso_scale" :0.865
```

Isometric scale factor (tile width ÷ tile height)
Used by:
- ``to_iso()`` modyfiers

Default: 1.0

animations (required)
``` json
"animations": [ ... ]
```

An array of animation definitions (see in point 3).

## 3. Animation definition

Example:

``` json
{
  "name": "walk",
  "start": 0,
  "length": 6,
  "loop": true,
  "values": { ... },
  "functions": { ... }
}
```

name (opitonal)
``` json
"name": "walk"
```

Base name of the animation

The builder automatically creates one animation per direction
with names ``{name}{dir}``
Final animation names will be:
```
walk0, walk1, walk2, ...
```
default: ``""``

start (required)
``` json
"start": 0
```

Horizontal frame index where this animation starts

Measured in frames, not seconds

length (required)
``` json
"length": 6
```

Number of frames in this animation

Frames are read horizontally from the spritesheet

loop (optional)
``` json
"loop": true
```

Whether the animation loops
Default: ``true``

## 4. Values (value tracks)

Values modify node properties at specific frames.

Example:

``` json
"values": {
    "Node2D:rotation": {
        "interpolation": "animation.interpolation_linear",
        "values": [
            {
                "frame": 2.5,
                "value": "$rotation"
            }
        ]
    }
}
```

### Value properties

interpolation (optional)

``` json
"interpolation": "animation.interpolation_nearest",
```

interpolation type for track

frame (required)

``` json
"frame": "2.5",
```

Time of value change in frames (can be fractional)

value (required)

``` json
"value": "$b:true",
```

Value using the Parameter System (Read more in section 6.)

## 5. Functions (method tracks)

Animations may define method calls that are triggered at specific frames.

Example:

``` json
"functions": {
  "CharacterBody2D": {
    "apply_impulse": [
      {
        "frame": 1.5,
        "values": [
          "$rotatable:(200, 0)",
          ],
      },
    ]
  }
}
```

### Function properties
frame (optional)
``` json
"frame": 1.5
```

Frame at which the function runs (can be fractional)

values (optional)
``` json
"values": [ ... ]
```

Array of values passed to the method

values are defined using Parameter System (see below)

## 6. Parameter system

Parameters are written as strings and parsed by the builder.

### Modyfiers
you can think about them like some sort of functions applied to values
each type has its own modyfiers

modyfiers are split by ``;``(semicolon) character

syntax:
``` json
"$param;mod(arg1, arg2);mod2(...)"
```
- modyfiers are applied left to right
- If a type does not support modyfier, they are ignored

> If there are no modyfiers provided in type, it mean that it does not support any modyfiers

## 7. Supported parameter types
### Constants

You can directly use constants by names
```
"tween.trans_linear"
"animation.interpolation_nearest"
```


#### Tween constants

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

#### Animation constants

Supported values:
- ``animation.interpolation_nearest``
- ``animation.interpolation_linear``
- ``animation.interpolation_cubic``
- ``animation.interpolation_linear_angle``
- ``animation.interpolation_cubic_angle``

### $lib
``` json
"$lib"
```

Returns the animation library name (String).

### $rotation(_angle)
``` json
"$rotation(_angle)"
```

Returns rotation (angle) for the current direction.

Formula:
``angle = (current_direction / total_directions)``

Rotation is clockwise

#### Modyfiers
- ``to_iso()``

### $rotatable:(x, y)
``` json
"$rotatable:(1, 0)"
```

Returns a ``Vector2`` rotated per direction.

Rotation is clockwise

Useful for directional movement, offsets, impulses, etc.

#### Modyfiers
- ``to_iso()``
- ``scale(f)``
- ``invert_x()``
- ``invert_y()``
- ``rotate(rad)``
- ``rotate_angle(deg)``

### $frametime:value
``` json
"$frametime:2"
```

Returns seconds based on animation FPS.

Example:
```
fps = 12

$frametime:2 -> 0.1(6)s
```

#### Modyfiers
- ``clamp(min, max)``
- ``snap(step)``

### $dir
``` json
"$dir"
```

Returns direction index(int) 

### dir_norm
``` json
"$dir_norm"
```

Returns normalized direction(0.0 -> 1.0)

#### Modyfiers
- ``clamp(min, max)``
- ``snap(step)``

### $i:value (Integer)
``` json
"$i:5"
```

### $f:value (Float)
``` json
"$f:0.75"
```

#### Modyfiers
- ``to_iso()``
- ``clamp(min, max)``
- ``snap(step)``

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

#### Modyfiers
- ``to_iso()``
- ``scale(f)``
- ``invert_x()``
- ``invert_y()``
- ``rotate(rad)``
- ``rotate_angle(deg)``

### $b:value (Boolean)
``` json
"$b:true"
"$b:false"
```

Accepted values:

``true, t``

``false, f``

## 8. Example animation entry
``` json
{
  "name": "attack",
  "start": 12,
  "length": 4,
  "loop": false,

  "functions": {
    "CharacterBody2D": {
      "apply_impulse": [
        {
          "frame": 1,
          "params": [
            "$rotatable:(200, 0);to_iso()",
            "$frametime:1"
          ]
        }
      ]
    },

    "AudioPlayer": {
      "play_sound": [
        {
          "frame": 0,
          "params": [
            "$s:swing_heavy"
          ]
        }
      ]
    }
  }
}
```

9. Common errors
Error	Cause
- Wrong directions	Animations use different directions
- Invalid param	Unsupported $type:
- Method not found on node
10. Summary of critical rules

- All animations must use the same directions value
- Spritesheet must be correctly aligned
- Parameters must follow the supported formats
