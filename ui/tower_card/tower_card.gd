class_name TowerCard
extends Control
## Hover card for shop items: name, stats and a live demo of the tower. One card lives in
## the HUD and is reused for every item.

@onready var tower_name = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var icon_container = %IconContainer
@onready var icon: TextureRect = %Icon
@onready var preview: ScenePreview = %ScenePreview


func _ready():
	hide()
	EventManager.shop_item_hovered.connect(func(item: ShopItem): show_tower(item.stats, item.fish_texture.texture, item.demo_scene))
	EventManager.shop_item_unhovered.connect(hide_tower)
	# The card sits between the shop and the map; it must never take mouse hover
	# from the shop item or the tiles underneath.
	mouse_filter = MOUSE_FILTER_IGNORE
	for c in find_children("*", "Control", true, false):
		c.mouse_filter = MOUSE_FILTER_IGNORE


func show_tower(stats: TowerStats, fish_texture: Texture, demo_scene: PackedScene):
	tower_name.text = stats.fish_name
	description_label.text = stats.get_card_text()
	icon.texture = fish_texture
	icon_container.visible = demo_scene == null
	preview.visible = demo_scene != null
	if demo_scene:
		preview.show_scene(demo_scene)
	show()


func hide_tower():
	hide()
	preview.clear()
