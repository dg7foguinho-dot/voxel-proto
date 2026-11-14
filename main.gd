extends Node3D

func _ready() -> void:
	var world := World.new()
	world.name = "World"
	add_child(world)

	var player := Player.new()
	player.name = "Player"
	player.position = Vector3(48, 20, 48)
	add_child(player)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.shadow_enabled = true
	add_child(sun)

	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	we.environment = env
	add_child(we)
