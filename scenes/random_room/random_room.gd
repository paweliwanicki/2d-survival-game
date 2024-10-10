extends Node
class_name RandomRoom;

const FLOOR_TILES_SOURCE_ID = 0
const WALL_TILES_SOURCE_ID = 0
const DOOR_TILES_SOURCE_ID = 0
const MISCELLANEOUS_SOURCE_ID = 0;

const CLOSED_DOOR_TILE = [9,3];
const OPEN_DOOR_TILE = [9,0];

const MIN_ROOM_SIZE = 45
const MAX_ROOM_SIZE = 60

const MAP_SIZE = 100;

const ROOM_OFFSET = 30;

const DOOR_TILES = {
	"SINGLE_CLOSE_DOOR": [9,3],
	"DOUBLE_CLOSE_DOOR": [[10,3],[11,3]],
}

const MISCELLANEOUS_TILES = {
	"OFF_FOUNTAIN":{
		"coords": [[7,0],[7,2]],
		"weight" : 3
	} ,
	"ON_FOUNTAIN":{
		"coords": [[8,0],[8,2]],
		"weight" : 3
	} ,
	"OFF_GARGOYLE_FOUNTAIN":{
		"coords": [[7,1],[7,2]],
		"weight" : 3
	} ,
	"ON_GARGOYLE_FOUNTAIN":{
		"coords": [[8,1],[8,2]],
		"weight" : 3
	},
}

const BACKGROUND_TILES = {
	"FILLED" : {
		"coords": [0,0],
		"weight": 30
	},	
	"MOODED" : {
		"coords": [0,1],
		"weight": 3
	},	
	"STONED" : {
		"coords": [0,2],
		"weight": 1
	},	
}

const FLOOR_TILES = {
	"FILLED" : {
		"coords": [0,4],
		"weight": 30
	},
	"SANDED" : 	{
		"coords": [1,4],
		"weight": 3
	},
	"STONED" : {
		"coords" : [6,3],
		"weight": 1
	},
}


const FLOOR_TILES_UNDER_WALL = {
	"UNDER_WALL_1": {
		"coords" : [2,4],
		"weight": 10
	},
	"UNDER_WALL_2": {
		"coords": [3,4],
		"weight": 5
	},
}

const WALL_TILE = {
	"TOP" :  [2,0],
	"LEFT" : [1,1],
	"TOP_LEFT_CORNER": [1, 0],
	"RIGHT" : [3,1],
	"TOP_RIGHT_CORNER": [3, 0],
	"BOTTOM": [2,2],
	"BOTTOM_LEFT_CORNER": [1, 2],
	"BOTTOM_RIGHT_CORNER": [3, 2],
	"WALL": [2,1]
}

const FLOOR_LAYER = 0;
const WALL_LAYER = 1;
const MISCELLANEOUS_LAYER = 2;
const PLAYER_LAYER = 3;

var floor_tiles_table = WeightedTable.new();
var background_tiles_table = WeightedTable.new();
var under_wall_tiles_table = WeightedTable.new();
var miscellaneous_tiles_table = WeightedTable.new();

@export var tileset: TileSet
@onready var tilemap = $TileMap

func _ready():

	add_tiles_to_weight_table(FLOOR_TILES, floor_tiles_table);
	add_tiles_to_weight_table(FLOOR_TILES_UNDER_WALL, under_wall_tiles_table);
	add_tiles_to_weight_table(BACKGROUND_TILES, background_tiles_table);
	add_tiles_to_weight_table(MISCELLANEOUS_TILES, miscellaneous_tiles_table);
	
	generate_background();
	var room = generate_room();
	create_miscellaneous_in_room(room)
	

func get_random_door_position(room_width: int, room_height: int) -> Vector2i:
	var positions = [
		Vector2i(randi_range(ROOM_OFFSET + 1, ROOM_OFFSET + room_width - 2), ROOM_OFFSET) * tilemap.rendering_quadrant_size, 
		Vector2i(randi_range(ROOM_OFFSET + 1, room_width - 2), ROOM_OFFSET + room_height - 1),
		Vector2i(ROOM_OFFSET, randi_range(1, ROOM_OFFSET + room_height - 2)),
		Vector2i(ROOM_OFFSET + room_width - 1, randi_range(ROOM_OFFSET + 1, ROOM_OFFSET +  room_height - 2))
	]
	print(positions, "positions");

	return positions[randi_range(0, positions.size() - 1)]


func on_door_area_entered(body: Node2D):
	print("Transition to another scene")
	# get_tree().change_scene("res://path_to_next_scene.tscn")
	
	
func add_tiles_to_weight_table(tiles: Dictionary, table: WeightedTable):
	for tile in tiles:
		var tile_details = tiles[tile];
		table.add_item(tile_details["coords"], tile_details["weight"]);
		

func generate_background():
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var background_tile = background_tiles_table.pick_item();
			tilemap.set_cell(FLOOR_LAYER, Vector2i(x, y), FLOOR_TILES_SOURCE_ID, Vector2i(background_tile[0], background_tile[1]));


func generate_room():
	var doors = [];
	var connections = [];
	var room_width = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE);
	var room_height = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE);
	
	for x in range(room_width):
		for y in range(room_height):
			var room_x = x + ROOM_OFFSET;
			var room_y = y + ROOM_OFFSET;
			var floor_tile = floor_tiles_table.pick_item();
			tilemap.set_cell(FLOOR_LAYER, Vector2i(room_x, room_y), FLOOR_TILES_SOURCE_ID, Vector2i(floor_tile[0], floor_tile[1]));
			
			# under wall floor tiles
			if y == 1 && x > 0 && x < room_width - 1:
				var under_wall_tile = under_wall_tiles_table.pick_item();
				tilemap.set_cell(FLOOR_LAYER, Vector2i(room_x, room_y), WALL_TILES_SOURCE_ID, Vector2i(under_wall_tile[0], under_wall_tile[1]));
				continue;
			
			# left wall
			if x == 0:
				tilemap.set_cell(WALL_LAYER, Vector2i(room_x, room_y), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["LEFT"][0], WALL_TILE["LEFT"][1]));
				continue;
			
			# right wall
			if x == room_width - 1:
				tilemap.set_cell(WALL_LAYER, Vector2i(room_x, room_y), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["RIGHT"][0], WALL_TILE["RIGHT"][1]));
				continue;	
				
			# top wall	
			if y == 0:
				tilemap.set_cell(WALL_LAYER, Vector2i(room_x, room_y - 1), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["TOP"][0], WALL_TILE["TOP"][1]));
				tilemap.set_cell(WALL_LAYER, Vector2i(room_x, room_y), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["WALL"][0], WALL_TILE["WALL"][1]));
				continue;	
			
			# bottom wall
			if y == room_height - 1:
				tilemap.set_cell(WALL_LAYER, Vector2i(room_x, room_y + 1), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["BOTTOM"][0], WALL_TILE["BOTTOM"][1]));
									

	# top left corner
	tilemap.set_cell(WALL_LAYER, Vector2i(ROOM_OFFSET, ROOM_OFFSET - 1), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["TOP_LEFT_CORNER"][0], WALL_TILE["TOP_LEFT_CORNER"][1]));
	# top right corner 
	tilemap.set_cell(WALL_LAYER, Vector2i(ROOM_OFFSET + room_width - 1, ROOM_OFFSET - 1), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["TOP_RIGHT_CORNER"][0], WALL_TILE["TOP_RIGHT_CORNER"][1])); 
	# bottom left corner
	tilemap.set_cell(WALL_LAYER, Vector2i(ROOM_OFFSET, ROOM_OFFSET + room_height), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["BOTTOM_LEFT_CORNER"][0], WALL_TILE["BOTTOM_LEFT_CORNER"][1])); 
	# bottom right corner
	tilemap.set_cell(WALL_LAYER, Vector2i(ROOM_OFFSET + room_width - 1, ROOM_OFFSET + room_height), WALL_TILES_SOURCE_ID, Vector2i(WALL_TILE["BOTTOM_RIGHT_CORNER"][0], WALL_TILE["BOTTOM_RIGHT_CORNER"][1])); 
	 	
	
	var top_door_position = Vector2i(ROOM_OFFSET + (room_width / 2), ROOM_OFFSET);
	tilemap.set_cell(WALL_LAYER, top_door_position, DOOR_TILES_SOURCE_ID, Vector2i(CLOSED_DOOR_TILE[0], CLOSED_DOOR_TILE[1]))	
	var bottom_door_position = Vector2i(ROOM_OFFSET + (room_width / 2), ROOM_OFFSET + room_height);
	tilemap.set_cell(WALL_LAYER, bottom_door_position, DOOR_TILES_SOURCE_ID, Vector2i(OPEN_DOOR_TILE[0], OPEN_DOOR_TILE[1]), TileSetAtlasSource.TRANSFORM_FLIP_V | 
TileSetAtlasSource.TRANSFORM_FLIP_H)

	create_door_area(bottom_door_position);
	
	var player_x = (ROOM_OFFSET + (room_width / 2)) * tilemap.rendering_quadrant_size;
	var player_y = (ROOM_OFFSET + (room_height - 1 )) * tilemap.rendering_quadrant_size;
	%Player.global_position = Vector2(ROOM_OFFSET + (room_width / 2) + .5, ROOM_OFFSET + room_height - 1) * tilemap.rendering_quadrant_size
	%Player.z_index = PLAYER_LAYER;
	
	return {
		"connections": connections,
		"doors" : [top_door_position, bottom_door_position],
		"width": room_width,
		"height" : room_height
	}


func create_door_area(position: Vector2i):
	var door_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(8, 8)
	collision_shape.shape = shape
	door_area.add_child(collision_shape)
	door_area.position = (position * tilemap.rendering_quadrant_size) + Vector2i.ONE * 8;
	door_area.collision_mask = 2 ;
	door_area.collision_layer = 0;
	door_area.body_entered.connect(on_door_area_entered)
	get_tree().get_first_node_in_group("entities_layer").add_child(door_area)


func create_miscellaneous_in_room(room):
	const MIN_MARGIN = 2
	var available_positions: Array = []
	
	# Wygenerowanie listy dostępnych pozycji na ścianie
	for x in range(ROOM_OFFSET + 1, room["width"] - 1):
		available_positions.append(x)
	
	var placed_positions: Array = []
	
	for i in randi_range(0,5):
		if available_positions.is_empty():
			break
		
		var index = randi_range(0, available_positions.size() - 1)
		var position = available_positions[index]
		
		if position == room["width"] / 2:
			position += MIN_MARGIN;
		
		placed_positions.append(position)
		available_positions.erase(index)
		
		for j in range(1, MIN_MARGIN + 1):
			available_positions.erase(position - j)
			available_positions.erase(position + j)
		
		var tile = miscellaneous_tiles_table.pick_item();
		
		tilemap.set_cell(MISCELLANEOUS_LAYER, Vector2i(position, ROOM_OFFSET), MISCELLANEOUS_SOURCE_ID, Vector2i(tile[0][0], tile[0][1]))
		tilemap.set_cell(MISCELLANEOUS_LAYER, Vector2i(position, ROOM_OFFSET + 1), MISCELLANEOUS_SOURCE_ID, Vector2i(tile[1][0], tile[1][1]))
