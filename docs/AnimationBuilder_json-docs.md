# Animation Builder – JSON Format Documentation

This document describes the JSON format used by Animation Builder to generate 2D animations in Godot.

The builder reads a spritesheet and a JSON file, then creates animations inside an AnimationPlayer.

Rotation should be clockwise

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

length (required)
``` json
"length": 16
```

length of animation in sprite
used for setting Godot.Animation.HFrame

directions (optional)
``` json
"directions": 16
```

Controlls vframes for sprite
Use one row of animations as one direction

Default: 16

start_direction (optional)
``` json
"start_direction": "(0, 1)"
```

Vector2 set as start direction of animations
value used in ``to_iso`` modyfiers in angle values to transform them correctly

Default (0, 1)

iso_scale (optional)
``` json
"iso_scale" :0.865
```

tile width divided by tile height
value used in ``to_iso`` modyfier in vector2 / float based params

Default: 1.0

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

loop (optional)
``` json
"loop": true
```

Whether the animation loops
Default: true

## 4. Values (value tracks)

Values still needs to be improved and for now I wouldn't encourage you to use them. It's better to use functions for now

Values change on frame

Example:

``` json
"values": {
    "node_path:value": {
        "interpolation": "animation.interpolation_(type)",
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
"functions": {
  "node_path": {
    "method_name": [
      {
        "frame": 3,
        "values": [
          "$lib",
          ...
          ],
      },
      ...
    ]
  }
}
```

### Function properties
frame (optional)
``` json
"frame": 3
```

Frame at which the function runs

params (optional)
``` json
"params": [ ... ]
```

Array of parameters passed to the method

Parameters are defined using typed tokens (see below)

## 6. Parameter system

Parameters are written as strings and parsed by the builder.

### Modyfiers
you can think about them like some sort of functions applied to values
each type has its own modyfiers

modyfiers are split by ``;``(semicolon) character

syntax:
``` json
"$param;mod(mod_params, ...);..."
```

> If there are no modyfiers provided in type, it mean that it does not support any modyfiers

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

### Animation constants

same as tweens

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

name of the animation library in string

### $rotation(_angle)
``` json
"$rotation(_angle)"
```

rotation / rotation angle of current direction in float

Rotation formula:
``angle = (current_direction / total_directions)``

Rotation is clockwise

#### Modyfiers
##### "to_iso"
transform angle by iso_scale
formula:
`` angle = Vector2(angle_vector.x, angle_vector.y * iso_scale).to_angle() ``

##### Important note
angle is supposed to start on (0, 1), so when using (1, 0) (like godot does) as start it wrongly changes values. It will be probably changed in future. 

### $rotatable:(x, y)
``` json
"$rotatable:(1, 0)"
```

A Vector2 that is rotated per direction

Rotation formula:

``angle = (current_direction / total_directions) * 360°``


Rotation is clockwise

Useful for directional movement, offsets, impulses, etc.

#### Modyfiers
##### "to_iso"
transform angle by iso_scale
formula:
`` angle_vector = Vector2(angle_vector.x, angle_vector.y * iso_scale) ``

##### "rotate(_angle)(angle)"
rotate vector by angle

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

#### Modyfiers
##### "to_iso"
transform angle by iso_scale
formula:
`` angle = Vector2(angle_vector.x, angle_vector.y * iso_scale).to_angle() ``

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
##### "to_iso"
transform angle by iso_scale
formula:
`` angle_vector = Vector2(angle_vector.x, angle_vector.y * iso_scale) ``

##### "rotate(_angle)(angle)"
rotate vector by angle

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
