class_name PathIndicator
extends Line2D

@export var tile_grid: TileGrid

func _ready():
	tile_grid.path_updated.connect(_on_path_updated)
	_on_path_updated()

func _on_path_updated():
	self.points = tile_grid.get_start_to_finish()
