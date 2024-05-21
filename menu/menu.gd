extends Node2D

onready var animation = $AnimationPlayer

func _on_multiplayer_pressed():
	animation.play("multiplayer")


func _on_cancel_multiplayer_pressed():
	animation.play("multiplayer_cancel")


func _on_quit_pressed():
	get_tree().quit()


func _on_singleplayer_pressed():
	animation.play("singleplayer")


func _on_cancel_singleplayer_pressed():
	animation.play("singleplayer_cancel")


func _on_openworld(index):
	GlobalData.data = {
		"server": true,
		"world_path": "user://worlds/" + $singleplayer/Control/ColorRect/ItemList.get_item_text(index)
	}
	GlobalData.use_data = true
	var _err = get_tree().change_scene("res://core/main.tscn")


func _on_join_pressed():
	GlobalData.data = {
		"server": false,
		"ip": $multiplayer/Control/Control/LineEdit.text
	}
	GlobalData.use_data = true
	var _err = get_tree().change_scene("res://core/main.tscn")


func _input(_event):
	if Input.is_action_just_pressed("enter"):
		_on_join_pressed()


func _ready():
	var dir = Directory.new()
	if dir.open("user://worlds") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != '.' and file_name != '..':
					$singleplayer/Control/ColorRect/ItemList.add_item(file_name)
			file_name = dir.get_next()
	
	var file = File.new()
	if file.file_exists("user://server.txt"):
		file.open("user://server.txt", File.READ)
		$multiplayer/Control/Control/LineEdit.text = file.get_line()
		file.close()


func _on_new_world_pressed():
	animation.play("create_world")


func _on_cancel_new_world_pressed():
	animation.play("cancel_create_world")


func _on_tutorial_pressed():
	animation.play("tutorial")


func _on_cancel_tutorial_pressed():
	animation.play("tutorial_cancel")


func _on_create_pressed():
	GlobalData.data = {
		"server": true,
		"world_path": "user://worlds/"+$new_world/Control/Panel/name/LineEdit.text
	}
	GlobalData.use_data = true
	var _err = get_tree().change_scene("res://core/main.tscn")


func _on_LineEdit_text_changed(new_text):
	var file = File.new()
	file.open("user://server.txt", File.WRITE)
	file.store_line(new_text)
	file.close()
