extends Node2D

@onready var bubble_dialogue = $DialogueBubble
@export var  str:String
func _ready():
	bubble_dialogue.play(str)
