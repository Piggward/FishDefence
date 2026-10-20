extends SceneTree
## Runs every tests/**/test_*.gd script headless. A test fails on a failed check or on any
## engine/script error logged while it runs.
##
## Run all:       godot --headless --fixed-fps 60 --path . -s res://tests/runner/test_runner.gd
## Run a subset:  ... -s res://tests/runner/test_runner.gd -- navigation
## The process exit code is the number of failed tests.

const TESTS_DIR := "res://tests"


class ErrorCatcher extends Logger:
	var errors: Array[String] = []

	func _log_error(_function, file, line, code, rationale, _editor_notify, error_type, _backtraces):
		if error_type != ERROR_TYPE_WARNING:
			errors.append("%s (%s:%d)" % [rationale if rationale else code, file, line])

	func _log_message(_message, _error):
		pass


func _initialize():
	_run.call_deferred()


func _run():
	# The headless window is 64x64; size it like the game's window so anchored UI sits
	# where it does in play and mouse clicks can reach (and hover) it.
	root.size = Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"))
	var filter := OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else ""
	var catcher := ErrorCatcher.new()
	OS.add_logger(catcher)
	var failed := 0
	var passed := 0
	for path in _find_tests(TESTS_DIR):
		if filter and not path.contains(filter):
			continue
		if not load(path).can_instantiate():
			failed += 1
			print("FAIL  %s does not compile (see the parse error above)" % path.trim_prefix(TESTS_DIR + "/"))
			continue
		for method in _test_methods(path):
			var test = load(path).new()
			test.tree = self
			catcher.errors.clear()
			await test.call(method)
			await test.cleanup()
			var problems: Array[String] = test.failures.duplicate()
			for e in catcher.errors:
				if not test.expected_errors.any(func(x): return e.contains(x)):
					problems.append("error: " + e)
			for x in test.expected_errors:
				if not catcher.errors.any(func(e): return e.contains(x)):
					problems.append("expected an error containing '%s'" % x)
			var name := "%s :: %s" % [path.trim_prefix(TESTS_DIR + "/"), method]
			if problems.is_empty():
				passed += 1
				print("PASS  ", name)
			else:
				failed += 1
				print("FAIL  ", name)
				for p in problems:
					print("        ", p)
	print("\n%d passed, %d failed" % [passed, failed])
	quit(failed)


func _find_tests(dir: String) -> Array[String]:
	var found: Array[String] = []
	for sub in DirAccess.get_directories_at(dir):
		found.append_array(_find_tests(dir + "/" + sub))
	for file in DirAccess.get_files_at(dir):
		if file.begins_with("test_") and file.ends_with(".gd") and dir != TESTS_DIR + "/runner":
			found.append(dir + "/" + file)
	found.sort()
	return found


func _test_methods(path: String) -> Array[String]:
	var methods: Array[String] = []
	for m in load(path).get_script_method_list():
		if m.name.begins_with("test_") and not methods.has(m.name):
			methods.append(m.name)
	return methods
