extends TestCase
## waves.csv loading.

const WAVES := "res://data/waves/waves.csv"


func test_waves_csv_loads_every_wave():
	var waves: Array = game_data().create_waves()
	check_eq(waves.size(), 25, "wave count")
	for i in waves.size():
		var w = waves[i]
		check(game_data().TRASH.has(w.trash_type), "wave %d trash type '%s' is known" % [i + 1, w.trash_type])
		check(w.amount > 0 and w.speed > 0 and w.health > 0, "wave %d has amount, speed and health" % [i + 1])


## Excel with Swedish settings saves with ";" and Windows line endings; both must load the same.
func test_semicolons_and_crlf_load_the_same_values():
	var original := FileAccess.get_file_as_string(WAVES)
	var path := "user://waves_semicolon_test.csv"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(original.replace(",", ";").replace("\n", "\r\n"))
	f.close()
	check_eq(game_data()._load_waves(path), game_data()._load_waves(WAVES), "rows")
	DirAccess.remove_absolute(path)


func test_bad_values_are_reported_with_line_numbers():
	var path := "user://waves_bad_test.csv"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("trash_type,amount,speed,health,enemy_bounty,wave_bounty\nsoda_cola,15,1000,50,2,200.5\n")
	f.close()
	expected_errors = ["line 2: unknown trash_type 'soda_cola'", "line 2: wave_bounty must be a whole number"]
	var rows: Array = game_data()._load_waves(path)
	check_eq(rows.size(), 1, "row count")
	DirAccess.remove_absolute(path)
