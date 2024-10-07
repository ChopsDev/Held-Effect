# Script for the "Returning" state of a card, using spring physics to smoothly return the card to its original position and rotation

extends CardState
class_name Returning

@export var card: Control
@export var card_UI: Control
@export var card_point_node : Node2D  # Node defining the original target position for the card

# Variables to store original position, rotation, and velocities for the spring effect
var original_position = Vector2.ZERO
var original_rotation = 0.0
var velocity = Vector2.ZERO
var angular_velocity = 0.0

# Spring physics constants for position and rotation adjustment
var spring_constant = 500.0  # Controls the strength of the position spring
var damping_coefficient = 20.0  # Controls the damping effect on position
var rotational_spring_constant = 300.0  # Controls the strength of the rotation spring
var rotational_damping_coefficient = 15.0  # Controls the damping effect on rotation

# Called when the state is entered, setting the target position and resetting velocities
func enter(): 
	original_position = card_point_node.position
	original_rotation = card_point_node.rotation_degrees
	velocity = Vector2.ZERO
	angular_velocity = 0.0
	card.pivot_offset = card_UI.size / 2  # Set pivot to center for balanced movement

# Updates the card’s position and rotation every frame using spring physics
func update(delta: float):
	# Position spring effect: calculates forces to bring the card back to the target position
	var position_diff = original_position - card.position
	var spring_force = position_diff * spring_constant
	var damping_force = -velocity * damping_coefficient
	var acceleration = spring_force + damping_force
	velocity += acceleration * delta
	card.position += velocity * delta

	# Rotation spring effect: calculates forces to bring the card back to the target rotation
	var rotation_diff = original_rotation - card.rotation_degrees
	var rotational_spring_force = rotation_diff * rotational_spring_constant
	var rotational_damping_force = -angular_velocity * rotational_damping_coefficient
	var angular_acceleration = rotational_spring_force + rotational_damping_force
	angular_velocity += angular_acceleration * delta
	card.rotation_degrees += angular_velocity * delta

	# Check if the card has settled close to the target position and rotation
	if velocity.length() < 0.1 and position_diff.length() < 0.1 and abs(angular_velocity) < 0.1 and abs(rotation_diff) < 0.1:
		# Snap to final position, reset velocities, and transition to "Idle" state
		card.position = original_position
		card.rotation_degrees = original_rotation
		velocity = Vector2.ZERO
		angular_velocity = 0.0
		Transitioned.emit(self, "Idle")  # Signal to change to "Idle" state
