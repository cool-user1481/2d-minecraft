extends Resource

class_name TerrainGenerator

var noise = [null, null, null]
var structures = {}
var ChunkManager
var queued_blocks = {}

func _init(Chunk_Manager):
	noise[0] = OpenSimplexNoise.new()
	noise[1] = OpenSimplexNoise.new()
	noise[1].seed = 1
	noise[1].octaves = 1
	noise[1].period = 8
	noise[2] = OpenSimplexNoise.new()
	noise[2].period = 32
	ChunkManager = Chunk_Manager
	loadstructures()


func genchunk(coordinates):
	var a = []
	for x in range(16):
		a.append([])
		a[x].resize(16)
		for y in range(16):
			a[x][y] = 0
			var global = Vector2(x + coordinates.x * 16, y + coordinates.y * 16)
			var height = round((noise[0].get_noise_1d((global.x))+1) * 50)
			if height == global.y:
				if hashcoord(global.x)%10 == 0:
					place_structure("tree", global)
				else:
					a[x][y] = 1
			elif height <= global.y:
				if global.y - height < 6 + noise[1].get_noise_1d(global.x)*3:
					a[x][y] = 2
				else:
					a[x][y] = 7
			if global.y - height > 15:
				var d = noise[2].get_noise_2d(global.x, global.y)
				if d>-0.1 and d<0.1:
					a[x][y] = 0
			
	ChunkManager.chunkdat[coordinates] = a
	
	for i in queued_blocks.keys():
		var chunk = Vector2(floor(i.x/16), floor(i.y/16))
		if chunk in ChunkManager.chunkdat:
			ChunkManager.setblock(i,queued_blocks[i])
			queued_blocks.erase(i)

func place_structure(struct, pos):
	for i in structures[struct].keys():
		ChunkManager.setblock(pos+i, structures[struct][i])
	

func loadstructures():
	var file = File.new()
	file.open("res://structures/structures.json", File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	for i in data.keys():
		file.open(data[i],File.READ)
		var structure = parse_json(file.get_as_text())
		structures[i] = {}
		for k in structure.keys():
			var s = k.strip_edges().split(",")
			structures[i][Vector2(s[0].substr(1, -1),s[1])] = structure[k]

func hashcoord(x):
	x = int(x)
	x = ((x >> 16) ^ x) * 73244475
	x = ((x >> 16) ^ x) * 73244475
	x = (x >> 16) ^ x;
	return x;
