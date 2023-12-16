extends Sprite

export  var direction = Vector2.ZERO

var reflect = Vector2.ZERO
onready var animationTree = $AnimationTree


func _ready():
	animationTree.active = true
	reflect = direction.normalized()


func _physics_process(delta):
	animationTree.set("parameters/blend_position", reflect)

