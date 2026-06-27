extends Node

# All tuning constants live here. Change these to adjust feel without touching game logic.

# F-4B/C Phantom II
# Forces are in m/s² (pre-divided by mass) so the flight model stays unit-clean.
const PHANTOM := {
	# --- Propulsion ---
	"max_thrust": 8.0,               # m/s² at full throttle, no afterburner
	"afterburner_multiplier": 1.5,   # thrust scale when AB is lit
	"fuel_burn_rate": 0.8,           # fuel units/s at full throttle
	"afterburner_fuel_multiplier": 2.5,

	# --- Aerodynamics ---
	# lift_accel = lift_factor * speed²; tuned so lift ≈ g at cruise (250 m/s)
	"lift_factor": 0.000157,
	# drag_accel = drag_factor * speed²
	"drag_factor": 0.000055,
	"stall_speed": 70.0,             # m/s — lift falls off below this

	# --- Envelope ---
	"max_speed": 600.0,              # m/s (~Mach 1.75 at altitude, arcade-scaled)
	"cruise_speed": 250.0,           # m/s reference (used for UI only)

	# --- Angular rates at full stick deflection (deg/s) ---
	"pitch_rate": 60.0,
	"roll_rate": 120.0,
	"yaw_rate": 25.0,
}

# Input processing
const INPUT := {
	"deadzone": 0.12,
	"axis_curve": 1.5,  # exponent >1 gives finer control near stick center
}
