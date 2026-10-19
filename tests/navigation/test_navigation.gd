extends TestCase
## Grid pathfinding and tower placement rules.


func _turn_points(p: PackedVector2Array) -> Array[int]:
	var turns: Array[int] = []
	for i in range(2, p.size()):
		if (p[i] - p[i - 1]).normalized() != (p[i - 1] - p[i - 2]).normalized():
			turns.append(i - 1)
	return turns


## Paths must be shortest and must not cross solid cells; checked against Godot's AStarGrid2D.
func test_pathfinder_matches_astar_on_random_grids():
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for trial in 200:
		var size := Vector2i(rng.randi_range(5, 48), rng.randi_range(5, 28))
		var finder := GridPathfinder.new(size, Vector2(8, 8))
		var astar := AStarGrid2D.new()
		astar.region = Rect2i(Vector2i.ZERO, size)
		astar.cell_size = Vector2(8, 8)
		astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		astar.update()
		var density := rng.randf_range(0.0, 0.45)
		for x in size.x:
			for y in size.y:
				if rng.randf() < density:
					finder.set_solid(Vector2i(x, y))
					astar.set_point_solid(Vector2i(x, y))
		for q in 5:
			var from := Vector2i(rng.randi_range(0, size.x - 1), rng.randi_range(0, size.y - 1))
			var to := Vector2i(rng.randi_range(0, size.x - 1), rng.randi_range(0, size.y - 1))
			var path := finder.find_path(from, to)
			check_eq(path.size(), astar.get_point_path(from, to).size(), "path length %s->%s on trial %d" % [from, to, trial])
			for i in path.size():
				check(not finder.is_solid(Vector2i(path[i] / 8)), "path crosses a solid cell on trial %d" % trial)
				if i > 0:
					check_eq((path[i] - path[i - 1]).length(), 8.0, "step size on trial %d" % trial)
			if not failures.is_empty():
				return


## Enemies should follow long straight runs, not staircases (two turns in a row).
func test_spawn_path_has_no_staircase():
	await load_level()
	var path := tile_grid().get_start_to_finish()
	check(path.size() > 0, "spawn has a path to the goal")
	var turns := _turn_points(path)
	for i in range(1, turns.size()):
		check(turns[i] - turns[i - 1] > 1, "turns at points %d and %d form a staircase" % [turns[i - 1], turns[i]])


## A tower may be placed next to an enemy that is visibly outside its footprint.
func test_placing_beside_a_passing_enemy_is_allowed():
	await load_level()
	var g := tile_grid()
	var target: Tile = null
	for t in placeable_tiles():
		if t.pos.x + 3 < g.grid_size.x and g.grid_array[t.pos.y][t.pos.x + 2].is_free() and g.grid_array[t.pos.y][t.pos.x + 3].is_free():
			target = t
			break
	var corner := g.cell_position(target)
	# The footprint's visible edge is at corner.x + 12; the enemy stands 2.5px past it.
	var enemy := await spawn_enemy_at(corner + Vector2(14.5, 0))
	var p := placer()
	p.hover_tile = target
	p._spawn_ghost(load("res://entities/towers/crab/crab_tower.tscn"))
	p.mouse_entered_tile(target)
	await physics_frames(4)
	check(not p.moving_object.get_overlapping_bodies().has(enemy), "the ghost does not touch the enemy")
	check(g.can_place(target), "placement beside the enemy is allowed")
	p.end_placing()


## A tower that would seal the path is refused, and the refusal leaves the grid as it was.
func test_blocking_placement_is_refused_and_reverted():
	await load_level()
	var g := tile_grid()
	var before := g.get_start_to_finish()
	var blocker: Tile = null
	for t in free_tiles():
		var cells: Array = g._footprint(t)
		if cells.size() != 4 or not cells.all(func(c): return c.is_free()):
			continue
		if g.can_place(t):
			g._set_solid(cells, false)
		else:
			blocker = t
			break
	check(blocker != null, "the level has a spot where a tower would block the path")
	if blocker:
		check_eq(g.get_start_to_finish(), before, "path after the refused placement")


## Walkable tiles come from world positions: moving the area node while keeping its
## shapes in place must not change them.
func test_walkable_tiles_ignore_area_node_offset():
	await load_level()
	var g := tile_grid()
	var nav: Area2D = g.navigation_area
	var count := func():
		var n := 0
		for row in g.grid_array:
			for t in row:
				if g.is_inside_area(t.global_position, nav):
					n += 1
		return n
	var before: int = count.call()
	nav.position += Vector2(40, 0)
	for s in nav.get_children():
		s.position -= Vector2(40, 0)
	check_eq(count.call(), before, "walkable tiles after moving the area node")
