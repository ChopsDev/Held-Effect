# Script for managing a state machine, allowing for dynamic transitions between states

extends Node

@export var intinal_state : CardState  # The starting state, set from the inspector

var current_state : CardState  # The state currently in use
var states : Dictionary = {}    # Dictionary to store all available states by name

# State machine setup instructions:
# 1. Ensure each state script has a unique class_name set in State.gd.
# 2. Assign the correct starting state to "intinal_state."
# 3. Each state must have a signal called "Transitioned" for state transitions.
# To trigger transitions: emit the "Transitioned" signal within a state
# Or call `request_transition("StateName")` from outside the machine.

func _ready():
	# Gather all child nodes that are instances of CardState and store in `states` dictionary
	for child in get_children():
		if child is CardState:
			states[child.name.to_lower()] = child
			
	# Set the initial state and start its behavior if assigned
	if intinal_state:
		current_state = intinal_state
		connect_state_signals(current_state)
		intinal_state.enter()
	else:
		print("Warning: No initial state set!")  # Notify if no initial state is specified

# Updates the current state on each frame
func _process(delta):
	if current_state:
		current_state.update(delta)

# Updates the current state on each physics frame
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

# Handles state transitions based on emitted signals
func on_child_transition(state, new_state_name):
	# Ensures the signal is from the current active state
	if state != current_state:
		return
	
	# Look up the new state by name in `states`; print error if state is missing
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("State transition failed: No state found with name: ", new_state_name)
		return
	
	# Disconnect the old state, exit it, connect the new state, and enter it
	if current_state:
		disconnect_state_signals(current_state)
		current_state.exit()
	
	connect_state_signals(new_state)
	new_state.enter()
	current_state = new_state

# Externally request a state transition
func request_transition(new_state_name):
	# Ignore transition requests if already in the requested state
	if new_state_name == current_state.name:
		return
	
	on_child_transition(current_state, new_state_name)

# Connects the "Transitioned" signal for a state to enable transitions
func connect_state_signals(state: CardState):
	var handler_callable = Callable(self, "on_child_transition")
	if state.has_signal("Transitioned") and not state.is_connected("Transitioned", handler_callable):
		state.connect("Transitioned", handler_callable)

# Returns the name of the current state for debugging or display purposes
func see_current_state() -> String:
	return current_state.name

# Disconnects the "Transitioned" signal from a state when transitioning away
func disconnect_state_signals(state: CardState):
	var handler_callable = Callable(self, "on_child_transition")
	if state.is_connected("Transitioned", handler_callable):
		state.disconnect("Transitioned", handler_callable)
