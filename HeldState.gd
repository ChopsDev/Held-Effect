# Script for the "Held" state of a card, managing drag behavior and rotation based on mouse movement

extends CardState
class_name Held

@export var card : Control
@export var card_UI : Control

var drag_offset = Vector2.ZERO
var previous_mouse_position = Vector2.ZERO
var smoothed_velocity_x = 0.0

# Called when the "Held" state is activated
func enter():
	set_drag_offset()
	previous_mouse_position = get_viewport().get_mouse_position()
	
	var local_grab_point = card.get_local_mouse_position()
	var card_height = card_UI.size.y
	
	# Set pivot based on where the card is grabbed (top or center)
	if local_grab_point.y <= card_height * 0.573:
		card.pivot_offset = drag_offset
		set_drag_offset()
	else:
		card.pivot_offset = card_UI.size / 2
		set_drag_offset_center()

# Sets drag offset for center-based pivot
func set_drag_offset_center():
	drag_offset = get_viewport().get_mouse_position() - card.position

# Sets drag offset based on the exact grab point
func set_drag_offset():
	drag_offset = card.get_local_mouse_position()

# Called every frame to update card's position and rotation
func update(delta: float):
	var current_mouse_position = get_viewport().get_mouse_position()
	var mouse_delta = current_mouse_position - previous_mouse_position
	previous_mouse_position = current_mouse_position
	
	# Smoothly move card towards mouse position with offset
	card.position = lerp(card.position, current_mouse_position - drag_offset, 0.8)
	
	# Smooth and apply rotation based on horizontal mouse velocity
	var mouse_velocity_x = mouse_delta.x / delta
	smoothed_velocity_x = lerp(smoothed_velocity_x, mouse_velocity_x, 0.2)
	apply_rotation_based_on_velocity(smoothed_velocity_x, delta)

# Rotation settings
@export_group("Rotation Movement Weight")
@export var rotation_amount: float = 45.0
@export var max_velocity = 3500.0
@export var rotation_smoothing_speed: float = 35.0
@export var rotation_ease_weight: Curve

# Apply rotation based on velocity for a tilting effect
func apply_rotation_based_on_velocity(velocity_x, delta):
	var current_rotation = card.rotation_degrees
	var target_rotation = 0.0
	
	# Only rotate if velocity exceeds threshold
	if abs(velocity_x) > 0.1:
		var t = clamp(abs(velocity_x) / max_velocity, 0.0, 1.0)
		var eased_t = rotation_ease_weight.sample(t)
		target_rotation = eased_t * rotation_amount * sign(velocity_x)
	
	# Smoothly adjust rotation towards target
	card.rotation_degrees = lerp(current_rotation, target_rotation, delta * rotation_smoothing_speed)
