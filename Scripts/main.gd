class_name Main extends Node2D

@export var levels : Array[PackedScene]
@export var tension_levels : Array[int]

@export_group("Audio")
@export var menu_audio : AudioStreamWAV
@export var menu_volume : float
@export var music_audio : AudioStreamWAV
@export var music_volume : float
@export var tension_audio : AudioStreamWAV
@export var tension_volume : float
@export var panic_audio : AudioStreamWAV
@export var panic_volume : float

@onready var levels_node : Node2D = %Levels
@onready var camera : Camera2D = %Camera
@onready var ui : UI = %UI
@onready var audio_player : AudioStreamPlayer = %AudioPlayer

var mode : String = "checkpoint"
@onready var LEVEL_COUNT : int = levels.size()
const LEVEL_HEIGHT : int = 22

@onready var player_scene = preload("res://Scenes/player.tscn")

var player : Player
var time : float = 0
var current_level : int = 1
var game_started : bool = false
var transitioning : bool = false

signal game_ended

func _ready() -> void:
	Global.main = self
	game_ended.connect(Global.menu._on_game_end)
	#SilentWolf.configure_scores_open_scene_on_close("res://Scenes/main.tscn")
	camera.global_position = Vector2(0.0, -abs(LEVEL_COUNT * (LEVEL_HEIGHT * Global.TILE_SIZE)))
	ui.hide()
	audio_player.set_stream(menu_audio)
	audio_player.set_volume_db(menu_volume)
	audio_player.play()
	
	
func _process(delta: float) -> void:
	if transitioning:
		var camera_y_pos : float = -abs((LEVEL_HEIGHT * Global.TILE_SIZE) * -abs(current_level - 1))
		#camera.global_position = lerp(camera.global_position, camera_pos, 1.25 * delta)
		camera.global_position.y = move_toward(camera.global_position.y, camera_y_pos, 2500.0 * delta)
		
	elif game_started:
		if current_level <= LEVEL_COUNT:
			if player and not player.dead: time += delta
			current_level = abs(ceil(abs(Global.player.global_position.y - (LEVEL_HEIGHT * Global.TILE_SIZE)) / (LEVEL_HEIGHT * Global.TILE_SIZE)))
		else:
			game_started = false
			audio_player.stop()
			audio_player.set_stream(panic_audio)
			audio_player.set_volume_db(panic_volume)
			audio_player.play()
			game_ended.emit()
		#print(current_level)
		if player and not player.dead and game_started:
			play_music()
		elif game_started:
			audio_player.stop()
		var camera_pos : Vector2 = Vector2(0.0, -abs((LEVEL_HEIGHT * Global.TILE_SIZE) * -abs(current_level - 1)))
		camera.global_position = lerp(camera.global_position, camera_pos, 5 * delta)
	else:
		var camera_pos : Vector2 = Vector2(0.0, -abs(LEVEL_COUNT * (LEVEL_HEIGHT * Global.TILE_SIZE)))
		camera.global_position = lerp(camera.global_position, camera_pos, 5 * delta)
		

func _start_game() -> void:
	current_level = 1
	for child in levels_node.get_children():
		child.hide()
		child.queue_free()
	
	for n in range(levels.size()):
		var level : Level = levels[n].instantiate()
		level.global_position = Vector2(0.0, n * (LEVEL_HEIGHT * Global.TILE_SIZE) * -1)
		levels_node.add_child(level)
		
	if player:
		player.hide()
		player.queue_free()
	player = player_scene.instantiate()
	player.global_position = levels_node.get_child(current_level - 1).spawn_point.global_position
	add_child(player)

	transitioning = true
	await get_tree().create_timer(5.0).timeout
	transitioning = false
	
	time = 0
	ui.show()
	game_started = true
	
	
func play_music() -> void:
	for level in tension_levels:
		if current_level == level:
			print(level)
			if not audio_player.get_stream() == tension_audio:
				audio_player.stop()
				audio_player.set_stream(tension_audio)
				audio_player.set_volume_db(tension_volume)
				audio_player.play()
			return
	if not audio_player.get_stream() == music_audio:
		audio_player.stop()
		audio_player.set_stream(music_audio)
		audio_player.set_volume_db(music_volume)
		audio_player.play()
		
# called from player script
func _on_respawn_player() -> void:
	if player:
		player.hide()
		player.queue_free()
	player = player_scene.instantiate()
	if mode == "checkpoint":
		player.global_position = levels_node.get_child(current_level - 1).spawn_point.global_position
	else:
		time = 0
		current_level = 1
		player.global_position = levels_node.get_child(current_level - 1).spawn_point.global_position
	add_child(player)
	
	# Replay music
	audio_player.stop()
	audio_player.set_stream(music_audio)
	audio_player.set_volume_db(music_volume)
	audio_player.play()
