extends Control

@onready var time_escaped : Label = %TimeEscaped
@onready var line_edit : LineEdit = %LineEdit

@onready var silent_wolf_leaderboard = preload("res://Addons/silent_wolf/Scores/Leaderboard.tscn")

var player_name : String
var player_score : float

func _on_submit_button_pressed() -> void:
	if not line_edit.get_text() == "":
		var input_string : String = line_edit.get_text()
		player_name = input_string
		
		SilentWolf.Scores.save_score(player_name, player_score)
			
		get_tree().change_scene_to_packed(silent_wolf_leaderboard)
