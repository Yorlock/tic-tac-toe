extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene
var temp_marker

var player: int
var player_1_score: int = 0
var player_2_score: int = 0
var first_turn_player: int = -1
var score_format: String = "Player 1: %d\nPlayer 2: %d"
var next_player_format: String = "Next player: %d"
var winner: int
var moves: int
const MAX_MOVES: int = 9

var player_panel_pos: Vector2i
var grid_data: Array
var board_size: int
var cell_size: int
var grid_pos: Vector2i

var row_sum: int
var column_sum: int
var diagonal1_sum: int
var diagonal2_sum: int

func _ready() -> void:
	board_size = $Board.texture.get_width()
	cell_size = board_size/3
	player_panel_pos = $PlayerPanel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
		
	if event.position.x >= board_size:
		return

	grid_pos = Vector2i(event.position / cell_size)
	if grid_data[grid_pos.y][grid_pos.x] != 0:
		return

	grid_data[grid_pos.y][grid_pos.x] = player
	create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
	moves += 1
	
	if check_win() != 0:
		get_tree().paused = true
		$GameOverMenu.show()
		if winner == 1: 
			$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins!"
			player_1_score += 1
		else: 
			$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins!"
			player_2_score += 1
		
		$ScoreLabel.text = score_format % [player_1_score, player_2_score]

	if check_draw():
		get_tree().paused = true
		$GameOverMenu.show()
		$GameOverMenu.get_node("ResultLabel").text = "It is a tie!"
		player_1_score += 1
		player_2_score += 1
		$ScoreLabel.text = score_format % [player_1_score, player_2_score]
	
	player *= -1
	$PlayerLabel.text = next_player_format % [1 if player == 1 else 2]
	temp_marker.queue_free()
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)

func new_game():
	first_turn_player *= -1
	player = first_turn_player
	winner = 0
	moves = 0
	grid_data = [
	[0,0,0],
	[0,0,0],
	[0,0,0]]
	
	row_sum = 0
	column_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	$PlayerLabel.text = next_player_format % [1 if player == 1 else 2]
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(player, position, update_temp_marker = false):
	var figure
	if player == 1:
		figure = circle_scene.instantiate()
	else:
		figure = cross_scene.instantiate()

	figure.position = position
	add_child(figure)
	if update_temp_marker: temp_marker = figure

func check_win():
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		column_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
		if row_sum == 3 or column_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or column_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1

	return winner

func check_draw():
	if moves == MAX_MOVES: return true
	return false


func _on_game_over_menu_restart() -> void:
	new_game()
