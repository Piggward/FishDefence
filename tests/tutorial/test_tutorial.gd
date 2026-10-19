extends TestCase
## The tutorial walks through its steps in order and hands control back to the game.

const TITLES := ["Defend the reef!", "Hire defenders!", "Place fishes!", "Build mazes!", "Start the game!"]


func test_tutorial_steps_through_and_resumes_the_game():
	await load_level()
	game_manager().tutorial_done = false
	var tutorial: TutorialContainer = tree.current_scene.get_node("CanvasLayer/TutorialContainer")
	EventManager.tutorial_requested.emit()
	tree.root.process_mode = Node.PROCESS_MODE_DISABLED
	for i in TITLES.size():
		await frames(3)
		var card: TutorialCard = tutorial.current_tutorial
		check_eq(card.tutorial_name.text, TITLES[i], "step %d title" % (i + 1))
		check(card.preview.visible, "step %d shows its demo" % (i + 1))
		check_eq(card.next_label.text == "Start", i == TITLES.size() - 1, "only the last step says Start (step %d)" % (i + 1))
		card.next.emit()
	await frames(3)
	check(not tutorial.visible, "tutorial hidden after the last step")
	check(game_manager().tutorial_done, "tutorial marked done")
	check_eq(tree.root.process_mode, Node.PROCESS_MODE_PAUSABLE, "game resumed")
	check_eq(tutorial.get_children().filter(func(c): return c is TutorialCard and not c.is_queued_for_deletion()).size(), 0, "no cards left behind")
