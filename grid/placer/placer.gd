class_name Placer
extends Area2D
## Buys, places, picks up and moves towers on the TileGrid.
## Lives in a follow-viewport CanvasLayer above the shop, so a tower carried over the shop
## draws on top of it while its position stays in world coordinates.

enum State { IDLE, MOVING, PLACING }

const PLACED_OBJECT = preload("uid://c4cx30cjibsx")

var state := State.IDLE
var hover_tile: Tile
var moving_object: PlacedObject = null
var placing_scene: PackedScene
@export var tile_grid: TileGrid
## Placed towers are moved here from the placer's layer.
@export var towers_container: Node2D
var shop_open := false
var cd = false


func _ready():
	EventManager.shop_item_clicked.connect(_on_shop_item_clicked)
	EventManager.shop_opened.connect(func(open): shop_open = open)
	tile_grid.tile_hovered.connect(mouse_entered_tile)
	if not tile_grid.is_node_ready():
		await tile_grid.ready
	hover_tile = tile_grid.goal_tile


func _on_shop_item_clicked(item: ShopItem):
	# The shop keeps processing on the game over screen; the placer doesn't.
	if not can_process() or state != State.IDLE or cd:
		return
	if not GameManager.can_buy(item.cost):
		EventManager.error.emit()
		return
	input_cd()
	_spawn_ghost(item.tower_scene)


func _process(_delta):
	if state != State.IDLE and shop_open:
		global_position = get_global_mouse_position()
		for child in get_children():
			child.position = Vector2.ZERO
	match state:
		State.IDLE:
			handle_idle()
		State.MOVING:
			handle_moving()
		State.PLACING:
			handle_placing()


func input_cd():
	cd = true
	await get_tree().create_timer(0.1).timeout
	cd = false


func _left_click() -> bool:
	return (Input.is_action_just_pressed("left_click") or Input.is_action_just_released("left_click")) and not cd


func handle_idle():
	if Input.is_action_just_pressed("left_click") and hover_tile and hover_tile.object != null and not cd:
		input_cd()
		try_pickup()


func handle_moving():
	if _left_click():
		input_cd()
		try_place()
	if Input.is_action_just_pressed("r") and not cd:
		input_cd()
		moving_object.rotate_object()


func handle_placing():
	if _left_click():
		input_cd()
		var tower := moving_object.object
		var rotation_deg := tower.rotation_degrees
		if try_place():
			if GameManager.can_buy(tower.stats.get_cost()):
				_spawn_ghost(placing_scene, rotation_deg)
			else:
				end_placing()
	if Input.is_action_just_released("right_click"):
		input_cd()
		end_placing()
	if Input.is_action_just_pressed("r") and not cd and moving_object:
		input_cd()
		moving_object.rotate_object()


func mouse_entered_tile(tile: Tile):
	hover_tile = tile
	if state != State.IDLE and moving_object != null and not tile.has_object(moving_object):
		moving_object.global_position = tile.global_position + tile.size / 2


func try_pickup():
	if not tile_grid.can_pickup(hover_tile):
		return
	moving_object = hover_tile.object
	tile_grid.remove_object(moving_object)
	tile_grid.show_tiles(true)
	change_state(State.MOVING)


func try_place() -> bool:
	for body in moving_object.get_overlapping_bodies():
		if body is Enemy:
			EventManager.error.emit()
			return false
	var cost := moving_object.object.cost
	if state == State.PLACING and not GameManager.can_buy(cost):
		EventManager.error.emit()
		return false
	if not tile_grid.can_place(hover_tile):
		EventManager.error.emit()
		return false

	if state == State.PLACING:
		GameManager.spend(cost)
	if moving_object.get_parent() != towers_container:
		moving_object.reparent(towers_container)
	tile_grid.place(moving_object, hover_tile)
	tile_grid.show_tiles(false)
	moving_object = null
	if state == State.MOVING:
		change_state(State.IDLE)
	return true


func end_placing():
	tile_grid.show_tiles(false)
	if is_instance_valid(moving_object):
		moving_object.queue_free()
	moving_object = null
	change_state(State.IDLE)
	EventManager.placing_stopped.emit()


func _spawn_ghost(scene: PackedScene, rotation_deg := 0.0):
	var tower: Tower = scene.instantiate()
	var obj: PlacedObject = PLACED_OBJECT.instantiate()
	obj.object = tower
	obj.add_child(tower)
	add_child(obj)
	obj.set_object_rotation(rotation_deg)
	obj.global_position = hover_tile.global_position + hover_tile.size / 2
	moving_object = obj
	placing_scene = scene
	tile_grid.show_tiles(true)
	change_state(State.PLACING)


func change_state(to: State):
	if to == state:
		return
	state = to
	if to == State.PLACING:
		EventManager.placing_started.emit(moving_object.object)
