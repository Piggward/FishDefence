class_name Discus
extends Tower

var target_found = false
@onready var target_area = $TargetArea
var current_target_pos = 0
@onready var animation_player = $TargetArea/AnimationPlayer
@onready var aoe_area = $TargetArea/AoeArea
const SPLASH = preload("uid://iv1thjyw4q72")


func _ready():
	super()
	target_area.position = range_cells[0] * 16
	target_area.body_entered.connect(_on_target_area_entered)

func _on_target_area_entered(_enemy: Enemy):
	if target_found or not enabled:
		return
	target_found = true
	animation_player.play("target_found")
	var tween = get_tree().create_tween()
	play_attack_sound()
	tween.tween_property(sprite_2d, "position", Vector2(0, -600), 0.5 / attack_speed)
	tween.tween_property(sprite_2d, "position", target_area.position, 0.24 / attack_speed)
	#explode
	await tween.finished
	var spl = SPLASH.instantiate()
	spl.emitting = true
	if not is_instance_valid(projectile_container):
		return
	projectile_container.add_child(spl)
	spl.global_position = target_area.global_position
	
	for aoe_enemy: Enemy in aoe_area.get_overlapping_bodies():
		deal_damage(aoe_enemy)
	await get_tree().create_timer(0.3).timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(sprite_2d, "position", Vector2(0, 0), 0.4 / attack_speed)
	await tween2.finished
	target_found = false
	
func play_attack_sound(l = 0.8, h = 1.2, volume = 5.0):
	await get_tree().create_timer(0.5 / attack_speed / 2).timeout
	super(l,h, volume)

func _process(_delta):
	if not cd and enabled and not target_found:
		set_cd()
		next_target()
		
func next_target():
	var curr = current_target_pos
	current_target_pos = randi_range(0, range_cells.size()-1)
	if curr == current_target_pos:
		current_target_pos = wrapf(current_target_pos + 1, 0, range_cells.size())
	target_area.position = range_cells[current_target_pos] * 16
	sprite_2d.look_at(target_area.global_position)
	sprite_2d.rotation_degrees = wrapf(sprite_2d.rotation_degrees + 180, 0, 360)
	


	
