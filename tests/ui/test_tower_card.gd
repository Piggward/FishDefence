extends TestCase
## The shop's hover card and its live tower demo.


func test_hover_card_shows_demo_and_frees_it_on_hide():
	await load_level()
	var card := tower_card()
	for item in shop_items():
		card.show_tower(item.stats, item.fish_texture.texture, item.demo_scene)
		await frames(20)
		check(card.visible, "card visible for %s" % item.stats.fish_name)
		check_eq(card.preview.viewport.get_child_count(), 1, "one demo in the preview for %s" % item.stats.fish_name)
		card.hide_tower()
		await frames(3)
		check(not card.visible, "card hidden")
		check_eq(card.preview.viewport.get_child_count(), 0, "preview empty after hiding %s" % item.stats.fish_name)


func _on_screen_size(control: Control) -> Vector2:
	return control.size * (tree.root.get_final_transform() * control.get_global_transform_with_canvas()).get_scale()


## The demo renders at the pixels it covers on screen, not its smaller UI size (which got
## stretched up and blurred), at any window size, while the demo still frames the same area.
func test_demo_renders_at_screen_resolution():
	await load_level()
	var card := tower_card()
	var item: ShopItem = shop_items()[1]
	card.show_tower(item.stats, item.fish_texture.texture, item.demo_scene)
	var preview := card.preview
	# The window is resized while the card stays open.
	for window in [Vector2i(1152, 648), Vector2i(1920, 1080)]:
		tree.root.size = window
		await frames(5)
		var on_screen := _on_screen_size(preview)
		check(on_screen.x > preview.size.x * 1.2, "the card is scaled up on screen (%s vs UI %s)" % [on_screen, preview.size])
		check((Vector2(preview.viewport.size) - on_screen).abs() < Vector2(1, 1),
			"renders %s pixels for %s on screen at %s" % [preview.viewport.size, on_screen, window])
		# Same framing: the tower sits at the same fraction of the preview as at UI size.
		var tower: Node2D = preview.viewport.find_children("*", "Tower", true, false)[0]
		var at := tower.get_global_transform_with_canvas().origin
		var in_pixels := preview.viewport.get_final_transform() * at / Vector2(preview.viewport.size)
		check((in_pixels - at / preview.size).abs() < Vector2(0.01, 0.01),
			"tower at %s of the preview, expected %s at %s" % [in_pixels, at / preview.size, window])
	card.hide_tower()
	tree.root.size = Vector2i(1152, 648)


## A demo left open must not pile up enemies (they used to spawn forever).
func test_demo_enemies_stay_bounded():
	await load_level()
	var item: ShopItem = shop_items().filter(func(i): return i.stats.fish_name == "Anchovy")[0]
	var card := tower_card()
	card.show_tower(item.stats, item.fish_texture.texture, item.demo_scene)
	await frames(1200)
	var enemies := card.preview.viewport.find_children("*", "CharacterBody2D", true, false).size()
	check(enemies < 40, "demo enemies after 20 s: %d" % enemies)
	card.hide_tower()


## Towers inside the hover demos attack the demo enemies.
func test_demo_towers_attack():
	await load_level()
	var card := tower_card()
	for name in ["Crab", "Surgeon Fish", "Puffer Fish", "Anchovy"]:
		var item: ShopItem = shop_items().filter(func(i): return i.stats.fish_name == name)[0]
		card.show_tower(item.stats, item.fish_texture.texture, item.demo_scene)
		# Demo enemies have no health set, so the first hit kills them: watch for deaths.
		var kills := [0]
		var watched := {}
		for f in 600:
			await tree.process_frame
			for e in card.preview.viewport.find_children("*", "CharacterBody2D", true, false):
				if e is Enemy and not watched.has(e):
					watched[e] = true
					e.died.connect(func(_e, _killed): kills[0] += 1)
			if kills[0] > 0:
				break
		check(kills[0] > 0, "%s demo kills its enemies" % name)
		card.hide_tower()
		await frames(3)
