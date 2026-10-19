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
