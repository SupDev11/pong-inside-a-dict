extends Node2D

#the entire code is in a dictionary lol
@onready var code_data := {
#region Variables
	#Button that starts the game
	start_menu_ui = %StartMenuUI,
	start_button = %StartButton,
	restart_button = %RestartButton,
	is_restarted = false,
	
	code_button = %CodeButton,
	code_window = %CodeWindow,
	
	#Audio
	audio = %Audio,
	paddle_hit = preload("res://sfx/paddle_hit.ogg"), 
	
	#Gets A Reference To The Player Variable
	player = %Player,
	player2 = %Player2,
	player_vars = {
		#Handles All Player Related Variables
		player_speed = 530,
		player_original_speed = 530,
		player_max_speed = 700,
		
		player1_score = 0,
		player2_score = 0,
		player1_score_ui = %P1ScoreTextNum,
		player2_score_ui = %P2ScoreTextNum,
		
		ball_rng_min_p1 = 0,
		ball_rng_min_p2 = 0,
		ball_rng_middle_p1 = 1,
		ball_rng_middle_p2 = 1,
		ball_rng_max_p1 = 2, 
		ball_rng_max_p2 = 2, 
	},
	
	#Gets A Reference To The Ball Variable
	ball = %BallPos/Ball,
	ball_pos = %BallPos,
	ballYborderUP = %Borders/YBorderBallUp,
	ballYborderDOWN = %Borders/YBorderBallDown,
	borderkillLeft = %BallBorderP1,
	borderkillRight = %BallBorderP2, 
	#Ball Speed Vars
	ball_speed_x = 520,
	ball_speed_y = 300,
	ball_speed_x_max = 1000,
	ball_speed_y_max = 500,
	ball_original_speed_x = 520,
	ball_original_speed_y = 300,
	
	#Ball Check Stuff
	ball_check = 0,
	ball_rng = RandomNumberGenerator.new(),
	ball_rng_min = 0,
	ball_rng_max = 3,
		
	#Enums Don't Work In A Dictionary, But Since Their Similar To One We Just Mimic It.
	BALL_DIR = {
		LEFT = 0,
		RIGHT = 1,
		LEFTDOWN = 2,
		RIGHTDOWN = 3,
		LEFTMIDDLE = 4,
		RIGHTMIDDLE = 5,
		UP = 6,
		DOWN = 7,
	},
	
#endregion
	
#region Functions
	std = {
		
		#Calls All Standard Functions
		FunctionCall = func() -> void:
			#connecting a button press to game start
			code_data.start_button.pressed.connect(func() -> void: 
				code_data.start_menu_ui.hide()
				code_data.code_window.hide()
				code_data.std.Start.call() 
				code_data.std.FixedUpdate.call()
			)
			code_data.restart_button.pressed.connect(func() -> void:
				code_data.is_restarted = true
				get_tree().reload_current_scene()
			)
			code_data.code_button.pressed.connect(func() -> void:
				code_data.code_window.show()
			)
			code_data.code_window.close_requested.connect(func() -> void:
				code_data.code_window.hide()
			)
			const grab_focus_delay := 0.5
			
			await get_tree().create_timer(grab_focus_delay).timeout
			code_data.start_button.grab_focus()
			pass,
		
		#Runs Once
		Start = func() -> void:
			code_data.ball.body_entered.connect(code_data.ball_functions.BallCollision)
			code_data.ball_functions.BallRandomPos.call()
			pass,
			
		#Runs Every Physics Frame
		FixedUpdate = func(delta := get_physics_process_delta_time()) -> void:
			while code_data.is_restarted == false:
				if code_data.is_restarted == true:
					break
				
				await get_tree().physics_frame
				#Movement Calls
				code_data.PlayerMovement.call()
				
				#Checks What Direction The Ball Should Head To
				code_data.ball_functions.BallMatch.call()
			pass,
	},
	
	game_functions = {
		AddSpeed = func(speed_amount) -> void:
			if code_data.ball_speed_x <= code_data.ball_speed_x_max:
				code_data.ball_speed_x += speed_amount
			if code_data.ball_speed_y <= code_data.ball_speed_y_max:
				code_data.ball_speed_y += randf_range(speed_amount, speed_amount + speed_amount)
			if code_data.ball_speed_x > code_data.ball_speed_x_max or code_data.ball_speed_y > \
			code_data.ball_speed_y_max:
				code_data.ball_speed_x = code_data.ball_speed_x_max
				code_data.ball_speed_y = code_data.ball_speed_y_max
				return
			
			if code_data.player_vars.player_speed <= code_data.player_vars.player_max_speed:
				code_data.player_vars.player_speed += speed_amount
			else:
				code_data.player_vars.player_speed = code_data.player_vars.player_max_speed
			pass,
		
		AddScoreP1 = func(score_amount) -> void:
			code_data.player_vars.player1_score += score_amount
			code_data.player_vars.player1_score_ui.text = str(code_data.player_vars.player1_score)
			pass,
		AddScoreP2 = func(score_amount) -> void:
			code_data.player_vars.player2_score += score_amount
			code_data.player_vars.player2_score_ui.text = str(code_data.player_vars.player2_score)
			pass,
		
		BallResetP1 = func() -> void:
			var ball_reset_delay := 2.0
			code_data.game_functions.AddScoreP2.call(1)
			code_data.ball.hide()
			
			await get_tree().create_timer(ball_reset_delay).timeout
			code_data.ball.show()
			code_data.ball.position = code_data.ball_pos.position
			code_data.ball_speed_x = code_data.ball_original_speed_x
			code_data.ball_speed_y = code_data.ball_original_speed_y
			code_data.player_vars.player_speed = code_data.player_vars.player_original_speed 
			code_data.ball_functions.BallRandomPos.call()
			pass,
			
		BallResetP2 = func() -> void:
			var ball_reset_delay := 2.0
			code_data.game_functions.AddScoreP1.call(1)
			code_data.ball.hide()
			
			await get_tree().create_timer(ball_reset_delay).timeout
			code_data.ball.show()
			code_data.ball.position = code_data.ball_pos.position
			code_data.ball_speed_x = code_data.ball_original_speed_x
			code_data.ball_speed_y = code_data.ball_original_speed_y
			code_data.player_vars.player_speed = code_data.player_vars.player_original_speed 
			code_data.ball_functions.BallRandomPos.call()
			pass,
	},
	
	#Handles The Movement
	PlayerMovement = func() -> void:
		code_data.player.velocity.y = Input.get_axis("up", "down") * code_data.player_vars.player_speed
		code_data.player.move_and_slide()
		
		code_data.player2.velocity.y = Input.get_axis("up2", "down2") * code_data.player_vars.player_speed
		code_data.player2.move_and_slide()
		pass,
		
	ball_functions = {
		BallCollision = func(body: Node2D) -> void:
			#Checks What Body Is Colliding With
			match body.name:
				code_data.ballYborderUP.name:
					code_data.ball_functions.BallRandomHitDown.call()
					code_data.ball_functions.PaddleHitSound.call()
				code_data.ballYborderDOWN.name:
					code_data.ball_functions.BallRandomHitUp.call()
					code_data.ball_functions.PaddleHitSound.call()
				code_data.player.name:
					code_data.ball_functions.BallRandomHitRight.call()
					code_data.ball_functions.PaddleHitSound.call()
				code_data.player2.name:
					code_data.ball_functions.BallRandomHitLeft.call()
					code_data.ball_functions.PaddleHitSound.call()
				code_data.borderkillLeft.name:
					code_data.game_functions.BallResetP1.call()
					code_data.ball_functions.PaddleHitSound.call()
				code_data.borderkillRight.name:
					code_data.game_functions.BallResetP2.call()
					code_data.ball_functions.PaddleHitSound.call()
					
			code_data.game_functions.AddSpeed.call(6.5)
			pass,
			
		BallMatch = func() -> void:
			match code_data.ball_check:
				code_data.BALL_DIR.LEFT:
					code_data.ball_functions.MoveUpperLeft.call()
				code_data.BALL_DIR.RIGHT:
					code_data.ball_functions.MoveUpperRight.call()
				code_data.BALL_DIR.LEFTDOWN:
					code_data.ball_functions.MoveLowerLeft.call()
				code_data.BALL_DIR.RIGHTDOWN:
					code_data.ball_functions.MoveLowerRight.call()
				code_data.BALL_DIR.LEFTMIDDLE:
					code_data.ball_functions.MoveMiddleLeft.call()
				code_data.BALL_DIR.RIGHTMIDDLE:
					code_data.ball_functions.MoveMiddleRight.call()
				code_data.BALL_DIR.UP:
					code_data.ball_functions.MoveDown.call()
				code_data.BALL_DIR.DOWN:
					code_data.ball_functions.MoveUp.call()
			pass,
			
		BallRandomPos = func() -> void:
			code_data.ball_check = randi_range(code_data.ball_rng_min, code_data.ball_rng_max)
			pass,
		
		PaddleHitSound = func() -> void:
			code_data.audio.stream = code_data.paddle_hit
			code_data.audio.play()
			pass,
		
		BallRandomHitLeft = func() -> void:
			var left_rng := RandomNumberGenerator.new()
			var left_rng_num := left_rng.randi_range(code_data.player_vars.ball_rng_min_p2, code_data.player_vars.ball_rng_max_p2)
			if left_rng_num == code_data.player_vars.ball_rng_min_p2:
				code_data.ball_check = code_data.BALL_DIR.LEFT
			
			if left_rng_num == code_data.player_vars.ball_rng_middle_p2:
				code_data.ball_check = code_data.BALL_DIR.LEFTMIDDLE
			
			if left_rng_num == code_data.player_vars.ball_rng_max_p2:
				code_data.ball_check = code_data.BALL_DIR.LEFTDOWN
			pass,
			
		BallRandomHitRight = func() -> void:
			var right_rng := RandomNumberGenerator.new()
			var right_rng_num := right_rng.randi_range(code_data.player_vars.ball_rng_min_p1, code_data.player_vars.ball_rng_max_p1)
			if right_rng_num == code_data.player_vars.ball_rng_min_p1:
				code_data.ball_check = code_data.BALL_DIR.RIGHT
			
			if right_rng_num == code_data.player_vars.ball_rng_middle_p1:
				code_data.ball_check = code_data.BALL_DIR.RIGHTMIDDLE
			
			if right_rng_num == code_data.player_vars.ball_rng_max_p1:
				code_data.ball_check = code_data.BALL_DIR.RIGHTDOWN
			pass,
			
		BallRandomHitDown = func() -> void:
			var down_rng := RandomNumberGenerator.new()
			var down_rng_num := down_rng.randi_range(code_data.player_vars.ball_rng_min_p1, code_data.player_vars.ball_rng_max_p1)
			if down_rng_num == code_data.player_vars.ball_rng_min_p1:
				code_data.ball_check = code_data.BALL_DIR.LEFTDOWN
				
			if down_rng_num == code_data.player_vars.ball_rng_middle_p1:
				code_data.ball_check = code_data.BALL_DIR.DOWN
			
			if down_rng_num == code_data.player_vars.ball_rng_max_p1:
				code_data.ball_check = code_data.BALL_DIR.RIGHTDOWN
			pass,
		
		BallRandomHitUp = func() -> void:
			var up_rng := RandomNumberGenerator.new()
			var up_rng_num := up_rng.randi_range(code_data.player_vars.ball_rng_min_p1, code_data.player_vars.ball_rng_max_p1)
			if up_rng_num == code_data.player_vars.ball_rng_min_p2:
				code_data.ball_check = code_data.BALL_DIR.LEFT
			
			if up_rng_num == code_data.player_vars.ball_rng_middle_p2:
				code_data.ball_check = code_data.BALL_DIR.UP
				
			if up_rng_num == code_data.player_vars.ball_rng_max_p2:
				code_data.ball_check = code_data.BALL_DIR.RIGHT
			pass,
		
		MoveUpperLeft = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x -= code_data.ball_speed_x * delta
			code_data.ball.position.y -= code_data.ball_speed_y * delta
			pass,

		MoveMiddleLeft = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x -= code_data.ball_speed_x * delta
			pass,

		MoveLowerLeft = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x -= code_data.ball_speed_x * delta
			code_data.ball.position.y += code_data.ball_speed_y * delta
			pass,
			
		MoveUpperRight = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x += code_data.ball_speed_x * delta
			code_data.ball.position.y -= code_data.ball_speed_y * delta
			pass,
			
		MoveMiddleRight = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x += code_data.ball_speed_x * delta
			pass,
			
		MoveLowerRight = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.x += code_data.ball_speed_x * delta
			code_data.ball.position.y += code_data.ball_speed_y * delta
			pass,
		MoveUp = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.y += code_data.ball_speed_x * delta
			pass,
		
		MoveDown = func(delta := get_physics_process_delta_time() ) -> void:
			code_data.ball.position.y -= code_data.ball_speed_x * delta
			pass,
	},
#endregion	
}

func _ready() -> void:
	code_data.std.FunctionCall.call()
