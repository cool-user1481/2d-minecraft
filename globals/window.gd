extends Node


func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
