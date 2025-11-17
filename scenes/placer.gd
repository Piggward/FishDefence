class_name Placer
extends Area2D

var obstacle_polygon: PackedVector2Array
@onready var collision_polygon_2d = $PlacedObject/StaticBody2D/CollisionPolygon2D

var cd = false
const PLACED_OBJECT = preload("uid://c4cx30cjibsx")
var region: NavigationRegion2D
@onready var placeable_checker = $PlacedObject/PlaceableChecker
var tile_grid: Node2D

func _ready():
	#obstacle_polygon = collision_polygon_2d.polygon;
	region = get_tree().get_first_node_in_group("NavigationRegion")
	tile_grid = get_tree().get_first_node_in_group("TileGrid")
	EventManager.shop_item_clicked.connect(_on_shop_item_clicked)
	
func _on_shop_item_clicked(item: ShopItem):
	if PlaceManager.state == PlaceManager.State.IDLE:
		if not cd:
			var tower = item.tower.instantiate()
			if not GameManager.can_afford(tower):
				return
			input_cd()
			var obj: PlacedObject
			obj = PLACED_OBJECT.instantiate()
			obj.object = tower
			obj.add_child(tower)
			PlaceManager.add_object(obj)
			add_child(obj)
	
func _process(delta):
	if PlaceManager.state == PlaceManager.State.IDLE:
		handle_idle()
	elif PlaceManager.state == PlaceManager.State.MOVING:
		handle_moving()
	elif PlaceManager.state == PlaceManager.State.PLACING:
		handle_placing()

func input_cd():
	cd = true
	await get_tree().create_timer(0.1).timeout
	cd = false

func handle_idle():
	if Input.is_action_just_released("left_click") and PlaceManager.hover_tile.object != null and not cd:
		input_cd()
		PlaceManager.try_pickup()
		
	
func handle_moving():
	if Input.is_action_just_pressed("left_click") and not cd:
		input_cd()
		PlaceManager.try_place()
		
func handle_placing(): 
	if Input.is_action_pressed("left_click") and not cd:
		var copy = PlaceManager.moving_object.duplicate()
		PlaceManager.try_place()
		if PlaceManager.moving_object == null:
			#var obj: PlacedObject
			#obj = PLACED_OBJECT.instantiate()
			#obj.object = copy
			#obj.add_child(copy)
			PlaceManager.add_object(copy)
			add_child(copy)
	if Input.is_action_just_released("right_click"):
		input_cd()
		PlaceManager.end_placing()
