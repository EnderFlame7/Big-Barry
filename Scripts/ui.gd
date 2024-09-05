class_name UI extends Control

@onready var inflation_bar : TextureProgressBar = %ProgressBar
@onready var timer : Label = %Timer

var inflation_value : float


func _ready() -> void:
	Global.ui = self


func _process(delta: float) -> void:
	var opt_min_zero: String = "0" if Global.main.time < 60 * 10 else ""
	var opt_sec_zero: String = "0" if floor(fmod(Global.main.time, 60)) < 10 else ""
	timer.set_text(opt_min_zero + str(floor(Global.main.time / 60)) + ":" + opt_sec_zero + str(String.num(floor(fmod(Global.main.time, 60)), 0)) + "." + str(snapped(100 * (snapped(Global.main.time, 0.01) - floor(Global.main.time)), 1)))
	if Global.player:
		inflation_bar.min_value = 0
		inflation_bar.max_value = Global.player.MAX_INFLATION
		inflation_bar.set_step(0.01)
		inflation_bar.set_value(Global.player.inflation)
		inflation_value = lerp(inflation_value, Global.player.inflation, 25 * delta)
		inflation_bar.set_value(inflation_value)
