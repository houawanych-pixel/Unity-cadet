extends Node3D
## First scene: placeholder geometry and camera/comms UI only.
## No live AI, speech, or flight integration yet.

var cockpit_camera: Camera3D
var chase_camera: Camera3D
var comms: PanelContainer
var status_label: Label

func block(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	instance.material_override = material
	parent.add_child(instance)
	instance.position = position

func _ready() -> void:
	var ship := Node3D.new()
	ship.name = "Ship"
	add_child(ship)
	var visuals := Node3D.new()
	visuals.name = "ReplaceableVisuals"
	ship.add_child(visuals)
	block(visuals, Vector3(0, -0.7, 0), Vector3(2.8, 0.3, 5), Color(0.16, 0.22, 0.3))
	block(visuals, Vector3(-1.3, 0, -0.5), Vector3(0.2, 1.4, 4), Color(0.2, 0.3, 0.4))
	block(visuals, Vector3(1.3, 0, -0.5), Vector3(0.2, 1.4, 4), Color(0.2, 0.3, 0.4))
	block(visuals, Vector3(0, -0.1, -1.8), Vector3(2.4, 0.6, 0.6), Color(0.1, 0.45, 0.5))
	block(visuals, Vector3(-2.2, -0.5, 0.8), Vector3(2, 0.15, 2.2), Color(0.2, 0.4, 0.55))
	block(visuals, Vector3(2.2, -0.5, 0.8), Vector3(2, 0.15, 2.2), Color(0.2, 0.4, 0.55))
	var docking := Marker3D.new()
	docking.name = "DockingAnchor"
	ship.add_child(docking)
	docking.position = Vector3(0, -1.5, 0)
	cockpit_camera = Camera3D.new()
	ship.add_child(cockpit_camera)
	cockpit_camera.position = Vector3(0, 0.8, 0.7)
	cockpit_camera.current = true
	chase_camera = Camera3D.new()
	ship.add_child(chase_camera)
	chase_camera.position = Vector3(0, 4, 9)
	chase_camera.look_at(Vector3(0, 0, -2))
	var light := DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-40, -30, 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(100):
		var star := MeshInstance3D.new()
		var star_mesh := SphereMesh.new()
		star_mesh.radius = 0.08
		star_mesh.height = 0.16
		star_mesh.radial_segments = 4
		star_mesh.rings = 2
		star.mesh = star_mesh
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.7, 0.85, 1)
		star.material_override = mat
		add_child(star)
		star.position = Vector3(rng.randf_range(-60, 60), rng.randf_range(-30, 40), rng.randf_range(-100, -30))
	build_ui()

func build_ui() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var layout := VBoxContainer.new()
	hud.add_child(layout)
	layout.position = Vector2(20, 20)
	status_label = Label.new()
	status_label.text = "UNITY CADET | Scene prototype | AI and voice not connected"
	layout.add_child(status_label)
	var camera_button := Button.new()
	camera_button.text = "Switch cockpit / chase view"
	camera_button.custom_minimum_size = Vector2(280, 52)
	layout.add_child(camera_button)
	camera_button.pressed.connect(func():
		if cockpit_camera.current:
			chase_camera.make_current()
		else:
			cockpit_camera.make_current()
	)
	var comms_button := Button.new()
	comms_button.text = "Open / close Judy comms"
	comms_button.custom_minimum_size = Vector2(280, 52)
	layout.add_child(comms_button)
	comms = PanelContainer.new()
	layout.add_child(comms)
	var content := VBoxContainer.new()
	comms.add_child(content)
	var title := Label.new()
	title.text = "LT. JUDY | Visual placeholder"
	content.add_child(title)
	var portrait := ColorRect.new()
	portrait.color = Color(0.08, 0.2, 0.25)
	portrait.custom_minimum_size = Vector2(180, 100)
	content.add_child(portrait)
	var note := Label.new()
	note.text = "Rigged upper-body portrait planned.\nNo generated dialogue in this scene."
	content.add_child(note)
	comms.hide()
	comms_button.pressed.connect(func(): comms.visible = not comms.visible)
