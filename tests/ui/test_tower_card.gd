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
