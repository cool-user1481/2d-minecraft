extends TileMap

var coordinates
var on_screen
var blocks = [Vector3(0, 0, -1), Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(2, 0, 0), Vector3(3, 0, 0),  Vector3(4, 0, 0), Vector3(6, 0, 0),  Vector3(5, 0, 0), Vector3(7, 0, 0), Vector3(1, 2, 0), Vector3(2, 2, 0), Vector3(3, 2, 0)]
onready var ChunkManager = get_parent()


func display_chunk():
	var chunk = ChunkManager.chunkdat[coordinates]
	for y in range(16):
		for x in range(16):
			if chunk[x][y] > len(blocks)-1:
				self.set_cell(x, y, 0, false, false, false, Vector2(0,2))
			else:
				self.set_cell(x, y, blocks[chunk[x][y]].z, false, false, false, Vector2(blocks[chunk[x][y]].x, blocks[chunk[x][y]].y))
