class_name GreenDoor extends Node2D

@export var button_types : Array[PackedScene]
@export var button_pos : Array[Vector2i]
@export var parent_nodes : Array[Node2D]
@onready var anim_player : AnimationPlayer = %AnimPlayer
@onready var move_sfx : AudioStreamPlayer = %"Move SFX"

var buttons : Array[Switch]
var opening : bool = false

func _ready() -> void:
	for i in range(button_types.size()):
		buttons.append(button_types[i].instantiate())
		buttons[i].position = (button_pos[i] * Global.TILE_SIZE) + Vector2i(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)
		buttons[i].button_pressed.connect(_on_open_door)
		buttons[i].button_released.connect(_on_close_door)
		if parent_nodes: parent_nodes[i].add_child(buttons[i])
		else: add_child(buttons[i])
	anim_player.set_current_animation("reset")


# called by button script using signal
func _on_open_door() -> void:
	if opening == false:
		opening = true
		if not move_sfx.playing: move_sfx.play()
		anim_player.set_current_animation("open")
		anim_player.play()

# called by button script using signal
func _on_close_door() -> void:
	if opening == true:
		opening = false
		if not move_sfx.playing: move_sfx.play()
		anim_player.set_current_animation("open")
		anim_player.play_backwards()


func _on_animation_finished(anim_name: StringName) -> void:
	if move_sfx.playing:
		move_sfx.stop()
