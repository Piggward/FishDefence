extends Node

var hover_tile: Tile
var moving_object: PlacedObject = null

var state: State = State.IDLE
var cd = false;

var tile_grid: TileGrid
enum State { IDLE, MOVING, PLACING }

signal pick_up(object: PlacedObject)
signal start_placing
signal stop_placing

func reset():
	tile_grid = TileGrid.new()
	hover_tile = null
	moving_object = null
	cd = false
	state = State.IDLE
	
func mouse_entered_tile(tile: Tile):
	hover_tile = tile
	if (state == State.MOVING or state == State.PLACING) and moving_object != null and not tile.has_object(moving_object):
		moving_object.global_position = tile.global_position + tile.size / 2
		
func try_pickup():
	if not tile_grid.can_pickup(hover_tile):
		return 
	
	tile_grid.show_tiles(true)
	moving_object = hover_tile.object
	pick_up.emit(hover_tile.object)
	change_state(State.MOVING)
	
func rotate():
	moving_object.rotate_object()
	
func try_place():
	for area in moving_object.get_overlapping_bodies():
		if area is Enemy:
			EventManager.error.emit()
			return
			
	var start_time := Time.get_ticks_usec()  # Start stopwatch
	if not tile_grid.can_place(hover_tile):
		EventManager.error.emit()
		return
	
	if state == State.PLACING and not GameManager.transaction_requested(moving_object.object):
		return
	
	tile_grid.show_tiles(false)
	tile_grid.place(moving_object, hover_tile)
	moving_object = null
	if state == State.MOVING:
		change_state(State.IDLE)
	var end_time := Time.get_ticks_usec()    # End stopwatch
	var elapsed := end_time - start_time     # Microseconds
	#print("try_place took %s microseconds" % elapsed)
		
		
func end_placing():
	tile_grid.show_tiles(false)
	if is_instance_valid(moving_object):
		moving_object.queue_free()
		moving_object = null
	change_state(State.IDLE)
	stop_placing.emit()
	
func add_object(o: PlacedObject):
	tile_grid.show_tiles(true)
	moving_object = o
	change_state(State.PLACING)
	moving_object.global_position = hover_tile.global_position + hover_tile.size / 2
	
func change_state(to: State):
	if to == self.state:
		return
	self.state = to;
	if to == State.PLACING:
		start_placing.emit(moving_object.object)
			
#func can_place(tile: Vector2i):
	#if not tile_inside_area(placeable_tiles.map_to_local(tile)):
		#return false
	#var place: bool = true;
	#for a in moving_object.get_overlapping_areas():
		#if a is PlacedObject or a.name == "EnemyArea":
			#return false
	##TODO: Check if blocking path	
	##TODO: Check if blocked by other tower	
	##if moving_object.get_overlapping_areas().size() > 0:
		##return false;
		#
	#return place;
