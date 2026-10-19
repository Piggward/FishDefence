class_name GridPathfinder
extends RefCounted
## Shortest 4-directional paths on a grid of cells, with as few turns as possible.
## A breadth-first pass from the target gives every cell its step count to the target.
## A path walks down those counts and keeps its direction for as long as that is still a
## shortest route, so it runs in long straight lines instead of staircases.
## Path points are `origin + cell * cell_size`.

const DIRECTIONS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
const UNREACHABLE := -1

var size: Vector2i
var cell_size: Vector2
var origin: Vector2
var _solid := PackedByteArray()
var _distance := PackedInt32Array()
## Target the cached distances were computed for; cleared whenever a cell changes.
var _distance_target := Vector2i(-1, -1)


func _init(grid_size: Vector2i, grid_cell_size: Vector2, grid_origin := Vector2.ZERO):
	size = grid_size
	cell_size = grid_cell_size
	origin = grid_origin
	_solid.resize(size.x * size.y)
	_distance.resize(size.x * size.y)


func set_solid(cell: Vector2i, solid := true) -> void:
	if _in_bounds(cell):
		_solid[_index(cell)] = 1 if solid else 0
		_distance_target = Vector2i(-1, -1)


func is_solid(cell: Vector2i) -> bool:
	return not _in_bounds(cell) or _solid[_index(cell)] == 1


func cell_to_point(cell: Vector2i) -> Vector2:
	return origin + Vector2(cell) * cell_size


## Points from `from` to `to`, both included; empty if there is no way through.
## `preferred_direction` is the way the walker is already heading, to avoid a turn at the start.
func find_path(from: Vector2i, to: Vector2i, preferred_direction := Vector2i.ZERO) -> PackedVector2Array:
	var path := PackedVector2Array()
	if is_solid(from) or is_solid(to):
		return path
	_update_distances(to)
	var i := _index(from)
	if _distance[i] == UNREACHABLE:
		return path
	var target := _index(to)
	var w := size.x
	var offsets: Array[int] = [1, w, -1, -w]  # same order as DIRECTIONS
	var k := DIRECTIONS.find(preferred_direction)
	path.resize(_distance[i] + 1)
	var n := 0
	path[n] = cell_to_point(from)
	while i != target:
		var next := _distance[i] - 1
		if k == -1 or not _leads_to(i, k, next, w):
			for d in 4:
				if _leads_to(i, d, next, w):
					k = d
					break
		i += offsets[k]
		n += 1
		@warning_ignore("integer_division")
		path[n] = origin + Vector2(i % w, i / w) * cell_size
	return path


## True if stepping from flat index `i` in direction `k` lands on a cell with distance `next`.
func _leads_to(i: int, k: int, next: int, w: int) -> bool:
	var x := i % w
	match k:
		0: return x + 1 < w and _distance[i + 1] == next
		1: return i + w < _distance.size() and _distance[i + w] == next
		2: return x > 0 and _distance[i - 1] == next
		_: return i >= w and _distance[i - w] == next


func _update_distances(target: Vector2i) -> void:
	if target == _distance_target:
		return
	_distance_target = target
	_distance.fill(UNREACHABLE)
	var w := size.x
	var count := _distance.size()
	var queue := PackedInt32Array()
	queue.resize(count)
	var head := 0
	var tail := 1
	queue[0] = _index(target)
	_distance[queue[0]] = 0
	while head < tail:
		var i := queue[head]
		head += 1
		var step := _distance[i] + 1
		var x := i % w
		if x + 1 < w and _solid[i + 1] == 0 and _distance[i + 1] == UNREACHABLE:
			_distance[i + 1] = step
			queue[tail] = i + 1
			tail += 1
		if x > 0 and _solid[i - 1] == 0 and _distance[i - 1] == UNREACHABLE:
			_distance[i - 1] = step
			queue[tail] = i - 1
			tail += 1
		if i + w < count and _solid[i + w] == 0 and _distance[i + w] == UNREACHABLE:
			_distance[i + w] = step
			queue[tail] = i + w
			tail += 1
		if i >= w and _solid[i - w] == 0 and _distance[i - w] == UNREACHABLE:
			_distance[i - w] = step
			queue[tail] = i - w
			tail += 1


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func _index(cell: Vector2i) -> int:
	return cell.y * size.x + cell.x
