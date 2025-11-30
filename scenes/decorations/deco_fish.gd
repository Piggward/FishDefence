class_name DecoFish
extends Sprite2D

const ANGELFISH_2 = preload("uid://b8je12wheahho")
const ANGELFISH = preload("uid://dg3fmyddamft3")
const AXOLOTL_2 = preload("uid://dh8vwt2hm0y4s")
const AXOLOTL = preload("uid://bqupux6v4hmib")
const DANIO = preload("uid://bwsc3lfv0x66u")
const DANIO_GLO = preload("uid://srcesr174wv1")
const GUPPY_2 = preload("uid://cu3kshqr1diwk")
const GUPPY_3 = preload("uid://duld13s5hddlk")
const GUPPY_4 = preload("uid://cxd88p483lnd6")
const GUPPY = preload("uid://c3pb5sp0wa67d")
const PUFFER_PEA = preload("uid://dy12uwriv41b0")
const TETRA = preload("uid://bn2rv6htpu5ak")
const TETRA_2 = preload("uid://6yqmvoxqm2xb")
const TETRA_GLO_2 = preload("uid://024ym8sa2mp7")
const TETRA_GLO = preload("uid://c0scpwanvxwj2")
var direction: int
var speed = 30
const BUBBLE = preload("uid://dncqyivscsihw")
var dead = false

const FISH_TEXTURES = [
	ANGELFISH_2, ANGELFISH,
	AXOLOTL_2, AXOLOTL,
	DANIO, DANIO_GLO,
	GUPPY_2, GUPPY_3, GUPPY_4, GUPPY,
	PUFFER_PEA,
	TETRA, TETRA_2, TETRA_GLO_2, TETRA_GLO
]

func _ready():
	self.texture = FISH_TEXTURES[randi_range(0, FISH_TEXTURES.size()-1)]
	self.scale.x = 1 if direction <= 0 else -1
	self.speed *= randf_range(0.8, 1.2)
	await get_tree().create_timer(randf_range(0, 1)).timeout
	spawn_bubble()
	self.scale.x = 1 if direction <= 0 else -1
	
func spawn_bubble():
	if dead:
		return
	var b = BUBBLE.instantiate()
	b.global_position = self.global_position
	get_parent().add_child(b)
	await get_tree().create_timer(randi_range(1, 4)).timeout
	spawn_bubble()
	pass
	
func die():
	self.scale.y = -1
	dead = true
	await get_tree().create_timer(20).timeout
	self.queue_free()
	
func _process(delta):
	if dead:
		self.position.y += delta * 10
	else:
		self.position.x += delta * speed if direction > 0 else (-delta * speed)
		
