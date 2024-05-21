extends Node2D

var generator = TerrainGenerator.new(self)
var worldedit = WorldEdit.new(self)
var ticker = Tick.new(self)
var chunkscene = preload("res://core/chunk.tscn")
var chunkdat = {}
var world_path = "user://worlds/temp"
var ready = false
var updatedchunks = {}
export (Vector2) var render_dist = Vector2(3,2)
export var chunk_size = 2048
export (NodePath) var player_path
export (NodePath) var particle_path
export (NodePath) var hot_bar_path
onready var player = get_node(player_path)
onready var particle = get_node(particle_path)
onready var hot_bar = get_node(hot_bar_path)



func _process(_delta):
	var mouse_pos = Vector2(floor(get_global_mouse_position().x/128), floor(get_global_mouse_position().y/128))
	if not worldedit.active:
		if Input.is_action_pressed("mine"):
			if not getblock(mouse_pos) == 0:
				setblock(mouse_pos, 0, true)
		if Input.is_action_pressed("place"):
			if getblock(mouse_pos) == 0:
				if not getblock(mouse_pos) == hot_bar.block:
					setblock(mouse_pos, hot_bar.block)
	
	for i in get_children():
		i.on_screen = false
	
	if ready or get_parent().server:
		for x in range((player.position.x/chunk_size)-render_dist.x,(player.position.x/chunk_size)+render_dist.x, 1):
			for y in range((player.position.y/chunk_size)-render_dist.y,(player.position.y/chunk_size)+render_dist.y, 1):
				if get_node_or_null(str(Vector2(x, y))) == null:
					var new_chunk = chunkscene.instance()
					new_chunk.position.x = x * chunk_size
					new_chunk.position.y = y * chunk_size
					new_chunk.name = str(Vector2(x, y))
					new_chunk.coordinates = Vector2(x, y)
					add_child(new_chunk)
					if get_parent().server:
						getchunk(Vector2(x, y))
						new_chunk.display_chunk()
					else:
						rpc_id(1, "get_chunk_form_server", Vector2(x, y))
				get_node(str(Vector2(x, y))).on_screen = true
	
	for i in get_children():
		if not i.on_screen:
			if not get_parent().server:
				chunkdat.erase(i.coordinates)
			i.queue_free()
	if get_parent().server:
		for i in updatedchunks.keys():
			rpc("setchunk", i, chunkdat[i])
			if get_node_or_null(str(i)):
				get_node_or_null(str(i)).display_chunk()
		updatedchunks = {}

func getchunk(coordinates):
	if not coordinates in chunkdat:
		generator.genchunk(coordinates)
	return chunkdat[coordinates]

func _input(event):
	var mouse_pos = Vector2(floor(get_global_mouse_position().x/128), floor(get_global_mouse_position().y/128))
	worldedit.input(event, mouse_pos)

remote func get_chunk_form_server(coordinates):
	if get_parent().server:
		rpc_id(get_tree().get_rpc_sender_id(), "setchunk", coordinates, getchunk(coordinates))

remote func setchunk(coordinates, data):
	if get_tree().get_rpc_sender_id() == 1:
		if get_node_or_null(str(coordinates)):
			chunkdat[coordinates] = data
			get_node_or_null(str(coordinates)).display_chunk()

remote func setblock(pos, block, destroy=false):
	if get_parent().server:
		ticker.tickBlock(pos, 0)
		ticker.tickBlock(pos+Vector2.LEFT, 0)
		ticker.tickBlock(pos+Vector2.RIGHT, 0)
		ticker.tickBlock(pos+Vector2.UP, 0)
		ticker.tickBlock(pos+Vector2.DOWN, 0)
		if is_loaded(pos):
			if destroy and getblock(pos) != 0:
				var colors = ["000000","b5683c","b5683c","9c5a34","00b637","9c5a34","ff0000","949494","00aeff", "ffeeac", "ff0000", "949494"]
				particle.particle((pos*128)+Vector2(64,64), colors[getblock(pos)])
			var chunk = Vector2(floor(pos.x/16), floor(pos.y/16))
			pos = Vector2(int(pos.x) % 16, int(pos.y) % 16)
			chunkdat[chunk][pos.x][pos.y] = block
			updatedchunks[chunk] = true
		else:
			generator.queued_blocks[pos] = block
	else:
		rpc_id(1, "setblock", pos, block, destroy)

func getblock(pos):
	if is_loaded(pos):
		var chunk = Vector2(floor(pos.x/16), floor(pos.y/16))
		pos = Vector2(int(pos.x) % 16, int(pos.y) % 16)
		return chunkdat[chunk][pos.x][pos.y]
	elif pos in generator.queued_blocks:
		return generator.queued_blocks[pos]
	else:
		return 0

func is_loaded(pos):
	var chunk = Vector2(floor(pos.x/16), floor(pos.y/16))
	return chunk in chunkdat

func save():
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir_recursive(world_path)
	var file = File.new()
	file.open(world_path+"/world.dat", File.WRITE)
	file.store_var(chunkdat)
	file.close()


func load_world():
	var file = File.new()
	if file.file_exists(world_path+"/world.dat"):
		file.open(world_path+"/world.dat", File.READ)
		chunkdat = file.get_var()
		for  i in get_children():
			i.queue_free()


func tick():
	if get_parent().server:
		ticker.tick()
