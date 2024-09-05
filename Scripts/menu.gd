class_name Menu extends Control

# MAIN MENU BUTTONS
@onready var play_button : TextureButton = %PlayButton
@onready var mode_button : TextureButton = %ModeButton
@onready var leaderboard_button : TextureButton = %LeaderboardButton

# MODE
@onready var mode : Control = %Mode
@onready var mode_desc : Label = %ModeDescription

@onready var anim_player : AnimationPlayer = %AnimPlayer

# LEADERBOARD STUFF
@onready var name_submit : Control = %LeaderboardSubmit
#@onready var leaderboard = preload("res://Addons/silent_wolf/Scores/Leaderboard.tscn")

# THE END
@onready var the_end : Control = %TheEnd

signal start_game

func _ready() -> void:
	#anim_player.set_current_animation("reset")
	#anim_player.play()
	Global.menu = self
	mode.hide()
	name_submit.hide()
	the_end.hide()
	disable_buttons()
	#anim_player.set_current_animation("show_menu")
	#anim_player.play()
	start_game.connect(owner._start_game)
	
	#await anim_player.animation_finished
	
	enable_buttons()
	
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	mode_desc.hide()
	disable_buttons()
	anim_player.set_current_animation("hide_menu")
	anim_player.play()
	start_game.emit()
	

func _on_mode_pressed() -> void:
	if not mode.visible:
		mode_desc.show()
		mode.show()
	else:
		#mode_desc.hide()
		mode.hide()


func _on_leaderboard_pressed() -> void:
	disable_buttons()
	anim_player.set_current_animation("hide_menu")
	anim_player.play()
	await anim_player.animation_finished
	#var bruh = leaderboard.instantiate()
	#add_child(bruh)
	

func disable_buttons() -> void:
	mode.hide()
	#mode_desc.hide()
	play_button.set_deferred("disabled", true)
	mode_button.set_deferred("disabled", true)
	leaderboard_button.set_deferred("disabled", true)


func enable_buttons() -> void:
	play_button.set_deferred("disabled", false)
	mode_button.set_deferred("disabled", false)
	leaderboard_button.set_deferred("disabled", false)

# called from main script
func _on_game_end() -> void:
	anim_player.set_current_animation("roll_credits")
	the_end.show()
	anim_player.play()
	await anim_player.animation_finished
	
	# Play happy music
	Global.main.audio_player.stop()
	Global.main.audio_player.set_stream(Global.main.menu_audio)
	Global.main.audio_player.set_volume_db(Global.main.menu_volume)
	Global.main.audio_player.play()
	
	#if Global.main.mode == "yolo":
		#enable_buttons()
		#name_submit.time_escaped.set_text("You escaped in " + Global.ui.timer.get_text() + " !")
		#name_submit.player_score = Global.main.time
		#anim_player.set_current_animation("show_name")
		#name_submit.show()
		#anim_player.play()
	#else:
	anim_player.set_current_animation("show_menu")
	anim_player.play()
	await anim_player.animation_finished
	enable_buttons()

func _on_checkpoint_button_pressed() -> void:
	Global.main.mode = "checkpoint"
	mode_desc.set_text("Mode: checkpoint")


func _on_yolo_button_pressed() -> void:
	Global.main.mode = "yolo"
	mode_desc.set_text("Mode: yolo")
