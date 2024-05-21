extends Node2D


export (PackedScene) var particles

remote func sv_particle(pos, color):
	if get_parent().server:
		rpc("cl_particle", pos, color)
		cl_particle(pos, color)

remote func cl_particle(pos, color):
	if get_tree().get_rpc_sender_id() == 1 or get_parent().server:
		var scene = particles.instance()
		scene.position = pos
		scene.process_material = scene.process_material.duplicate()
		scene.process_material.color = color
		add_child(scene)
		scene.emitting = true

func particle(pos, color):
	if get_parent().server:
		sv_particle(pos, color)
	else:
		rpc_id(1, "sv_particle", pos, color)


func _process(_delta):
	for i in get_children():
		if not i.emitting:
			i.queue_free()
