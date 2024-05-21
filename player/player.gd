extends KinematicBody2D

export var walk_speed = 100
export var run_speed = 200
export var friction = 0.85
export var gravity = 100
export var jump_power = 1387
export var mid_air_jump = false
export var down_jump = false

var velocity = Vector2()
var speed

func _physics_process(_delta):
	if Input.is_action_pressed("sprint"):
		speed = run_speed
	else:
		speed = walk_speed
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	velocity.x *= friction
	
	velocity.y += gravity
	if is_on_floor() or mid_air_jump:
		
		if Input.is_action_pressed("ui_up"):
			velocity.y = -jump_power
		if Input.is_action_pressed("ui_down") and down_jump:
			velocity.y = jump_power
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
