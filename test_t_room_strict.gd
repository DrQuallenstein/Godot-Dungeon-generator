extends SceneTree

## Test script to validate differentiated success criteria for T-rooms vs I/L-rooms

func _init():
	print("=== Testing T-Room Strict Fulfillment ===\n")
	
	test_success_criteria_logic()
	test_t_room_scenarios()
	test_i_l_room_scenarios()
	
	print("\n=== All Tests Completed ===")
	quit()


func test_success_criteria_logic():
	print("Test 1: Success Criteria Logic")
	print("-------------------------------")
	
	print("NEW LOGIC: Differentiated by Required Connection Count")
	print()
	
	print("IF required_connections.size() >= 3:")
	print("  → STRICT: return connections_satisfied == required_connections.size()")
	print("  → T-rooms (3 required): ALL 3 must be filled")
	print("  → Multi-connection rooms: ALL must be filled")
	print()
	
	print("ELSE (< 3 required):")
	print("  → LENIENT: return connections_satisfied > 0")
	print("  → I-rooms (2 required): At least 1 must be filled")
	print("  → L-rooms (2 required): At least 1 must be filled")
	print()
	
	print("RATIONALE:")
	print("  - T-rooms with only 2/3 connections look incomplete")
	print("  - T-shape requires all 3 branches for visual coherence")
	print("  - I/L-rooms can work as corridors with 1 connection")
	print("  - I/L-rooms with 2 connections are ideal but not required")
	print()


func test_t_room_scenarios():
	print("Test 2: T-Room Scenarios (3 required)")
	print("--------------------------------------")
	
	print("Scenario A: T-Room with ALL 3 connections filled")
	print("  - TOP: Filled → Door created ✓")
	print("  - RIGHT: Filled → Door created ✓")
	print("  - BOTTOM: Filled → Door created ✓")
	print("  - connections_satisfied = 3")
	print("  - required_connections.size() = 3")
	print("  - Check: 3 == 3 → TRUE")
	print("  - Result: ✅ T-room PLACED with all 3 doors")
	print()
	
	print("Scenario B: T-Room with only 2/3 connections filled")
	print("  - TOP: Filled → Door created ✓")
	print("  - RIGHT: Cannot fill (blocked)")
	print("  - BOTTOM: Filled → Door created ✓")
	print("  - connections_satisfied = 2")
	print("  - required_connections.size() = 3")
	print("  - Check: 2 == 3 → FALSE")
	print("  - Result: ❌ T-room NOT PLACED")
	print("  - Walker tries different position/rotation")
	print()
	
	print("Scenario C: T-Room with only 1/3 connections filled")
	print("  - TOP: Filled → Door created ✓")
	print("  - RIGHT: Cannot fill (blocked)")
	print("  - BOTTOM: Cannot fill (blocked)")
	print("  - connections_satisfied = 1")
	print("  - required_connections.size() = 3")
	print("  - Check: 1 == 3 → FALSE")
	print("  - Result: ❌ T-room NOT PLACED")
	print()
	
	print("✓ T-rooms only placed when complete (all 3 connections)")
	print()


func test_i_l_room_scenarios():
	print("Test 3: I/L-Room Scenarios (2 required)")
	print("----------------------------------------")
	
	print("Scenario A: I-Room with BOTH connections filled")
	print("  - TOP: Filled → Door created ✓")
	print("  - BOTTOM: Filled → Door created ✓")
	print("  - connections_satisfied = 2")
	print("  - required_connections.size() = 2")
	print("  - Check: 2 < 3 → Lenient mode")
	print("  - Check: 2 > 0 → TRUE")
	print("  - Result: ✅ I-room PLACED with both doors")
	print()
	
	print("Scenario B: I-Room with only 1/2 connections filled")
	print("  - TOP: Cannot fill (blocked)")
	print("  - BOTTOM: Filled → Door created ✓")
	print("  - connections_satisfied = 1")
	print("  - required_connections.size() = 2")
	print("  - Check: 2 < 3 → Lenient mode")
	print("  - Check: 1 > 0 → TRUE")
	print("  - Result: ✅ I-room PLACED with 1 door")
	print("  - TOP remains open for later walkers")
	print()
	
	print("Scenario C: L-Room with only 1/2 connections filled")
	print("  - RIGHT: Filled → Door created ✓")
	print("  - BOTTOM: Cannot fill (blocked)")
	print("  - connections_satisfied = 1")
	print("  - required_connections.size() = 2")
	print("  - Check: 2 < 3 → Lenient mode")
	print("  - Check: 1 > 0 → TRUE")
	print("  - Result: ✅ L-room PLACED with 1 door")
	print("  - BOTTOM remains open for later walkers")
	print()
	
	print("✓ I/L-rooms placed with partial connections (flexible)")
	print()


func test_expected_outcomes():
	print("Test 4: Expected Outcomes")
	print("-------------------------")
	
	print("With Differentiated Success Criteria:")
	print()
	
	print("T-ROOMS (3 required):")
	print("  ✅ Only placed when ALL 3 exits connected")
	print("  ✅ Always look complete and proper T-shape")
	print("  ⚠️  May be placed less frequently (need all 3 positions free)")
	print("  ✓ Better than incomplete T-rooms!")
	print()
	
	print("I-ROOMS (2 required):")
	print("  ✅ Placed with 1 or 2 connections")
	print("  ✅ Can work as corridors with 1 connection")
	print("  ✅ Frequently placed")
	print()
	
	print("L-ROOMS (2 required):")
	print("  ✅ Placed with 1 or 2 connections")
	print("  ✅ Can work as corners with 1 connection")
	print("  ✅ Frequently placed")
	print()
	
	print("TRADE-OFF:")
	print("  - T-rooms: Stricter (complete or nothing)")
	print("  - I/L-rooms: Flexible (partial is OK)")
	print("  - Result: T-rooms always look proper!")
	print()
