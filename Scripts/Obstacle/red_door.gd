class_name RedDoor extends Node2D

@export var button_type : PackedScene
@export var button_pos : Vector2i
@export var parent_node : Node2D
@onready var anim_player : AnimationPlayer = %AnimPlayer
@onready var open_sfx : AudioStreamPlayer = %"Open SFX"

var button
var open : bool = false

func _ready() -> void:
	button = button_type.instantiate()
	button.position = (button_pos * Global.TILE_SIZE) + Vector2i(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)
	button.button_pressed.connect(_on_open_door)
	if parent_node: parent_node.add_child(button)
	else: add_child(button)
	anim_player.set_current_animation("reset")

# called by button script using signal
func _on_open_door() -> void:
	if open == false:
		open = true
		open_sfx.play()
		anim_player.set_current_animation("open")
		anim_player.play()

# called by button script using signal
func _on_close_door() -> void:
	if open == true:
		open = false
		anim_player.set_current_animation("open")
		anim_player.play_backwards()
