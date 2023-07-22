extends Node


var save_filename = "user://save_game.save"


func remove_save_game():
	var directory = Directory.new()
	directory.remove(save_filename)


func save_game():
	var save_file = File.new()
	save_file.open(save_filename, File.WRITE)
	var saved_nodes = get_tree().get_nodes_in_group("Saved")

	for node in saved_nodes:
		if node.filename.empty():
			break

		var node_details = node.get_save_stats()
		save_file.store_line(to_json(node_details))

	save_file.close()


func load_game():
	var save_file = File.new()
	if not save_file.file_exists(save_filename):
		return

	save_file.open(save_filename, File.READ)

	var saved_nodes = get_tree().get_nodes_in_group("Saved")

	for node in saved_nodes:
		while save_file.get_position() < save_file.get_len():
			var node_data = parse_json(save_file.get_line())

			if node.get_filename() != node_data.file_name:
				return
			else:
				node.load_save_stats(node_data)

	save_file.close()



func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()
