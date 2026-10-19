extends TestCase
## Tower stats, ranges and buffs.

const TOWERS := [
	"res://entities/towers/anchovy/anchovy_tower.tscn",
	"res://entities/towers/clown_fish/clown_tower.tscn",
	"res://entities/towers/crab/crab_tower.tscn",
	"res://entities/towers/discus/discus_tower.tscn",
	"res://entities/towers/puffer/puffer_tower.tscn",
	"res://entities/towers/snail/snail.tscn",
	"res://entities/towers/surgeon_fish/surgeon_tower.tscn",
]
const CLOWN := "res://entities/towers/clown_fish/clown_tower.tscn"
const SURGEON := "res://entities/towers/surgeon_fish/surgeon_tower.tscn"
const SNAIL := "res://entities/towers/snail/snail.tscn"


## Every tower has stats, and each range cell becomes a 16px collision square.
func test_every_tower_has_stats_and_range_shapes():
	for path in TOWERS:
		var tower: Tower = load(path).instantiate()
		tree.root.add_child(tower)
		await frames()
		check(tower.stats != null, "%s has stats" % path)
		check(not tower.range_cells.is_empty(), "%s has range cells" % path)
		var shapes: Array = tower.range_area.get_children().filter(func(c): return c is RangeCollision).map(func(c): return c.position)
		var expected: Array = tower.range_cells.map(func(c): return c * 16)
		shapes.sort()
		expected.sort()
		check_eq(shapes, expected, "%s range shapes" % path)
		tower.queue_free()


func test_expert_mode_costs_more():
	var stats: TowerStats = load("res://entities/towers/crab/crab_stats.tres")
	game_manager().easy_mode = true
	var easy := stats.get_cost()
	game_manager().easy_mode = false
	check_eq(stats.get_cost(), int(easy * TowerStats.EXPERT_COST_MULTIPLIER), "expert cost")
	game_manager().easy_mode = true


## A clown buff must come and go with the towers, never stacking or sticking.
func test_clown_buff_follows_pickup_and_placement():
	await load_level()
	game_manager().eco_bucks = 100000
	var g := tile_grid()
	var pair := []
	for t in placeable_tiles():
		if t.pos.x + 2 < g.grid_size.x:
			var right = g.grid_array[t.pos.y][t.pos.x + 2]
			if right.is_free() and g.can_place(right):
				g._set_solid(g._footprint(right), false)
				pair = [t, right]
				break
	var surgeon: Tower = await place_tower(load(SURGEON), pair[0])
	var base: float = surgeon.attack_speed
	var clown: ClownTower = await place_tower(load(CLOWN), pair[1])
	var buffed: float = base * clown.attack_speed_multiplier
	check(is_equal_approx(surgeon.attack_speed, buffed), "buffed after the clown is placed")
	var p := placer()
	for i in 3:
		p.hover_tile = pair[0]
		p.try_pickup()
		await physics_frames(2)
		check(is_equal_approx(surgeon.attack_speed, base), "unbuffed while picked up (round %d)" % i)
		p.mouse_entered_tile(pair[0])
		check(p.try_place(), "placed back (round %d)" % i)
		await physics_frames(2)
		check(is_equal_approx(surgeon.attack_speed, buffed), "buffed once again, not twice (round %d)" % i)
	p.hover_tile = pair[1]
	p.try_pickup()
	await physics_frames(2)
	check(is_equal_approx(surgeon.attack_speed, base), "unbuffed when the clown is picked up")
	p.mouse_entered_tile(pair[1])
	p.try_place()


## Picking up a snail must release enemies standing on its slime.
func test_snail_pickup_releases_slowed_enemies():
	await load_level()
	game_manager().eco_bucks = 100000
	# The snail's slime lies one tower cell (two grid cells) to its left; enemies only ever
	# stand on walkable cells, so pick a spot with open ground there.
	var g := tile_grid()
	var spot: Tile = placeable_tiles().filter(func(t):
		return t.pos.x >= 2 and [-2, -1].all(func(dx):
			return [0, 1].all(func(dy): return g.grid_array[t.pos.y + dy][t.pos.x + dx].is_free())))[0]
	var snail: Snail = await place_tower(load(SNAIL), spot)
	var enemy := await spawn_enemy_at(snail.slimes[0].global_position, 1000)
	# Stand still: once the snail is gone the enemy's new path may lead into its spot,
	# and placing a tower on an enemy is (correctly) refused.
	enemy.following = false
	check(is_equal_approx(enemy.speed, 1000 * snail.slow_ratio), "slowed on the slime")
	var p := placer()
	p.hover_tile = spot
	p.try_pickup()
	await physics_frames(3)
	check(is_equal_approx(enemy.speed, 1000.0), "full speed after the snail is picked up")
	p.mouse_entered_tile(spot)
	check(p.try_place(), "snail placed back")
	await physics_frames(3)
	check(is_equal_approx(enemy.speed, 1000 * snail.slow_ratio), "slowed again after the snail is placed back")


## Slows with the same name don't stack; removing them in any order restores full speed.
func test_mixed_strength_slows_restore_speed():
	await load_level()
	var enemy := await spawn_enemy_at(Vector2(-100, -100))
	enemy.speed = 1000
	var slow := func(m: float) -> SlowDebuff:
		var d := SlowDebuff.new()
		d.slow_multiplier = m
		d.buff_name = "slow"
		return d
	enemy.add_debuff(slow.call(0.5))
	enemy.add_debuff(slow.call(0.8))
	check(is_equal_approx(enemy.speed, 500.0), "only the first slow applies")
	enemy.remove_debuff("slow")
	await frames()
	check(is_equal_approx(enemy.speed, 800.0), "the remaining slow takes over")
	enemy.remove_debuff("slow")
	await frames()
	check(is_equal_approx(enemy.speed, 1000.0), "full speed with no slows")


## Every attacking tower damages enemies standing in its range (anchovy charge, puffer
## spikes, surgeon spit, crab tackle and discus slam each detect enemies differently).
func test_attacking_towers_damage_enemies_in_range():
	for path in TOWERS:
		var stats: TowerStats = load(path).instantiate().stats
		if stats.damage <= 0:
			continue
		await load_level()
		game_manager().eco_bucks = 100000
		var tile: Tile = placeable_tiles()[placeable_tiles().size() / 2]
		var tower: Tower = await place_tower(load(path), tile)
		var enemies: Array[Enemy] = []
		for cell in tower.range_cells:
			var enemy := await spawn_enemy_at(tower.global_position + cell * 16)
			enemy.following = false
			enemies.append(enemy)
		var damaged := false
		for f in 600:
			await tree.process_frame
			if enemies.any(func(e): return e.health < 100000):
				damaged = true
				break
		check(damaged, "%s damaged an enemy in its range" % stats.fish_name)
		await cleanup()
