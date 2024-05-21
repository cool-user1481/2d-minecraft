extends Camera2D

var zoomed = false

func _physics_process(_delta):
	var target_zoom
	
	if Input.is_action_just_pressed("zoom"):
		zoomed = !zoomed

	if zoomed:
		target_zoom = 4
	else:
		target_zoom = 2
	var current_zoom = ((zoom.x - target_zoom) * 0.8) + target_zoom
	zoom = Vector2(current_zoom, current_zoom)
