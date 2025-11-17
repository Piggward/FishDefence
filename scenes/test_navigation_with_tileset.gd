extends Node2D
@onready var tile_map_layer = $TileMapLayer
@onready var tile_grid = $TileGrid
@onready var placeable_tiles = $placeableTiles
@onready var ghost_placement = $Ghostplacement

@onready var path_2d = $Path2D
@onready var navigation_agent_2d = $CharacterBody2D/NavigationAgent2D


#func _process(delta):
	#var tile = (placeable_tiles.local_to_map(get_global_mouse_position()));
	#ghost_placement.global_position = placeable_tiles.map_to_local(tile)
	#if Input.is_action_pressed("left_click"):
		#var c = CRAB.instantiate()
		#c.global_position = ghost_placement.global_position
		#add_child(c)
	#
		
