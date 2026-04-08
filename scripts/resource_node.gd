extends Area2D

# Sets what kind of resource this node gives. Wood, ore, etc.
# Example values:
# "wood"
# "ore"
@export var resource_type: String = "wood"

# Sets how much of that resource is given on collection.
@export var amount: int = 1

# Sets the actionthe player performs on the node. Like cut, mine, etc.
@export var interaction_type: String = "cut"

# Handles what happens when the player interacts with this resource.
# The node decides what type it is and updates the correct player count.
func interact(player):
	var collected_amount = amount
	if resource_type == "wood":
		collected_amount =randi_range(1,5)
		player.wood_count += collected_amount
		player.show_feedback("Collected wood x" + str(collected_amount))
		
	elif resource_type == "ore":
		collected_amount =randi_range(1,5)
		player.ore_count += collected_amount
		player.show_feedback("Collected ore x" + str(collected_amount))
	else:
		print("Unknown resource type: ", resource_type)
		return

	# Updates UI later when that system is added.
	player.update_resource_ui()

	# Remove this node from the player's nearby list before deleting it.
	player.remove_nearby_object(self)

	# Deletes the resource after collection.
	queue_free()

# Runs when a body enters this Area2D.
# If the player enters, add this node to the player's nearby list.
func _on_body_entered(body):
	if body.name == "Player":
		body.add_nearby_object(self)

# Runs when a body exits this Area2D.
# If the player exits, remove this node from the player's nearby list.
func _on_body_exited(body):
	if body.name == "Player":
		body.remove_nearby_object(self)

# Highlights node targeted
func highlight():
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1,1,0) #yellow

# Remove highlight
func unhighlight():
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1,1,1) #normal
