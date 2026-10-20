extends TestCase
## The shop slides in from the tab and out when the mouse leaves. A slide can reverse
## half-way, and the placer's idea of whether the shop is open always matches the shop's.


func _shop_point() -> Vector2:
	return screen_pos(shop(), Vector2(60, shop().size.y / 2))


## Hovering items inside the open shop keeps it open; leaving it closes it.
func test_shop_opens_from_the_tab_and_closes_on_leave():
	await load_level()
	check_eq(shop().position, shop().closed_position, "starts closed")
	await open_shop()
	check(shop().open and placer().shop_open, "open, and the placer knows")
	check_eq(shop().position, shop().open_position, "slid fully in")
	var title := screen_pos(shop(), Vector2(shop().size.x / 2, 20))
	await mouse_glide(title + Vector2(0, 10), title, 2)
	for item in shop_items():
		await mouse_glide(title, screen_pos(item, item.size / 2), 2)
		check(shop().open, "still open while hovering %s" % item.stats.fish_name)
	await frames(40)
	check_eq(shop().position, shop().open_position, "still fully in")
	await mouse_glide(_shop_point(), Vector2(400, 300), 2)
	await frames(40)
	check(not shop().open and not placer().shop_open, "closed after leaving, and the placer knows")
	check_eq(shop().position, shop().closed_position, "slid fully out")


## Coming back while it slides out reopens it from where it is, instead of being ignored.
func test_shop_reverses_when_the_mouse_comes_back_mid_slide():
	await load_level()
	await open_shop()
	await mouse_glide(_shop_point(), Vector2(400, 300), 2)
	await frames(6)
	var x := shop().position.x
	check(x > shop().open_position.x and x < shop().closed_position.x, "mid-slide (x %s)" % x)
	await mouse_glide(Vector2(400, 300), _shop_point(), 2)
	check(shop().open and placer().shop_open, "reopening, and the placer knows")
	await frames(40)
	check_eq(shop().position, shop().open_position, "slid back in")
