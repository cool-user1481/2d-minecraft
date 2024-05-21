extends Resource

class_name Tick


var ChunkManager
var ticks = {}
var tickNumber = 0

func _init(Chunk_Manager):
	ChunkManager = Chunk_Manager

func tick():
	tickNumber += 1
	for i in ticks.keys():
		if ChunkManager.is_loaded(i):
			if ticks[i] < tickNumber:
				if ChunkManager.getblock(i) == 8:
					if ChunkManager.getblock(i+Vector2.DOWN)==0:
						ChunkManager.setblock(i+Vector2.DOWN,8)
						ChunkManager.setblock(i,0)
					elif hashcoord(tickNumber*256+i.x*64+i.y)%2==0:
						if ChunkManager.getblock(i+Vector2.RIGHT)==0:
							ChunkManager.setblock(i+Vector2.RIGHT,8)
							ChunkManager.setblock(i,0)
						elif ChunkManager.getblock(i+Vector2.LEFT )==0:
							ChunkManager.setblock(i+Vector2.LEFT ,8)
							ChunkManager.setblock(i,0)
					else:
						if ChunkManager.getblock(i+Vector2.LEFT )==0:
							ChunkManager.setblock(i+Vector2.LEFT ,8)
							ChunkManager.setblock(i,0)
						elif ChunkManager.getblock(i+Vector2.RIGHT)==0:
							ChunkManager.setblock(i+Vector2.RIGHT,8)
							ChunkManager.setblock(i,0)
				elif ChunkManager.getblock(i) == 9:
					if ChunkManager.getblock(i+Vector2.DOWN)==0:
						ChunkManager.setblock(i+Vector2.DOWN,9)
						ChunkManager.setblock(i,0)
					elif hashcoord(tickNumber*256+i.x*64+i.y)%2==0:
						if ChunkManager.getblock(i+Vector2(1,1))==0:
							ChunkManager.setblock(i+Vector2(1,1),9)
							ChunkManager.setblock(i,0)
						elif ChunkManager.getblock(i+Vector2(-1,1))==0:
							ChunkManager.setblock(i+Vector2(-1,1),9)
							ChunkManager.setblock(i,0)
					else:
						if ChunkManager.getblock(i+Vector2(-1,1))==0:
							ChunkManager.setblock(i+Vector2(-1,1),9)
							ChunkManager.setblock(i,0)
						elif ChunkManager.getblock(i+Vector2(1,1))==0:
							ChunkManager.setblock(i+Vector2(1,1),9)
							ChunkManager.setblock(i,0)
				elif ChunkManager.getblock(i) == 10:
					if ChunkManager.getblock(i+Vector2.DOWN)==0:
						ChunkManager.setblock(i+Vector2.DOWN,10)
						ChunkManager.setblock(i,0)
					else:
						var r = 3
						for x in range(i.x-r, i.x+r, 1):
							for y in range(i.y-r, i.y+r, 1):
								if (Vector2(x,y)-i).length()<r:
									ChunkManager.setblock(Vector2(x, y), 0)
				elif ChunkManager.getblock(i) == 11:
					var blocks = []
					var j = 1
					while ChunkManager.getblock(i+Vector2.UP*j)!=0:
						blocks.append(ChunkManager.getblock(i+Vector2.UP*j))
						j += 1
					for k in range(len(blocks)):
						ChunkManager.setblock(i+Vector2.UP*(k+2),blocks[k])
					ChunkManager.setblock(i+Vector2.UP,0)
				ticks.erase(i)

func tickBlock(pos, time):
	ticks[pos] = time + tickNumber

func hashcoord(x):
	x = int(x)
	x = ((x >> 16) ^ x) * 73244475
	x = ((x >> 16) ^ x) * 73244475
	x = (x >> 16) ^ x;
	return x;
