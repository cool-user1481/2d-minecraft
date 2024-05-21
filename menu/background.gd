tool
extends TileMap

var blocks = [Vector3(0, 0, -1), Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(2, 0, 0), Vector3(3, 0, 0),  Vector3(4, 0, 0), Vector3(6, 0, 0),  Vector3(5, 0, 0)]

func _ready():
	var file = File.new()
	file.open("res://menu/background.json",File.READ)
	var structure = parse_json(file.get_as_text())
	for k in structure.keys():
		var s = k.strip_edges().split(",")
		set_cellv(Vector2(s[0].substr(1, -1),s[1]),blocks[structure[k]].z, false, false, false, Vector2(blocks[structure[k]].x, blocks[structure[k]].y))

