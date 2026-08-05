extends GutTest


func test_gut_is_available() -> void:
	assert_eq(1 + 1, 2, "GUT should execute the pinned smoke-test suite.")
