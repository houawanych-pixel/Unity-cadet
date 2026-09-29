extends Control
var game: Node3D
var font := ThemeDB.fallback_font
var aim_offset := Vector2.ZERO
var sticks := {}
var flash := 0.0
var damage_flash := 0.0
const CYAN = Color("67dcff")
const INK = Color("091b2d")
const WHITE = Color("e6eff5")
var portrait = preload("res://assets/Unity_Cadet_Judy_Portrait_v01.webp")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func reticle() -> Vector2:
	return Vector2(640, 310) + aim_offset

func panel(rect: Rect2, color := INK, edge := CYAN) -> void:
	draw_style_box(box(color, edge), rect)

func box(color: Color, edge: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.border_color = edge
	b.set_border_width_all(2)
	b.set_corner_radius_all(10)
	return b

func label(at: Vector2, text: String, size_px := 18, color := WHITE) -> void:
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func poly(points: Array, tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), tint)

func _process(dt: float) -> void:
	flash = maxf(0, flash-dt)
	damage_flash = maxf(0, damage_flash-dt)
	queue_redraw()

func _draw() -> void:
	# Flat cockpit frame, deliberately no hands, transparencies or heavy shader stack.
	poly([Vector2(0,450),Vector2(260,550),Vector2(470,576),Vector2(540,720),Vector2(0,720)],Color("bac9d3"))
	poly([Vector2(1280,450),Vector2(1020,550),Vector2(810,576),Vector2(740,720),Vector2(1280,720)],Color("bac9d3"))
	poly([Vector2(0,495),Vector2(265,585),Vector2(442,610),Vector2(477,720),Vector2(0,720)],Color("283d54"))
	poly([Vector2(1280,495),Vector2(1015,585),Vector2(838,610),Vector2(803,720),Vector2(1280,720)],Color("283d54"))
	for mirrored in [false,true]:
		var x := 1280.0 if mirrored else 0.0
		var sign_x := -1.0 if mirrored else 1.0
		draw_line(Vector2(x,140), Vector2(x+sign_x*175,505), Color("a3b9c9"), 20)
		draw_line(Vector2(x+sign_x*12,160),Vector2(x+sign_x*161,478),Color("efaf44"),5)
	panel(Rect2(456,8,368,93))
	label(Vector2(549,31),"UNITY CADET",21)
	var stats := [game.shield,game.hull,game.energy]
	var colors := [CYAN,Color("8df6ac"),Color("f3da6f")]
	for i in 3:
		label(Vector2(474+i*117,53),["SHIELD","HULL","ENERGY"][i],13,colors[i])
		label(Vector2(474+i*117,84),"%d%%" % stats[i],27,colors[i])
	var names := ["SHIELD %d/5" % game.repair_stock[0],"HULL %d/5" % game.repair_stock[1],"ENERGY %d/5" % game.repair_stock[2],"FIRE GUNS","MISSILE %02d" % game.missiles,"MINE %02d" % game.mine_stock]
	for i in 6:
		var x := 12 if i < 3 else 968
		var y := 12+(i%3)*60
		panel(Rect2(x,y,300,52))
		label(Vector2(x+12,y+33),names[i],18)
		panel(Rect2(x+179,y+7,111,38),Color("174967") if game.auto_modes[i] else INK)
		label(Vector2(x+188,y+32),"AUTO" if game.auto_modes[i] else "MANUAL",16)
	label(Vector2(18,205),"TRAINING / 3D PLACEHOLDER SHIPS",13,CYAN)
	label(Vector2(440,128),game.message,16)
	for target in game.targets:
		if not is_instance_valid(target): continue
		var p: Vector2 = game.camera.unproject_position(target.global_position)
		var behind: bool = game.camera.is_position_behind(target.global_position)
		var c := Color("ff7764")
		if behind or p.x < 55 or p.x > 1225 or p.y < 225 or p.y > 515:
			var v: Vector3 = game.camera.to_local(target.global_position)
			p = Vector2(1238 if v.x > 0 else 42, clampf(360-v.y,235,480))
			var direction := 1 if p.x > 640 else -1
			poly([p+Vector2(direction*15,0),p+Vector2(-direction*10,-12),p+Vector2(-direction*10,12)],c)
		else:
			draw_rect(Rect2(p-Vector2(23,18),Vector2(46,36)),c,false,2)
			label(p+Vector2(-27,37),"%dm" % game.ship.position.distance_to(target.position),13,c)
	var r := reticle()
	var locked: bool = game.target_under_aim() != null
	var rc := Color("ffda73") if locked else WHITE
	draw_arc(r,25,0,TAU,36,rc,2,true)
	for v in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		draw_line(r+v*17,r+v*36,rc,2)
	draw_circle(r,2,rc)
	if locked: label(r+Vector2(-24,-42),"LOCK",14,rc)
	if flash > 0:
		draw_line(Vector2(275,610),r,Color("9bf5ff"),4)
		draw_line(Vector2(1005,610),r,Color("9bf5ff"),4)
	for i in 2:
		var c := Vector2(135 if i == 0 else 1145,593)
		draw_circle(c,90,Color("0b263e"))
		draw_arc(c,88,0,TAU,64,CYAN,3,true)
		draw_arc(c,66,0,TAU,48,Color("32617a"),1,true)
		var delta: Vector2 = game.flight*50 if i == 0 else aim_offset/3.0
		draw_circle(c+delta,30,Color("8cc8f0"))
		draw_arc(c+delta,30,0,TAU,36,WHITE,2,true)
		label(c+Vector2(-27,72),"FLIGHT" if i == 0 else "AIM",15)
	for pair in [[Rect2(55,439,160,52),"WARP"],[Rect2(232,580,145,52),"TRACTOR"],[Rect2(1065,439,160,52),"ENGINE ON" if game.engine_off else "ENGINE KILL"],[Rect2(903,580,145,52),"THRUST"]]:
		panel(pair[0])
		label(pair[0].position + Vector2(12,32), pair[1], 16)
	panel(Rect2(565,184,150,42))
	label(Vector2(587,212),"TRACK NEXT",16)
	label(Vector2(550,157),"SPEED %02d   SECTOR %d" % [game.speed,game.sector],14,CYAN)
	if game.warp_charge >= 0:
		label(Vector2(507,252),"WARP CHARGING %.1f / 5" % game.warp_charge,20,CYAN)
	for pickup in game.salvage:
		if not game.camera.is_position_behind(pickup.position):
			var pp: Vector2 = game.camera.unproject_position(pickup.position)
			draw_rect(Rect2(pp-Vector2(12,12),Vector2(24,24)),Color("72f5cf"),false,2)
	if is_instance_valid(game.tracked) and not game.camera.is_position_behind(game.tracked.position):
		var tp: Vector2 = game.camera.unproject_position(game.tracked.position)
		label(tp+Vector2(-30,-32),"TRACKED",14,CYAN)
	if not game.comms_open:
		draw_circle(Vector2(640,598),70,INK)
		for radius in [24,46,68]: draw_arc(Vector2(640,598),radius,0,TAU,48,Color("377892"),1,true)
		draw_line(Vector2(570,598),Vector2(710,598),CYAN,1)
		draw_line(Vector2(640,530),Vector2(640,666),CYAN,1)
		for target in game.targets:
			var relative: Vector3 = game.ship.to_local(target.position)
			var p := Vector2(relative.x,relative.z)*0.35
			draw_circle(Vector2(640,598)+p.limit_length(65),4,Color("ff7764"))
		poly([Vector2(640,589),Vector2(633,605),Vector2(647,605)],WHITE)
		panel(Rect2(565,674,150,38))
		label(Vector2(599,699),"CALL / LOG",15)
	else:
		panel(Rect2(390,439,500,273))
		# Atlas region from approved concept, rendered as a still placeholder.
		if game.active_contact == "LT. JUDY":
			draw_texture_rect(portrait,Rect2(401,452,135,167),false)
		else:
			label(Vector2(413,520),"UNKNOWN",18,Color("ff7764"))
			label(Vector2(413,548),"SIGNAL",18,Color("ff7764"))
		label(Vector2(548,468),game.active_contact,20,CYAN)
		label(Vector2(548,491),"SCRIPTED TRAINING COMMS",12,Color("f3da6f"))
		var words: PackedStringArray = game.judy_line.split(" ")
		var line := ""
		var row := 0
		for word in words:
			if font.get_string_size(line+word,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x > 321:
				label(Vector2(548,522+row*24),line,18)
				row += 1
				line = ""
			line += word+" "
		label(Vector2(548,522+row*24),line,18)
		for i in 3:
			panel(Rect2(405+i*158,632,150,42))
			label(Vector2(415+i*158,659),["STATUS","LINK TEST","END CALL"][i],15)
		label(Vector2(548,696),"Still portrait • Voice/video later",12)
	if game.contacts_open:
		panel(Rect2(390,439,500,273))
		label(Vector2(414,472),"COMMS / CONTACTS",22,CYAN)
		for i in 2:
			panel(Rect2(405+i*240,490,225,46))
			label(Vector2(416+i*240,520),["CALL JUDY","HOSTILE TEST"][i],17)
		for i in game.call_log.size(): label(Vector2(414,565+i*24),game.call_log[i],15)
		panel(Rect2(720,660,150,40))
		label(Vector2(746,687),"CLOSE",16)
	if game.caller != "":
		panel(Rect2(417,355,446,68))
		label(Vector2(431,380),"INCOMING: " + game.caller,16,CYAN)
		label(Vector2(440,409),"ANSWER",18)
		label(Vector2(726,409),"DECLINE",18)
	panel(Rect2(18,687,93,27))
	label(Vector2(29,706),"PAUSE",13)
	label(Vector2(1130,709),"v0.2.0",12)
	if damage_flash > 0: draw_rect(Rect2(0,0,1280,720),Color(1,0.1,0.1,0.12))
	if not game.started or game.paused or game.hull <= 0 or game.kills == 3:
		if game.comms_open and game.kills == 3: return
		draw_rect(Rect2(0,0,1280,720),Color(0.01,0.025,0.07,0.86))
		panel(Rect2(350,185,580,335))
		label(Vector2(460,240),"UNITY CADET",38)
		label(Vector2(410,279),"ANIME COCKPIT • MOBILE TRAINING",19,CYAN)
		label(Vector2(403,322),"Two thumbs: fly and aim. Fingers: fire and recharge.",17)
		label(Vector2(403,352),"Clear three drones. Open COMMS to check with Judy.",17)
		label(Vector2(403,381),"Prototype ships / scripted dialogue / no live AI yet",15)
		panel(Rect2(470,416,340,67),Color("18506b"))
		var title := "RESUME" if game.paused else "START TRAINING"
		if game.hull <= 0 or game.kills == 3: title = "RESTART TRAINING"
		label(Vector2(514,458),title,23)

func touch_down(id: int, p: Vector2) -> void:
	if not game.started or game.paused or game.hull <= 0 or (game.kills == 3 and not game.comms_open):
		if Rect2(470,416,340,67).has_point(p):
			if game.hull <= 0 or game.kills == 3:
				get_tree().reload_current_scene()
			else:
				game.started = true
				game.paused = false
		return
	if game.caller != "" and Rect2(417,355,446,68).has_point(p):
		if p.x < 640: game.call_contact(game.caller)
		else:
			game.call_log.push_front("Declined: " + game.caller)
			game.caller = ""
		return
	if game.contacts_open and Rect2(390,439,500,273).has_point(p):
		if Rect2(405,490,225,46).has_point(p): game.call_contact("LT. JUDY")
		elif Rect2(645,490,225,46).has_point(p):
			game.caller = "HOSTILE TEST"
			game.contacts_open = false
		elif Rect2(720,660,150,40).has_point(p): game.contacts_open = false
		return
	if Rect2(55,439,160,52).has_point(p):
		game.warp()
		return
	if Rect2(1065,439,160,52).has_point(p):
		game.toggle_engine()
		return
	if Rect2(232,580,145,52).has_point(p):
		game.tractor()
		return
	if Rect2(903,580,145,52).has_point(p):
		game.thrusting = true
		sticks[id] = 3
		return
	if Rect2(565,184,150,42).has_point(p):
		game.track_next()
		return
	for i in 2:
		var center := Vector2(135 if i == 0 else 1145,593)
		if center.distance_to(p) < 105:
			sticks[id] = i
			touch_move(id,p)
			return
	for i in 6:
		var x := 12 if i < 3 else 968
		var y := 12+(i%3)*60
		if Rect2(x,y,300,52).has_point(p):
			if p.x > x+179:
				game.auto_modes[i] = not game.auto_modes[i]
			elif i < 3: game.regenerate(i)
			elif i == 3:
				game.holding_fire = true
				sticks[id] = 2
				game.shot()
			else: game.shot(i-3)
			return
	if Rect2(18,687,93,27).has_point(p):
		game.paused = true
		reset_inputs()
	elif not game.comms_open and Rect2(565,674,150,38).has_point(p):
		game.contacts_open = not game.contacts_open
	elif game.comms_open:
		if Rect2(405,632,150,42).has_point(p): game.command("status")
		elif Rect2(563,632,150,42).has_point(p): game.command("link")
		elif Rect2(721,632,150,42).has_point(p): game.end_call()

func touch_move(id: int, p: Vector2) -> void:
	if not sticks.has(id): return
	var kind: int = sticks[id]
	if kind == 0: game.flight = ((p-Vector2(135,593))/65).limit_length(1)
	if kind == 1: aim_offset = ((p-Vector2(1145,593))/65).limit_length(1)*170

func touch_up(id: int) -> void:
	if sticks.get(id,-1) == 0: game.flight = Vector2.ZERO
	if sticks.get(id,-1) == 2: game.holding_fire = false
	if sticks.get(id,-1) == 3: game.thrusting = false
	sticks.erase(id)

func reset_inputs() -> void:
	sticks.clear()
	game.thrusting = false
	game.flight = Vector2.ZERO
	game.holding_fire = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and game != null:
		reset_inputs()
		game.paused = true

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed: touch_down(event.index,event.position)
		else: touch_up(event.index)
	elif event is InputEventScreenDrag: touch_move(event.index,event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: touch_down(-1,event.position)
		else: touch_up(-1)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): touch_move(-1,event.position)
