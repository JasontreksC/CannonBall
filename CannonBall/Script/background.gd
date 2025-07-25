extends ParallaxBackground

@export var horizonColor: Color
@export var skyColor: Color

@onready var spSky: Sprite2D = $Sky
@onready var plClouds1 = $PL_Clouds1
@onready var plClouds2 = $PL_Clouds2
@onready var plMountains = $PL_Mountains

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var gtSky: GradientTexture2D = spSky.texture
	gtSky.gradient.set_color(0, skyColor)
	gtSky.gradient.set_color(1, horizonColor)
	
	var clouds1: Array[Node] = plClouds1.get_children()
	var clouds2: Array[Node] = plClouds2.get_children()
	
	for c: Sprite2D in clouds1:
		c.modulate = horizonColor * 1.2
		c.modulate.a = 1
	for c: Sprite2D in clouds2:
		c.modulate = horizonColor * 1.2
		c.modulate.a = 1
		
	#var mountains: Array[Node] = plMountains.get_children()
	#for c: Sprite2D in mountains:
		#var sm = c.material as ShaderMaterial
		#sm.set_shader_parameter("HorizonColor")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
