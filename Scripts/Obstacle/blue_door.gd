class_name BlueDoor extends Node2D

@export var button_types : Array[PackedScene]
@export var button_pos : Array[Vector2i]
@export var parent_nodes : Array[Node2D]
@onready var open_sfx : AudioStreamPlayer = %"Open SFX"
@onready var press_sfx : AudioStreamPlayer = %"Open SFX"
@onready var anim_player : AnimationPlayer = %AnimPlayer

var buttons : Array[Switch]
var open : bool = false

func _ready() -> void:
	for i in range(button_types.size()):
		buttons.append(button_types[i].instantiate())
		buttons[i].position = (button_pos[i] * Global.TILE_SIZE) + Vector2i(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)
		buttons[i].button_pressed.connect(_on_button_pressed)
		if parent_nodes: parent_nodes[i].add_child(buttons[i])
		else: add_child(buttons[i])
	anim_player.set_current_animation("reset")


# called by button script using signal
func _on_button_pressed() -> void:
	for i in range(buttons.size()):
		if not buttons[i].pressed:
			open_sfx.set_pitch_scale(1.25 + (i * 0.25))
			open_sfx.play()
			return
	open_door()


func open_door() -> void:
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
