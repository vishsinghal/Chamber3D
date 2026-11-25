extends Node

## MissionManager
## Handles all 15 story missions for "THE LAST SHIFT – ESCAPE FROM TOWER 7",
## active objectives, dialogue broadcasts, access cards (L1-L5), and building transitions.

signal mission_started(mission_id: int, title: String, objective: String)
signal mission_completed(mission_id: int, next_mission_id: int)
signal dialogue_triggered(speaker: String, text: String, duration: float)
signal access_card_obtained(level: int)

var current_mission_id: int = 1
var player_keycard_level: int = 1
var audio_logs_found: int = 0
var rescued_employees: int = 0

var missions: Dictionary = {
	1: {
		"title": "MISSION 1: The Normal Morning",
		"location": "Ground Floor: Reception & Canteen",
		"objective": "Enter Tower 7 through the main entrance and report to Ground Floor Reception.",
		"complete": false
	},
	2: {
		"title": "MISSION 2: The Blackout",
		"location": "Central Elevator Shaft & Floor 1",
		"objective": "Power failure! Escape the stalled elevator car and climb to Floor 1.",
		"complete": false
	},
	3: {
		"title": "MISSION 3: Find Access Card",
		"location": "Ground Floor Kitchen & Cold Storage",
		"objective": "Infiltrate the kitchen through the service chute and retrieve Marcus's Level-2 card.",
		"complete": false
	},
	4: {
		"title": "MISSION 4: Enter Wing A",
		"location": "Floor 1 Wing A: Security HQ",
		"objective": "Navigate cubicles without alerting the Enforcer robot to reach the Security Locker.",
		"complete": false
	},
	5: {
		"title": "MISSION 5: The Central Connection",
		"location": "Floor 1: Central Glass Skybridge",
		"objective": "Cross the illuminated skybridge while dodging automated ceiling turret sweeps.",
		"complete": false
	},
	6: {
		"title": "MISSION 6: The Missing Employee",
		"location": "Floor 2 Wing B: HR Archive",
		"objective": "Lure the Enforcer robot away from Room 204 and rescue Evelyn Vance.",
		"complete": false
	},
	7: {
		"title": "MISSION 7: Emergency Staircase",
		"location": "Staircase South (Floors 2 to 4)",
		"objective": "Ascend the vertical ruined stairwell through wall parkour and conduit climbing.",
		"complete": false
	},
	8: {
		"title": "MISSION 8: Restore Electricity",
		"location": "Floor 4 Wing B: Substation",
		"objective": "Navigate the dark electrical wing and synchronize the 3-phase transformers.",
		"complete": false
	},
	9: {
		"title": "MISSION 9: The Server Room",
		"location": "Floor 5 Wing A: Quantum Server Farm",
		"objective": "Defend Priya Sharma from attacking drones while she downloads the AI source code.",
		"complete": false
	},
	10: {
		"title": "MISSION 10: The Elevator Challenge",
		"location": "Floor 5 to 6: Elevator Shafts #3 & #4",
		"objective": "Ascend the vertical shaft by jumping across the roofs of moving elevator cars.",
		"complete": false
	},
	11: {
		"title": "MISSION 11: The Hidden Secret",
		"location": "Floor 6 Wing B: Bio-Neural R&D Lab",
		"objective": "Decrypt Dr. Sterling's terminal and discover the truth behind Unit Zero.",
		"complete": false
	},
	12: {
		"title": "MISSION 12: The Restricted Floor",
		"location": "Floor 6: Executive Skybridge",
		"objective": "Neutralize the Titan-X Heavy Janitor Mech to unlock the Floor 7 staircase.",
		"complete": false
	},
	13: {
		"title": "MISSION 13: Security Control Room",
		"location": "Floor 7 Sub-Penthouse",
		"objective": "Override the perimeter blast doors to evacuate 40 trapped employees to the street.",
		"complete": false
	},
	14: {
		"title": "MISSION 14: The Seventh Floor",
		"location": "Floor 7: CEO Boardroom & Helipad",
		"objective": "Confront Dr. Arthur Sterling and breach the inner Quantum AI core.",
		"complete": false
	},
	15: {
		"title": "MISSION 15: Final Battle – Escape Tower 7",
		"location": "Floor 7: Quantum AI Core",
		"objective": "Destroy the Apex Overseer, disable SYNAPSE-7, and make your final decision.",
		"complete": false
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Broadcast Mission 1 on start
	call_deferred("_start_initial_mission")

func _start_initial_mission() -> void:
	start_mission(1)
	play_dialogue("Ramesh", "Neil! You're just in time. Grab a coffee at the canteen before the 10:30 standup.", 4.0)

func start_mission(id: int) -> void:
	if not missions.has(id):
		return
	current_mission_id = id
	var m = missions[id]
	emit_signal("mission_started", id, m["title"], m["objective"])

func complete_mission(id: int) -> void:
	if not missions.has(id):
		return
	missions[id]["complete"] = true
	var next_id = id + 1
	emit_signal("mission_completed", id, next_id)
	if missions.has(next_id):
		start_mission(next_id)

func play_dialogue(speaker: String, text: String, duration: float = 4.0) -> void:
	emit_signal("dialogue_triggered", speaker, text, duration)

func grant_keycard(level: int) -> void:
	if level > player_keycard_level:
		player_keycard_level = level
		emit_signal("access_card_obtained", level)
		play_dialogue("SYSTEM", "LEVEL %d ACCESS GRANTED." % level, 3.0)
