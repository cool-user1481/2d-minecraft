extends Node2D


export var server = false
export var ip = "localhost"
export var port = 27015
export var max_players = 5

var network_unique_id = 0

onready var other_players_scene = preload("res://multiplayer/other players.tscn")
onready var players = $players
onready var player = $player

func _ready():
	$CanvasLayer/Control/MenuButton.get_popup().connect("id_pressed",self,"teleport")
	if GlobalData.use_data:
		server = GlobalData.data["server"]
		if server:
			$chunks.world_path = GlobalData.data["world_path"]
			$chunks.load_world()
		else:
			ip = GlobalData.data["ip"]
	
	if server:
		create_server()
	else:
		create_client()


func create_server():
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	network_unique_id = 1
	
	var network = NetworkedMultiplayerENet.new()
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)

func create_client():
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	# Set up an ENet instance
	var network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

func create_player(id):
	var new_player = other_players_scene.instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	players.add_child(new_player)
	$CanvasLayer/Control/MenuButton.get_popup().add_item(str(id),id)

func remove_player(id):
	players.get_node(str(id)).free()
	$CanvasLayer/Control/MenuButton.get_popup().remove_item($CanvasLayer/Control/MenuButton.get_popup().get_item_index(id))

func _on_server_disconnected():
	#get_tree().quit()
	pass

func _on_peer_connected(id):
	# When other players connect a character and a child player controller are created
	create_player(id)

func _on_peer_disconnected(id):
	# Remove unused nodes when player disconnects
	remove_player(id)

func _on_connected_to_server():
	# Upon successful connection get the unique network ID
	# This ID is used to name the character node so the network can distinguish the characters
	network_unique_id = get_tree().get_network_unique_id()
	$chunks.ready = true


func _physics_process(_delta):
	rpc_unreliable("update_position", player.transform)

remote func update_position(position):
	players.get_node(str(get_tree().get_rpc_sender_id())).transform = position

func teleport(id):
	player.transform = players.get_node(str(id)).transform
