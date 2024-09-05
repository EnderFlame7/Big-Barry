class_name DoubleClickNode extends Node


## Detects when user double-clicked


## Max duration between two clicks
const MAX_CLICK_DELTA := 0.25
## Max click duration
const MAX_CLICK_DURATION: float = 0.15
## The mouse button we're listening (change it if wanted)
@export var CLICK : String


## Used to track down the delta time between two clicks
var click_delta: float = 0.0
## Used to measure the amount of time the button was pressed
var click_duration: float = 0.0
## Used to check if we consider that the user has clicked
var already_clicked := false


signal double_tap_detected(input : String)


func _ready() -> void:
	double_tap_detected.connect(owner.sneeze)


func _process(delta: float) -> void:
	detect_click(delta)
	

## Detects when we have considered that the user has clicked
func detect_click(delta: float) -> void:
	# User is pressing the mouse button
	if Input.is_action_pressed(CLICK):
		click_duration += delta
	
	# User released or is not pressing the mouse button
	elif not Input.is_action_pressed(CLICK):
		click_delta += delta
		if click_duration <= MAX_CLICK_DURATION and click_duration > 0.0:
			handle_click()
		click_duration = 0.0
	
	
	# Resets already_clicked when too much time has passed before another click occured
	if click_delta > MAX_CLICK_DELTA:
		already_clicked = false


## Handles each considered click occurence happens
func handle_click() -> void:
	# Not clicked? => clicked already, we're waiting for the next click now
	if not already_clicked:
		already_clicked = true
		
	# We're checking if not too much time has passed since the previous click
	# (Implies that already_clicked == true)
	elif click_delta <= MAX_CLICK_DELTA:
		handles_double_click()
		
	# Resets the variable each time a click occurs
	click_delta = 0.0


## Handles when user double-clicked
func handles_double_click() -> void:
	double_tap_detected.emit(CLICK)
	print("DOUBLE CLICK")
