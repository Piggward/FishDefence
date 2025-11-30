class_name Placer
extends Area2D

var cd = false
const PLACED_OBJECT = preload("uid://c4cx30cjibsx")
var shop: Shop
var canvasLayer: CanvasLayer

func _ready():
	EventManager.shop_item_clicked.connect(_on_shop_item_clicked)
	shop = get_tree().get_first_node_in_group("Shop")
	canvasLayer = get_tree().get_first_node_in_group("CanvasLayer")
	shop.open_updated.connect(_on_shop_change)
	
func _on_shop_change(v: bool):
	if not v:
		self.reparent(get_tree().root)
		print("reparent to root")
	else:
		self.reparent(canvasLayer)
		print("reparent to canvasLayer")
	
	
func _on_shop_item_clicked(item: ShopItem):
	if PlaceManager.state == PlaceManager.State.IDLE:
		if not cd:
			var tower = item.get_tower(item.tower_type)
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
	elif shop.open:
		self.global_position = get_global_mouse_position()
		for child in get_children():
			child.position = Vector2.ZERO
	if PlaceManager.state == PlaceManager.State.MOVING:
		handle_moving()
	elif PlaceManager.state == PlaceManager.State.PLACING:
		handle_placing()

func input_cd():
	cd = true
	await get_tree().create_timer(0.1).timeout
	cd = false

func handle_idle():
	#TODO: VIKTIGT! Har Stängt Av Plocka Upp
	if Input.is_action_just_pressed("left_click") and PlaceManager.hover_tile.object != null and not cd:
		input_cd()
		PlaceManager.try_pickup()
		
func handle_moving():
	if (Input.is_action_just_pressed("left_click") or Input.is_action_just_released("left_click")) and not cd:
		input_cd()
		PlaceManager.try_place()
	if Input.is_action_just_pressed("r") and not cd:
		input_cd()
		PlaceManager.rotate()
		
func handle_placing(): 
	if (Input.is_action_just_pressed("left_click") or Input.is_action_just_released("left_click")) and not cd:
		input_cd()
		var tower_copy = PlaceManager.moving_object.object.duplicate()
		PlaceManager.try_place()
		if PlaceManager.moving_object == null and GameManager.can_afford(tower_copy):
			tower_copy.is_copy = true
			var place = PLACED_OBJECT.instantiate()
			place.object = tower_copy
			place.add_child(tower_copy)
			PlaceManager.add_object(place)
			add_child(place)
		elif PlaceManager.moving_object == null and not GameManager.can_afford(tower_copy):
			PlaceManager.end_placing()
	if Input.is_action_just_released("right_click"):
		input_cd()
		PlaceManager.end_placing()
		
	if Input.is_action_just_pressed("r") and not cd:
		input_cd()
		PlaceManager.rotate()
		
