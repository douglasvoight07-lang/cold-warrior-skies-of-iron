extends Node3D

func _ready() -> void:
	print("Main: _ready fired")
	_setup_sky()
	_setup_sun()
	_setup_ground()
	_setup_aircraft()
	print("Main: world ready")

func _setup_sky() -> void:
	var env := Environment.new()
	env.background_mode  = Environment.BG_COLOR
	env.background_color = Color(0.28, 0.55, 0.80)   # solid blue — reliable on any renderer
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color  = Color(0.6, 0.7, 0.9)
	env.ambient_light_energy = 0.5

	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

func _setup_sun() -> void:
	var sun := DirectionalLight3D.new()
	sun.light_energy     = 1.5
	sun.shadow_enabled   = true
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	add_child(sun)

func _setup_ground() -> void:
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(40000.0, 40000.0)
	var ground := MeshInstance3D.new()
	ground.mesh = mesh
	add_child(ground)

func _setup_aircraft() -> void:
	var phantom := Node3D.new()
	phantom.name     = "Phantom"
	phantom.position = Vector3(0.0, 2000.0, 0.0)

	# Placeholder fuselage box
	var box := BoxMesh.new()
	box.size = Vector3(3.0, 0.8, 8.0)
	var model := MeshInstance3D.new()
	model.mesh = box
	phantom.add_child(model)

	# Chase camera — must be added before the script's _ready() fires
	var cam := Camera3D.new()
	cam.name    = "ChaseCamera"
	cam.current = true
	phantom.add_child(cam)

	# Attach the flight script and spawn into the tree
	phantom.set_script(load("res://src/aircraft/aircraft.gd"))
	add_child(phantom)
