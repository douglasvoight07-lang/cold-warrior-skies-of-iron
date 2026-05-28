class_name Aircraft
extends Node3D

# Top-level aircraft node.
# Owns the FlightModel and HotasInput; drives its own transform each physics tick.
# Extend this node (or attach it to a scene) to add weapons, damage, radar, etc.

@export var stats: Dictionary = {}  # Leave empty to use Config.PHANTOM default

var _model: FlightModel
var _input: HotasInput
var _hud_timer: float = 0.0

@onready var _camera: Camera3D = $ChaseCamera

func _ready() -> void:
	if stats.is_empty():
		stats = Config.PHANTOM

	_model = FlightModel.new(stats)

	_input = HotasInput.new()
	add_child(_input)

	# Chase camera: behind and above, looking slightly down toward the nose
	_camera.position      = Vector3(0.0, 5.0, 16.0)
	_camera.rotation_degrees = Vector3(-15.0, 0.0, 0.0)

	# 250 m/s is where lift_factor balances gravity in config.gd
	_model.velocity = Vector3(0.0, 0.0, -250.0)
	_model.throttle = 0.7

	print("Aircraft online — %s | Alt %.0f m" % [name, position.y])

func _physics_process(delta: float) -> void:
	transform = _model.tick(
		transform,
		_input.pitch(),
		_input.roll(),
		_input.yaw(),
		_input.throttle_delta(),
		_input.afterburner(),
		delta
	)
	_hud_timer += delta
	if _hud_timer >= 1.0:
		_hud_timer = 0.0
		_print_hud()

func _print_hud() -> void:
	var spd := _model.velocity.length()
	var alt := position.y
	var thr := _model.throttle * 100.0
	print_rich("[color=cyan]SPD[/color] %5.0f m/s  [color=yellow]ALT[/color] %6.0f m  [color=green]THR[/color] %3.0f%%" \
		% [spd, alt, thr])

# --- Public accessors (for HUD, AI, damage system) ---

func get_speed()    -> float: return _model.velocity.length()
func get_throttle() -> float: return _model.throttle
func get_altitude() -> float: return position.y
func get_velocity() -> Vector3: return _model.velocity
