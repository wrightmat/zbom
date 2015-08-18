partTest = {
	textureName = "particleTexture.png",
	maxParticles = 200,
	positionType = 1, --kCCPositionTypeFree=1 kCCPositionTypeRelative=2 kCCPositionTypeGrouped=3
	sourcePosition = { x=0, y=0 },
	sourcePositionVariance = { x = 1, y = 1},
	particleLifeSpan = 3,
	particleLifespanVariance = 0,
	angle = 360,
	angleVariance = 360,
	startColor = { red = 0, green = 0, blue = .7, alpha = 1 },
	startColorVariance = { red = 0, green = .1, blue = .3, alpha = 0 },
	finishColor = { red = .2, green = 0, blue = 0, alpha = 1 },
	finishColorVariance = { red = .5, green = 0, blue = 0, alpha = 0 },
	startParticleSize = .25,
	startParticleSizeVariance = 0,
	finishParticleSize =  .1,
	FinishParticleSizeVariance = 0,
	duration = -1.0,
	blendFuncSource = 770,
	blendFuncDestination = 1,
	rotationStart = 0,
	rotationStartVariance = 0,
	rotationEnd = 0,
	rotationEndVariance = 0,
	blendMode = "alpha",
	--[[
	Sprite.ALPHA = "alpha"
	Sprite.NO_ALPHA = "noAlpha"
	Sprite.ADD = "add"
	Sprite.MULTIPLY = "multiply"
	Sprite.SCREEN = "screen"
	]]
	emitterType = 3,	--1 = gravity 2=radial
	--MODE A properties
	gravity = { x = 0, y = 0 },
	speed = 100,
	speedVariance = 0,
	radialAcceleration = 0,
	radialAccelVariance = 0,
	tangentialAcceleration = 0,
	tangentialAccelVariance = 0,
	--MODE B properties
	maxRadius = 100,
	maxRadiusVariance = 0,
	endRadius = 90,
	endRadiusVariance = 0,
	rotatePerSecond = 25,
	rotatePerSecondVariance = 0,
	--MODE C properties --gravity well
	wellPos = {x=500,y=500},
	wellMass = 100,
	particleMass = 10,
	power = 100,
	epsilon = 100,
	gravityConst = 25000,
}