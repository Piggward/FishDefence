class_name TowerArena
extends TowerDemo
## Sandbox for trying towers against enemies: run this scene (F6). Enemies walk the lanes
## (EnemySpawner nodes) past the towers. Drag in other tower scenes, move or rotate the
## lanes and set their `wave` to try other enemies. Kills, leaks and damage per tower are
## shown top left. Not part of the game: tests/ is excluded from exports.

## Game speed while the arena runs, to get through slow waves faster.
@export_range(0.25, 8.0) var time_scale := 1.0
@onready var stats_label: Label = %StatsLabel
var kills := 0
var leaked := 0
## Tower -> damage dealt.
var damage := {}
var _elapsed := 0.0


func _ready() -> void:
	super()
	Engine.time_scale = time_scale
	EventManager.tower_damage_dealt.connect(_on_tower_damage_dealt)
	for node in find_children("*", "", true, false):
		if node is DemoEnemySpawner:
			node.enemy_spawned.connect(func(enemy: Enemy): enemy.died.connect(_on_enemy_died))
			node.enemy_leaked.connect(func(_enemy): leaked += 1)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	_elapsed += delta
	var lines := ["Kills %d   Leaked %d   Time %d s" % [kills, leaked, _elapsed]]
	for tower: Tower in damage:
		if is_instance_valid(tower):
			lines.append("%s   %d dmg   %.1f dps" % [tower.name, damage[tower], damage[tower] / _elapsed])
	stats_label.text = "\n".join(lines)


func _on_enemy_died(_enemy: Enemy, killed: bool) -> void:
	if killed:
		kills += 1


func _on_tower_damage_dealt(tower: Tower, amount: int) -> void:
	damage[tower] = damage.get(tower, 0) + amount
