class_name MovingObject extends Node2D

@onready var anim_player : AnimationPlayer = %AnimPlayer

func _ready() -> void:
	anim_player.set_current_animation("move")
	anim_player.play()
