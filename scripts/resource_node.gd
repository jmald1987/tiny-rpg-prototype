extends Area2D

# Sets what kind of resource this node gives.
# Example values:
# "wood"
# "ore"
@export var resource_type: String = "wood"

# Sets how much of that resource is given on collection.
@export var amount: int = 1

# Handles what happens when the player interacts with this resource.
# The node decides what type it is and updates the correct player count.
func interact(player):
	if resource_type == "wood":
		player.wood_count += amount
		print("Collected wood. Total: ", player.wood_count)
	elif resource_type == "ore":
		player.ore_count += amount
		print("Collected ore. Total: ", player.ore_count)
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
