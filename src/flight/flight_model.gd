class_name FlightModel
extends RefCounted

# Simplified 6DOF arcade flight model.
#
# Design choices:
#   - Forces expressed in m/s² (already per unit mass) to keep math readable.
#   - Lift scales with speed² and degrades near stall and when banked.
#   - Drag opposes velocity vector (not just forward), so sideslip costs energy.
#   - Angular rates applied directly to basis — no rotational inertia tensor.
#     This is intentional: it gives the arcade feel (responsive, not sluggish).
#   - Caller owns and passes the Transform3D each tick; model is stateless
#     except for velocity and throttle position.

const GRAVITY := Vector3(0.0, -9.81, 0.0)

var stats: Dictionary
var velocity: Vector3 = Vector3.ZERO
var throttle: float = 0.0   # 0.0 – 1.0, persists between ticks

func _init(aircraft_stats: Dictionary) -> void:
	stats = aircraft_stats

# Returns the updated Transform3D after one physics tick.
func tick(
	xform: Transform3D,
	pitch_in: float,
	roll_in: float,
	yaw_in: float,
	throttle_delta: float,
	afterburner: bool,
	delta: float
) -> Transform3D:

	_step_throttle(throttle_delta, delta)

	# Basis vectors in world space
	var forward := -xform.basis.z
	var up      :=  xform.basis.y
	var right   :=  xform.basis.x

	# --- Rotation ---
	# Rates in radians for this tick
	var p := deg_to_rad(stats.pitch_rate) * pitch_in * delta
	var r := deg_to_rad(stats.roll_rate)  * roll_in  * delta
	var y := deg_to_rad(stats.yaw_rate)   * yaw_in   * delta

	xform.basis = (xform.basis
		.rotated(right,   -p)
		.rotated(forward, -r)
		.rotated(up,      -y)
		.orthonormalized())

	# Recompute after rotation
	forward = -xform.basis.z
	up      =  xform.basis.y

	# --- Forces ---
	var speed := velocity.length()

	var thrust := stats.max_thrust * throttle
	if afterburner:
		thrust *= stats.afterburner_multiplier

	# Lift acts in aircraft-up direction; falls off when banked or near stall.
	var lift := stats.lift_factor * speed * speed
	lift *= clamp(up.dot(Vector3.UP), 0.0, 1.0)
	if speed < stats.stall_speed:
		lift *= speed / stats.stall_speed   # smooth stall onset

	# Drag opposes the velocity vector.
	var drag := Vector3.ZERO
	if speed > 0.01:
		drag = -velocity.normalized() * stats.drag_factor * speed * speed

	var accel := forward * thrust + up * lift + drag + GRAVITY
	velocity = (velocity + accel * delta).limit_length(stats.max_speed)
	xform.origin += velocity * delta

	return xform

# --- Private ---

func _step_throttle(delta_in: float, delta: float) -> void:
	# Half a full sweep per second at full input
	throttle = clamp(throttle + delta_in * 0.5 * delta, 0.0, 1.0)
