extends TestCase
## The tower arena (a dev sandbox) runs a wave's real enemies past the towers and counts
## what happens, so towers and enemies can be tried without playing the level.

const ARENA := "res://tests/tower_arena/tower_arena.tscn"


func _start_arena(with_towers := true) -> TowerArena:
	var arena: TowerArena = load(ARENA).instantiate()
	arena.time_scale = 4.0
	if not with_towers:
		for node in arena.get_children():
			if node is Tower:
				arena.remove_child(node)
				node.free()
	tree.root.add_child(arena)
	tree.current_scene = arena
	return arena


func _spawners(arena: TowerArena) -> Array:
	return arena.get_children().filter(func(n): return n is DemoEnemySpawner)


## Enemies come with wave 1's health and speed, and the tower's kills and damage count.
func test_arena_runs_wave_enemies_past_the_tower():
	var arena := _start_arena()
	var spawned := []
	for spawner in _spawners(arena):
		spawner.enemy_spawned.connect(func(e: Enemy): spawned.append([e.health, e.speed]))
	for f in 60 * 20:
		await tree.process_frame
		if arena.kills >= 3:
			break
	var wave: Wave = game_data().create_waves()[0]
	check(not spawned.is_empty(), "enemies spawned")
	for stats in spawned:
		check_eq(stats, [wave.health, wave.speed / 60.0], "enemy health and speed (px/s) from wave 1")
	check(arena.kills >= 3, "the tower kills wave 1 enemies (kills %d)" % arena.kills)
	var tower: Tower = arena.get_node("SurgeonFish")
	check(arena.damage.get(tower, 0) > 0, "damage counted for the tower")
	await frames()
	check(arena.stats_label.text.contains("Kills %d" % arena.kills), "kills shown: %s" % arena.stats_label.text)
	check(arena.stats_label.text.contains("SurgeonFish"), "damage line for the tower: %s" % arena.stats_label.text)


## Enemies nobody stops walk off the end of their lane and count as leaked, not killed.
func test_enemies_that_get_through_count_as_leaked():
	var arena := _start_arena(false)
	for f in 60 * 15:
		await tree.process_frame
		if arena.leaked >= 2:
			break
	check(arena.leaked >= 2, "leaks counted (%d)" % arena.leaked)
	check_eq(arena.kills, 0, "kills without towers")


func test_arena_restores_game_speed_when_closed():
	await _start_arena()
	check_eq(Engine.time_scale, 4.0, "arena speed applied")
	await cleanup()
	check_eq(Engine.time_scale, 1.0, "game speed restored")
