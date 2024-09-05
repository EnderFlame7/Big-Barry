class_name Switch extends Node2D

@export var sprite : AnimatedSprite2D
@export var area : Area2D

@onready var press_sfx : AudioStreamPlayer = %"Press SFX"
@onready var release_sfx : AudioStreamPlayer = %"Release SFX"

var id : int
var pressed : bool = false

signal button_pressed
signal button_released

func _ready() -> void:
	sprite.set_frame_and_progress(0, 0.0)


func _process(delta: float) -> void:
	for a in area.get_overlapping_areas():
		if a.is_in_group("player"):
			if press_sfx and not pressed: press_sfx.play()
			pressed = true
			button_pressed.emit()
			sprite.set_frame_and_progress(1, 0.0)
			return
	if pressed:
		if release_sfx and pressed: release_sfx.play()
		pressed = false
		button_released.emit()
	sprite.set_frame_and_progress(0, 0.0)
