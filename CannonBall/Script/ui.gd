extends Control

var hp_step1 := 100
var hp_step2 := 100

const TURN_TIME := 5
@onready var time_label := $PlayUI/Time
@onready var def_ui := $PlayUI/Def
@onready var atk_ui := $PlayUI/Atk

var timer := TURN_TIME
var attacking_player := 1
var _timer : Timer

@onready var arrow1_click = $BallUi/BallUIarrow1click
@onready var arrow2_click = $BallUi/BallUIarrow2click

# Ball 이미지 3개를 각각 준비
@onready var black_ball = $BallUi/BlackBall
@onready var purple_ball = $BallUi/PurpleBall
@onready var red_ball = $BallUi/RedBall

var click_show_time := 0.2
var ball_state := 1 # 1~3

# 위치 저장용
var def_pos := Vector2()
var atk_pos := Vector2()

func _ready():
	# Def/Atk의 초기 위치 저장
	def_pos = def_ui.position
	atk_pos = atk_ui.position

	# HP바 초기화
	for i in range(100, 0, -10):
		var node_name1 = "HP/HpBar1/HpBk%d" % i
		var node1 = get_node_or_null(node_name1)
		if node1:
			node1.modulate.a = 1.0
		var node_name2 = "HP/HpBar2/HpBk%d" % i
		var node2 = get_node_or_null(node_name2)
		if node2:
			node2.modulate.a = 1.0

	start_turn(attacking_player)

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.one_shot = false
	_timer.autostart = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_tick)

	if arrow1_click:
		arrow1_click.modulate.a = 0.0
	if arrow2_click:
		arrow2_click.modulate.a = 0.0

	update_ball_color()

func _unhandled_input(event):
	if event.is_action_pressed("decrease_hp"):
		var node_name1 = "HP/HpBar1/HpBk%d" % hp_step1
		var node1 = get_node_or_null(node_name1)
		if node1:
			node1.modulate.a = 0.0
		hp_step1 -= 10
	elif event.is_action_pressed("decrease_hp2"):
		var node_name2 = "HP/HpBar2/HpBk%d" % hp_step2
		var node2 = get_node_or_null(node_name2)
		if node2:
			node2.modulate.a = 0.0
		hp_step2 -= 10
	elif event.is_action_pressed("Up"):
		show_arrow1_click()
		increase_ball_state()
	elif event.is_action_pressed("Down"):
		show_arrow2_click()
		decrease_ball_state()

func start_turn(player_num):
	timer = TURN_TIME
	update_time_label()
	attacking_player = player_num

	# 턴에 따라 Def와 Atk 위치 스왑
	if attacking_player == 1:
		atk_ui.position = atk_pos
		def_ui.position = def_pos
	else:
		atk_ui.position = def_pos
		def_ui.position = atk_pos

func _on_timer_tick():
	timer -= 1
	if timer < 0:
		attacking_player = 2 if attacking_player == 1 else 1
		start_turn(attacking_player)
	else:
		update_time_label()

func update_time_label():
	if timer <= 0:
		time_label.text = "Turn Change"
	else:
		var min = timer / 60
		var sec = timer % 60
		time_label.text = "%02d:%02d" % [min, sec]

func show_arrow1_click():
	if arrow1_click:
		arrow1_click.modulate.a = 1.0
		var timer := get_tree().create_timer(click_show_time)
		timer.timeout.connect(_on_arrow1_timer_timeout)

func _on_arrow1_timer_timeout():
	if arrow1_click:
		arrow1_click.modulate.a = 0.0

func show_arrow2_click():
	if arrow2_click:
		arrow2_click.modulate.a = 1.0
		var timer := get_tree().create_timer(click_show_time)
		timer.timeout.connect(_on_arrow2_timer_timeout)

func _on_arrow2_timer_timeout():
	if arrow2_click:
		arrow2_click.modulate.a = 0.0

func increase_ball_state():
	ball_state += 1
	if ball_state > 3:
		ball_state = 1
	update_ball_color()

func decrease_ball_state():
	ball_state -= 1
	if ball_state < 1:
		ball_state = 3
	update_ball_color()

func update_ball_color():
	# 모두 투명하게
	black_ball.modulate.a = 0.0
	purple_ball.modulate.a = 0.0
	red_ball.modulate.a = 0.0

	# ball_state에 따라 해당 공만 보이게
	match ball_state:
		1:
			black_ball.modulate.a = 1.0
		2:
			purple_ball.modulate.a = 1.0
		3:
			red_ball.modulate.a = 1.0
