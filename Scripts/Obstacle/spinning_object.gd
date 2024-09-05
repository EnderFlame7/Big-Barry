class_name SpinningObject extends Node2D


@export var initial_rot : float
@export var spin_rate : float


func _ready() -> void:
	rotation = deg_to_rad(initial_rot)


func _process(delta: float) -> void:
	rotation += deg_to_rad(spin_rate * (delta / 1.0))
