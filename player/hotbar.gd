extends TextureRect

var image = [Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(3,0), Vector2(4,0), Vector2(6, 0), Vector2(5,0), Vector2(7,0), Vector2(1,2), Vector2(2,2), Vector2(3,2)]
var blocks = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
var selected_block = 0
var block = 1
var block_count = 11

func _input(_event):
	if Input.is_action_pressed("scroll_up"):
		selected_block += 1
		block = blocks[selected_block % block_count]
		texture.region = Rect2(image[selected_block % block_count] * 16, Vector2(16, 16))
	if Input.is_action_pressed("scroll_down"):
		selected_block -= 1
		block = blocks[selected_block % block_count]
		texture.region = Rect2(image[selected_block % block_count] * 16, Vector2(16, 16))
