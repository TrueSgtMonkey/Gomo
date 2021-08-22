extends KinematicBody

const Box = preload("res://Objects/Physics/Box.tscn")

export (float) var speed = 9.0
export (float) var jumpSpeed= 12.0
export (float) var sprintMult = 2.0
export (float) var mouseSensitivity = 0.007
export (float) var maxVertClampDown = -1.5
export (float) var maxVertClampUp = 1.5

var moveVec := Vector3()
var velocity := Vector3()

var gravity := 30
var gravityEnabled := true
var gravButtonHeld := false
var jumpButtonHeld := false
var objectMenuHeld := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	moveVec = Vector3.ZERO
	if Input.is_action_pressed("FORWARD"):
		moveVec -= $Pivot/Camera.global_transform.basis.z
	if Input.is_action_pressed("BACKWARD"):
		moveVec += $Pivot/Camera.global_transform.basis.z
	if Input.is_action_pressed("LEFT"):
		moveVec -= $Pivot/Camera.global_transform.basis.x
	if Input.is_action_pressed("RIGHT"):
		moveVec += $Pivot/Camera.global_transform.basis.x
	
	if Input.is_action_pressed("SPRINT"):
		moveVec = moveVec.normalized() * speed * sprintMult
	else:
		moveVec = moveVec.normalized() * speed
	
	if gravityEnabled:
		velocity.x = moveVec.x
		velocity.z = moveVec.z
		if is_on_floor():
			if Input.is_action_pressed("JUMP") && !jumpButtonHeld:
				velocity.y = jumpSpeed
				jumpButtonHeld = true
			elif !Input.is_action_pressed("JUMP") && jumpButtonHeld:
				velocity.y = 0
				jumpButtonHeld = false
		else:
			velocity.y -= gravity * delta
	else:
		velocity = moveVec * 2.0
		if Input.is_action_pressed("JUMP"):
			velocity += $Pivot/Camera.global_transform.basis.y * speed
		
	move_and_slide(velocity, Vector3.UP, false)

#butt
func _input(event):
	if event.is_action_pressed("GRAV") && !gravButtonHeld:
		$CollisionShape.disabled = gravityEnabled
		gravityEnabled = !gravityEnabled
		gravButtonHeld = true
	elif !event.is_action_pressed("GRAV") && gravButtonHeld:
		gravButtonHeld = false
		
	if event.is_action_pressed("OBJECT_MENU") && !objectMenuHeld:
		objectMenuHeld = true
		spawnObject()
	elif !event.is_action_pressed("OBJECT_MENU") && objectMenuHeld:
		objectMenuHeld = false
		
#probably better to preload all of the objects in a singleton and pull from there
func spawnObject():
	var object = Box.instance()
	get_parent().add_child(object)
	object.global_transform.origin = global_transform.origin - $Pivot/Camera.global_transform.basis.z
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Pivot/Camera.rotate_x(-event.relative.y * mouseSensitivity)
		$Pivot/Camera.rotation.x = clamp($Pivot/Camera.rotation.x, maxVertClampDown, maxVertClampUp)
		$Pivot.rotate_y(-event.relative.x * mouseSensitivity)
