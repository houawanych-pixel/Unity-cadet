extends Node3D
# Mobile cockpit demo. Flight / cone-hit foundation adapted from the owner's
# homelancer-digital scripts/game.gd @ fff8284; no external game assets.
const HUD = preload("res://CockpitHUD.gd")
var ship: Node3D
var camera: Camera3D
var hud: Control
var targets: Array[Node3D] = []
var mines: Array[Dictionary] = []
var flight := Vector2.ZERO
var aim := Vector2.ZERO
var shield := 100.0
var hull := 100.0
var energy := 100.0
var missiles := 6
var mine_stock := 3
var kills := 0
var elapsed := 0.0
var distance_flown := 0.0
var cooldown := 0.0
var missile_cd := 0.0
var mine_cd := 0.0
var incoming_cd := 4.0
var started := false
var paused := false
var comms_open := false
var linked := false
var holding_fire := false
var auto_modes := [false, false, false, false, false, false]
var message := "Destroy 3 training drones. Judy is on your wing."
var judy_line := "Ready, Hova? Left stick flies. Right stick aims. Take your time."
var pitch := 0.0
var repair_stock := [5, 5, 5]
var repair_cd := [0.0, 0.0, 0.0]
var damage_age := 10.0
var engine_off := false
var thrusting := false
var speed := 9.0
var warp_charge := -1.0
var sector := 1
var tracked: Node3D
var salvage: Array[Node3D] = []
var contacts_open := false
var caller := ""
var active_contact := "LT. JUDY"
var call_log: Array[String] = []
var incoming_sent := false

func mesh_part(parent: Node3D, at: Vector3, dimensions: Vector3, tint: Color, sphere := false) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	if sphere:
		var ball := SphereMesh.new()
		ball.radial_segments = 16
		ball.rings = 8
		part.mesh = ball
	else:
		part.mesh = BoxMesh.new()
	part.scale = dimensions
	part.position = at
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = 1.0
	part.material_override = mat
	parent.add_child(part)
	return part

func fighter(parent: Node3D, tint: Color) -> Node3D:
	var model := Node3D.new()
	parent.add_child(model)
	mesh_part(model, Vector3.ZERO, Vector3(1.0, 0.5, 3.0), tint)
	var left := mesh_part(model, Vector3(-1.5, 0, 0.5), Vector3(2.0, 0.16, 1.3), tint)
	left.rotation.y = -0.35
	var right := mesh_part(model, Vector3(1.5, 0, 0.5), Vector3(2.0, 0.16, 1.3), tint)
	right.rotation.y = 0.35
	mesh_part(model, Vector3(0, 0.3, -0.5), Vector3(0.65, 0.3, 0.9), Color("193952"))
	mesh_part(model, Vector3(0, 0, 1.6), Vector3(0.65, 0.3, 0.2), Color("52eaff"))
	return model

func _ready() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("071426")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("9dbce2")
	env.environment.ambient_light_energy = 0.7
	add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	add_child(light)
	ship = Node3D.new()
	add_child(ship)
	camera = Camera3D.new()
	camera.fov = 78
	camera.far = 2500
	ship.add_child(camera)
	camera.current = true
	mesh_part(self, Vector3(-260, -120, -600), Vector3(190, 190, 190), Color("235ba4"), true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	# One MultiMesh draw for the star field.
	var stars := MultiMeshInstance3D.new()
	stars.multimesh = MultiMesh.new()
	stars.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var star_mesh := SphereMesh.new()
	star_mesh.radius = 0.65
	star_mesh.height = 1.3
	star_mesh.radial_segments = 4
	star_mesh.rings = 1
	stars.multimesh.mesh = star_mesh
	stars.multimesh.instance_count = 250
	var white := StandardMaterial3D.new()
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	white.albedo_color = Color("b8dfff")
	stars.material_override = white
	for i in 250:
		var direction := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		stars.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, direction * 1100))
	add_child(stars)
	for i in 16:
		mesh_part(self, Vector3(rng.randf_range(-180, 180), rng.randf_range(-80, 70), -100-i*30), Vector3.ONE * rng.randf_range(2, 8), Color("647286"), true)
	var wing := fighter(ship, Color("f4bd45"))
	wing.position = Vector3(18, 3, -38)
	for i in 3:
		var target := fighter(self, Color("ed735e"))
		target.position = Vector3((i-1)*22, (i%2)*8, -85-i*30)
		target.set_meta("hp", 4)
		target.set_meta("origin", target.position)
		targets.append(target)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = HUD.new()
	hud.game = self
	layer.add_child(hud)
	if "--self-test" in OS.get_cmdline_user_args():
		call_deferred("self_test")

func target_under_aim() -> Node3D:
	var center: Vector2 = hud.reticle()
	var best: Node3D = null
	var nearest := 500.0
	for target in targets:
		if not is_instance_valid(target) or camera.is_position_behind(target.global_position):
			continue
		var pixels := camera.unproject_position(target.global_position)
		var range_to := ship.position.distance_to(target.position)
		if pixels.distance_to(center) < 62 and range_to < nearest:
			best = target
			nearest = range_to
	return best

func hit(target: Node3D, damage: int) -> void:
	if not is_instance_valid(target):
		return
	var hp: int = target.get_meta("hp") - damage
	target.set_meta("hp", hp)
	if hp <= 0:
		targets.erase(target)
		var pickup := mesh_part(self, target.position, Vector3.ONE * 2, Color("72f5cf"))
		salvage.append(pickup)
		if tracked == target: tracked = null
		target.queue_free()
		kills += 1
		message = "Training target neutralized. %d / 3" % kills
		if kills == 3:
			message = "TRAINING COMPLETE • Tap debrief below"
			judy_line = "Clean work, Hova. All three drones are down. That's our first drill complete."
			comms_open = true

func shot(kind := 0) -> bool:
	if not started or paused or hull <= 0:
		return false
	var target := target_under_aim()
	if kind == 0:
		if cooldown > 0 or energy < 2:
			return false
		cooldown = 0.22
		energy -= 2
	elif kind == 1:
		if missile_cd > 0 or missiles <= 0 or target == null:
			message = "Missile needs a target inside the aiming ring." if missiles > 0 else "No missiles remaining."
			return false
		missiles -= 1
		missile_cd = 1.8
	else:
		if mine_cd > 0 or mine_stock <= 0:
			return false
		mine_stock -= 1
		mine_cd = 2
		var orb := mesh_part(self, ship.position, Vector3.ONE * 0.8, Color("f5cb54"), true)
		mines.append({"node":orb, "ttl":18.0})
		message = "Mine deployed. Triggers within 24 m of a drone."
		return true
	hud.flash = 0.1
	if target != null:
		hit(target, 4 if kind == 1 else 1)
	return true

func regenerate(kind: int, _delta := 1.0) -> void:
	if kind < 0 or kind > 2 or repair_stock[kind] <= 0 or repair_cd[kind] > 0:
		return
	var current: float = [shield, hull, energy][kind]
	if current >= 100: return
	repair_stock[kind] -= 1
	repair_cd[kind] = 1.0
	if kind == 0: shield = minf(100, shield + 35)
	if kind == 1: hull = minf(100, hull + 35)
	if kind == 2: energy = minf(100, energy + 35)
	message = "Repair charge used. %d / 5 remaining." % repair_stock[kind]

func track_next() -> void:
	if targets.is_empty():
		tracked = null
		message = "No targets on sensors."
		return
	var idx := targets.find(tracked)
	tracked = targets[(idx + 1) % targets.size()]
	message = "Tracking training drone. Steer toward its marker."

func tractor() -> void:
	var recovered := 0
	for pickup in salvage.duplicate():
		if ship.position.distance_to(pickup.position) <= 100:
			for i in 3: repair_stock[i] = mini(5, repair_stock[i] + 1)
			salvage.erase(pickup)
			pickup.queue_free()
			recovered += 1
	message = "Salvage collected. Repair stocks replenished (max 5)." if recovered > 0 else "Tractor: approach green salvage within 100 m."

func toggle_engine() -> void:
	engine_off = not engine_off
	if engine_off: thrusting = false
	message = "Engine cut. Braking to a stop for this training build." if engine_off else "Engine online."

func warp() -> void:
	if warp_charge >= 0:
		warp_charge = -1
		message = "Warp cancelled."
	elif speed > 0.2:
		message = "Cut the engine and stop before charging warp."
	elif energy < 25:
		message = "Warp requires 25% energy."
	else:
		warp_charge = 0
		message = "Warp charging. Hold still for 5 seconds."

func call_contact(who: String) -> void:
	active_contact = who
	caller = ""
	contacts_open = false
	comms_open = true
	call_log.push_front("Connected: " + who)
	call_log.resize(mini(3, call_log.size()))
	if who == "LT. JUDY": command("status")
	else: judy_line = "Training channel identified. This is a simulated hostile transmission."

func end_call() -> void:
	call_log.push_front("Ended: " + active_contact)
	call_log.resize(mini(3, call_log.size()))
	comms_open = false

func command(value: String) -> void:
	if value == "link":
		if not targets.is_empty():
			judy_line = "Negative, Hova. Clear the training drones first, then we can test the link."
		else:
			linked = not linked
			judy_line = "Link simulation confirmed." if linked else "Unlink confirmed. Back on your wing."
	elif value == "status":
		judy_line = "Your shield is %d%%, hull %d%%, energy %d%%. %d training targets remain." % [shield, hull, energy, targets.size()]
	else:
		judy_line = "I'm here, Hova. Move the aiming ring over a drone. Guns need energy; missiles need a target."
	comms_open = true

func _process(dt: float) -> void:
	if not started or paused or hull <= 0:
		return
	elapsed += dt
	damage_age += dt
	for i in 3: repair_cd[i] = maxf(0, repair_cd[i] - dt)
	if damage_age > 4: shield = minf(100, shield + 3 * dt)
	if elapsed > 9 and not incoming_sent:
		incoming_sent = true
		caller = "LT. JUDY"
		message = "Incoming call from Judy. Tap ANSWER."
	if not engine_off: warp_charge = -1
	if warp_charge >= 0:
		if flight.length() > 0.05 or thrusting or speed > 0.2:
			warp_charge = -1
			message = "Warp interrupted by movement."
		else:
			warp_charge += dt
			if warp_charge >= 5:
				energy -= 25
				warp_charge = -1
				sector += 1
				ship.position += Vector3(0, 0, -800)
				message = "Warp complete. Training sector %d." % sector
	cooldown = maxf(0, cooldown-dt)
	missile_cd = maxf(0, missile_cd-dt)
	mine_cd = maxf(0, mine_cd-dt)
	var steer := flight
	if Input.is_physical_key_pressed(KEY_A): steer.x -= 1
	if Input.is_physical_key_pressed(KEY_D): steer.x += 1
	if Input.is_physical_key_pressed(KEY_W): steer.y -= 1
	if Input.is_physical_key_pressed(KEY_S): steer.y += 1
	ship.rotate_y(-steer.x * dt * 0.8)
	pitch = clampf(pitch-steer.y*dt*0.6, -1.2, 1.2)
	ship.rotation.x = pitch
	var desired_speed := 0.0 if engine_off else 9.0
	if thrusting and energy > 5 and not engine_off:
		desired_speed = 55
		energy = maxf(0, energy - 14 * dt)
	speed = move_toward(speed, desired_speed, 35 * dt)
	var movement := -ship.global_basis.z * speed * dt
	ship.position += movement
	distance_flown += movement.length()
	energy = minf(100, energy+4*dt)
	for i in 3:
		if auto_modes[i] and [shield, hull, energy][i] <= 55: regenerate(i)
	if holding_fire or Input.is_physical_key_pressed(KEY_SPACE) or (auto_modes[3] and target_under_aim() != null): shot()
	if auto_modes[4] and target_under_aim() != null: shot(1)
	if auto_modes[5]:
		for target in targets:
			if target.position.distance_to(ship.position) < 24:
				shot(2)
				break
	for target in targets:
		var origin: Vector3 = target.get_meta("origin")
		target.position = origin + Vector3(sin(elapsed*0.35+origin.x)*5, cos(elapsed*0.25)*2, 0)
	for i in range(mines.size()-1, -1, -1):
		mines[i].ttl -= dt
		var detonate := false
		for target in targets.duplicate():
			if target.position.distance_to(mines[i].node.position) < 24:
				hit(target, 4)
				detonate = true
		if detonate or mines[i].ttl <= 0:
			mines[i].node.queue_free()
			mines.remove_at(i)
	incoming_cd -= dt
	if incoming_cd <= 0 and not targets.is_empty():
		incoming_cd = 5
		var near := false
		for target in targets:
			if target.position.distance_to(ship.position) < 150: near = true
		if near:
			damage_age = 0
			var damage := 8.0
			var absorbed := minf(shield, damage)
			shield -= absorbed
			hull = maxf(0, hull-(damage-absorbed))
			hud.damage_flash = 0.25
			if hull <= 0:
				message = "Training ended. Restart to try again."

func self_test() -> void:
	started = true
	hud.game = self
	# Lock a drone to the camera axis for deterministic targeting checks.
	targets[0].position = Vector3(0, 0, -85)
	hud.aim_offset = Vector2.ZERO
	assert(target_under_aim() == targets[0], "Crosshair target acquisition")
	assert(shot(), "Primary shot")
	assert(targets[0].get_meta("hp") == 3, "Weapon damage")
	assert(not shot(), "Cooldown enforced")
	assert(shot(1), "Missile fire")
	assert(missiles == 5 and kills == 1, "Finite missile / kill")
	assert(shot(2) and mine_stock == 2, "Mine deployment")
	shield = 40
	energy = 80
	regenerate(0)
	assert(shield == 75 and energy == 80 and repair_stock[0] == 4, "Finite shield repair")
	regenerate(0)
	assert(repair_stock[0] == 4, "Repair cooldown")
	command("link")
	assert(not linked, "Link blocked during threat")
	var before := ship.position
	flight = Vector2(0.5, 0)
	_process(0.1)
	assert(ship.position.distance_to(before) > 0.1, "Flight movement")
	toggle_engine()
	_process(0.5)
	assert(speed == 0, "Engine cut stops training ship")
	flight = Vector2.ZERO
	warp()
	assert(warp_charge == 0, "Stationary warp starts")
	flight = Vector2.ONE
	_process(0.1)
	assert(warp_charge == -1, "Movement cancels warp")
	flight = Vector2.ZERO
	warp()
	_process(5.1)
	assert(sector == 2, "Charged warp completes")
	track_next()
	assert(tracked != null, "Track target")
	call_contact("LT. JUDY")
	assert(comms_open and caller == "", "Answer call")
	end_call()
	assert(not comms_open and call_log.size() == 2, "End call / log")
	print("UNITY CADET: combat, finite repairs, warp, tracking and call checks passed")
	get_tree().quit()
