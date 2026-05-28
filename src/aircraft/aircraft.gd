class_name Aircraft
extends Node3D

# Top-level aircraft node.
# Owns the FlightModel and HotasInput; drives its own transform each physics tick.
# Extend this node (or attach it to a scene) to add weapons, damage, radar, etc.

@export var stats: Dictionary = {}  # Leave empty to use Config.PHANTOM default

var _model: FlightModel
var _input: HotasInput

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

	print("Aircraft online — %s" % name)
	print("Speed: 0  Alt: %.0f m  Throttle: 0%%" % position.y)

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
	_print_hud()

func _print_hud() -> void:
	# Temporary console HUD until a proper UI exists
	var spd  := _model.velocity.length()
	var alt  := position.y
	var thr  := _model.throttle * 100.0
	Engine.set_print_line_prefix("")  # no timestamp noise
	print_rich("[color=cyan]SPD[/color] %5.0f m/s  [color=yellow]ALT[/color] %6.0f m  [color=green]THR[/color] %3.0f%%\r" \
		% [spd, alt, thr])

# --- Public accessors (for HUD, AI, damage system) ---

func get_speed()    -> float: return _model.velocity.length()
func get_throttle() -> float: return _model.throttle
func get_altitude() -> float: return position.y
func get_velocity() -> Vector3: return _model.velocity
