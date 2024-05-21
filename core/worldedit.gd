extends Resource


class_name WorldEdit

var coords = [Vector2(),Vector2(),Vector2()]
var ChunkManager
var active = false

func _init(Chunk_Manager):
	ChunkManager = Chunk_Manager

func setpoint(point, pos):
	coords[point] = pos

func input(event, mouse_pos):
	if Input.is_action_just_pressed("worldedit_toggle"):
		active = not active
	if active:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				setpoint(0, mouse_pos)
			if event.button_index == BUTTON_RIGHT:
				setpoint(1, mouse_pos)
			if event.button_index == BUTTON_MIDDLE:
				setpoint(2, mouse_pos)
		
		if Input.is_action_just_pressed("worldedit_place"):
			fill(ChunkManager.hot_bar.block)

func fill(block):
	var p0 = Vector2(min(coords[0].x, coords[1].x), min(coords[0].y, coords[1].y))
	var p1 = Vector2(max(coords[0].x, coords[1].x), max(coords[0].y, coords[1].y))
	for x in range(p0.x, p1.x+1, 1):
		for y in range(p0.y, p1.y+1, 1):
			ChunkManager.setblock(Vector2(x, y), block)

func line(block):
	var p0 = coords[0]
	var p1 = coords[1]
	
	var steep = abs(p0.y - p1.y) > abs(p0.x - p1.x)
	
	if steep:
		p0 = Vector2(p0.y, p0.x)
		p1 = Vector2(p1.y, p1.x)
	
	if p0.x > p1.x:
		var p2 = p0
		p0 = p1
		p1 = p2
	
	var dx = p1.x - p0.x
	var dy = abs(p1.y - p0.y)
	
	var err = dx/2
	var ystep
	
	if p0.y < p1.y:
		ystep = 1
	else:
		ystep = -1
	
	while p0.x <= p1.x:
		if steep:
			ChunkManager.setblock(Vector2(p0.y, p0.x), block)
		else:
			ChunkManager.setblock(p0, block)
		
		err -= dy
		
		if err < 0:
			p0.y += ystep
			err += dx
		
		p0.x += 1

func circle(block):
	var r = (coords[0]-coords[1]).length()
	var p0 = coords[0]
	for x in range(p0.x-r, p0.x+r, 1):
		for y in range(p0.y-r, p0.y+r, 1):
			if (Vector2(x,y)-p0).length()<r:
				ChunkManager.setblock(Vector2(x, y), block)

func save(_block):
	var blocks = {}
	
	var p0 = Vector2(min(coords[0].x, coords[1].x), min(coords[0].y, coords[1].y))
	var p1 = Vector2(max(coords[0].x, coords[1].x), max(coords[0].y, coords[1].y))
	for x in range(p0.x, p1.x+1, 1):
		for y in range(p0.y, p1.y+1, 1):
			if not ChunkManager.getblock(Vector2(x,y)) == 6:
				blocks[Vector2(x,y)-coords[2]] = ChunkManager.getblock(Vector2(x,y))
	
	var file = File.new()
	file.open("res://structures/thing.json", File.WRITE)
	file.store_line(to_json(blocks))
	file.close()
