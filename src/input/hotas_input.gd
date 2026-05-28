class_name HotasInput
extends Node

# Abstracts all pilot input into named channels.
# Keyboard bindings are always active as fallback.
# HOTAS/gamepad axes overlay keyboard when a device is detected.
# Axis/button names match the Input Map defined in project.godot.

var _deadzone: float
var _curve: float

func _ready() -> void:
	_deadzone = Config.INPUT.deadzone
	_curve    = Config.INPUT.axis_curve

	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		print("[HotasInput] No HOTAS/gamepad detected — keyboard active")
	else:
		print("[HotasInput] Device: ", Input.get_joy_name(pads[0]))

# --- Axis channels (all return -1.0 to 1.0) ---

func pitch() -> float:
	return _axis("pitch_down", "pitch_up")

func roll() -> float:
	return _axis("roll_left", "roll_right")

func yaw() -> float:
	return _axis("yaw_left", "yaw_right")

# Returns +1 / 0 / -1 for throttle up / hold / down.
func throttle_delta() -> float:
	return Input.get_axis("throttle_down", "throttle_up")

# --- Button channels ---

func afterburner() -> bool:
	return Input.is_action_pressed("afterburner")

func fire_weapon() -> bool:
	return Input.is_action_just_pressed("fire_weapon")

# --- Private ---

func _axis(neg: StringName, pos: StringName) -> float:
	var raw := Input.get_axis(neg, pos)
	return _curve_map(_deadzone_map(raw))

func _deadzone_map(v: float) -> float:
	if absf(v) < _deadzone:
		return 0.0
	return signf(v) * (absf(v) - _deadzone) / (1.0 - _deadzone)

func _curve_map(v: float) -> float:
	return signf(v) * pow(absf(v), _curve)
