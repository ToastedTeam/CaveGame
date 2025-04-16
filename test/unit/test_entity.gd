extends GutTest

var entity_script = load('res://entities/Entity.gd')
var entity: Entity = null

func before_all():
	entity = entity_script.new()
	#gut.p("Runs once before all tests")

#func before_each():
	#gut.p("Runs before each test.")

#func after_each():
	#gut.p("Runs after each test.")

#func after_all():
	#gut.p("Runs once after all tests")
	
#func test_Damage():
	#entity.Damage(1, Node2D.new())
	#
	#assert_almost_eq(entity.health, entity.maxHealth - 1, 0.01, "Entity health was not subtracted")
	
func test_handleDeath():
	entity.handleDeath()
	await wait_frames(2)
	
	assert_freed(entity, "Entity was not freed")
