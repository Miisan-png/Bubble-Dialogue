extends Node2D

@onready var bubble_dialogue = $DialogueBubble

func _ready():
	bubble_dialogue.play("TestDialogue")
