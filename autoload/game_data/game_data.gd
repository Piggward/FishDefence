extends Node
## Wave data from waves.csv, loaded once, and the trash types enemies are made of.
## Tower stats live in each tower's folder as a TowerStats resource.

## Edit in any spreadsheet and save as CSV. Commas or semicolons both work (Excel with
## Swedish settings saves with ";"). Keep the values whole numbers.
## The file's import mode must stay "Keep File" so it is exported with the game.
const WAVES_PATH := "res://data/waves/waves.csv"
const WAVE_COLUMNS := ["trash_type", "amount", "speed", "health", "enemy_bounty", "wave_bounty"]

## Trash type (the trash_type column in waves.csv) -> enemy texture and the sound material played on death.
const TRASH := {
	"soda_coke": {"texture": preload("uid://me80oqeawbyf"), "material": "can"},
	"canned_soup": {"texture": preload("uid://bmj1lduug60as"), "material": "can"},
	"soda_pepsi": {"texture": preload("uid://ct3hvr3suw6bd"), "material": "can"},
	"soymilk_match": {"texture": preload("uid://qjkoel2faluk"), "material": "paper"},
	"soda_fanta": {"texture": preload("uid://rotbfsa4mpd8"), "material": "can"},
	"water_bottled": {"texture": preload("uid://emesrplrnsbr"), "material": "plastic"},
	"soda_sprite": {"texture": preload("uid://bgfas7k5jabt8"), "material": "can"},
	"yogurt_cup": {"texture": preload("uid://pkkn66dbbmnm"), "material": "plastic"},
	"garbage": {"texture": preload("uid://626io0fn6blk"), "material": "plastic bag"},
}

## One Dictionary per wave, keyed by WAVE_COLUMNS.
var _waves: Array[Dictionary] = []


func _ready():
	_waves = _load_waves(WAVES_PATH)


## Fresh Wave resources, so endless mode can scale them without touching the loaded data.
func create_waves() -> Array[Wave]:
	var waves: Array[Wave] = []
	for row in _waves:
		var wave := Wave.new()
		wave.trash_type = row["trash_type"]
		wave.amount = row["amount"]
		wave.speed = row["speed"]
		wave.health = row["health"]
		wave.enemy_bounty = row["enemy_bounty"]
		wave.wave_bounty = row["wave_bounty"]
		waves.append(wave)
	return waves


func trash_textures() -> Array:
	return TRASH.values().map(func(t): return t["texture"])


func _load_waves(path: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return rows
	var first_line := file.get_line()
	var delimiter := ";" if first_line.count(";") > first_line.count(",") else ","
	var header := Array(first_line.split(delimiter)).map(func(h): return h.strip_edges().to_lower())
	for column in WAVE_COLUMNS:
		if not header.has(column):
			push_error("%s: missing column '%s'" % [path, column])
			return rows
	var line_number := 1
	while not file.eof_reached():
		var cells := file.get_csv_line(delimiter)
		line_number += 1
		if cells.size() == 1 and cells[0].strip_edges().is_empty():
			continue
		var row := {}
		for column in WAVE_COLUMNS:
			var value: String = cells[header.find(column)].strip_edges() if header.find(column) < cells.size() else ""
			if column == "trash_type":
				if not TRASH.has(value):
					push_error("%s line %d: unknown trash_type '%s'" % [path, line_number, value])
				row[column] = value
			elif value.is_valid_int():
				row[column] = value.to_int()
			else:
				push_error("%s line %d: %s must be a whole number, got '%s'" % [path, line_number, column, value])
				row[column] = 0
		rows.append(row)
	return rows
