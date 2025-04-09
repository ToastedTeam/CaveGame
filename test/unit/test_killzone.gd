extends GutTest

var killzone_scene = load('res://scenes/killzone/killzone.tscn')
var killzone: Killzone = null

var timer: Timer = null

func before_all():
	killzone = killzone_scene.instantiate()
	
	for child in killzone.get_children():
		if child.name == "Timer":
			timer = child
	
	assert_not_null(timer, "Timer was not found")
	
	watch_signals(timer)
	#gut.p("Runs once before all tests")

func after_all():
	Engine.time_scale = 1.0

#func before_each():
	#gut.p("Runs before each test.")

#func after_each():
	#gut.p("Runs after each test.")

#func after_all():
	#gut.p("Runs once after all tests")
	
func test_body_enters():
	var node = Node2D.new()
	
	killzone._on_body_entered(node)
	await wait_frames(2)
	
	assert_freed(node, "Node was not freed")
	
func test_player_enters():
	var node = Node2D.new()
	node.name = "Player"
	
	killzone._on_body_entered(node)
	await wait_frames(2)
	
	assert_not_freed(node, "Player should not be freed")
	
	assert_eq(Engine.time_scale, 0.5, "Engine timescale should be set to 0.5")
	
	print(timer.is_stopped())
	
	#assert_false(timer.is_stopped(), "Timer should be started")
	#simulate(killzone, 10, 0.1)
	#await wait_seconds(timer.wait_time * 2 + 1)
	#assert_signal_emitted(timer, "timeout")
	#assert_called(killzone, "_on_timer_timeout")
	
#func test_on_timer_timeout() -> void:
	#killzone._on_timer_timeout()
	#assert_eq(Engine.time_scale, 1, "Engine timescale should be set to 1")
