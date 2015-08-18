sol.main.load_file("scripts/particle")(game)

local cEmitter = {}

function cEmitter:new(p)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(p)

  return object
end

function cEmitter:initialize(p)
	self.active = false
	self.t = cEmitter:deepcopy(p)
	self.template = cEmitter:deepcopy(p)
	self.maxParticles = self.t["maxParticles"]
	self.life = self.t["particleLifeSpan"]
	self.particles = {}
	self.emissionRate = self.maxParticles/self.life
	self.duration = nil
	self.emitCounter = 0
	self.particleCount = 0
	self.deadParts = {}
	self.angleOverride = false
	self.angleA = 0
	self.angleAvar = 0

	for i=1,self.maxParticles,1 do
		self.particles[i] = cEmitter:deepcopy(cEmitter:createParticle(self.t))
	end	
end

function cEmitter:createParticle(t)
	local p = {}
	local bitmap = Bitmap.new(Texture.new(t["textureName"]))
	local bw = bitmap:getWidth()
	local bh = bitmap:getHeight()
	bitmap:setPosition(-bw/2,-bh/2)
	p.sprite = Sprite.new()
	p.sprite:addChild(bitmap)
	p.sprite:setVisible(false)
	stage:addChild(p.sprite)
	p.active = false
	
	local life = t["particleLifeSpan"]
	local lifeVar = t["particleLifespanVariance"]
	local sourcePosition = t["sourcePosition"]
	local posVar = t["sourcePositionVariance"]
	local startSize = t["startParticleSize"]
	local startSizeVar = t["startParticleSizeVariance"]
	local endSize = t["finishParticleSize"]
	local endSizeVar = t["FinishParticleSizeVariance"]
	local startSpin = t["rotationStart"]
	local startSpinVar = t["rotationStartVariance"]
	local endSpin = t["rotationEnd"]
	local endSpinVar = t["rotationEndVariance"]
	
	local angle = t["angle"]
	local angleVar = t["angleVariance"]

	local start = {
		r = clampf(t["startColor"].red + t["startColorVariance"].red * CCRANDOM_MINUS1_1(),0,1),
		g = clampf(t["startColor"].green + t["startColorVariance"].green * CCRANDOM_MINUS1_1(),0,1),
		b = clampf(t["startColor"].blue + t["startColorVariance"].blue * CCRANDOM_MINUS1_1(),0,1),
		a = clampf(t["startColor"].alpha + t["startColorVariance"].alpha * CCRANDOM_MINUS1_1(),0,1)
	}
	local End = {
		r = clampf(t["finishColor"].red + t["finishColorVariance"].red * CCRANDOM_MINUS1_1(),0,1),
		g = clampf(t["finishColor"].green + t["finishColorVariance"].green * CCRANDOM_MINUS1_1(),0,1),
		b = clampf(t["finishColor"].blue + t["finishColorVariance"].blue * CCRANDOM_MINUS1_1(),0,1),
		a = clampf(t["finishColor"].alpha + t["finishColorVariance"].alpha * CCRANDOM_MINUS1_1(),0,1)
	}

 	p.timeToLive = life * lifeVar * CCRANDOM_MINUS1_1()
	p.timeToLive = MAX(0,p.timeToLive)
	p.timeToLive = 1
	p.pos = {
		x = sourcePosition.x + posVar.x * CCRANDOM_MINUS1_1(),
		y = sourcePosition.y + posVar.y * CCRANDOM_MINUS1_1()
	}
	p.color = start
	p.deltaColor = {
		r = (End.r - start.r) / p.timeToLive,
		g = (End.g - start.g) / p.timeToLive,
		b = (End.b - start.b) / p.timeToLive,
		a = (End.a - start.a) / p.timeToLive
	}
	local startS = startSize + startSizeVar * CCRANDOM_MINUS1_1()
	startS = MAX(0,startS)
	
	
	p.size = startS
	p.deltaSize = 0
	if endSize == -1 then 
		p.deltaSize = 0
	else
		local endS = endSize + endSizeVar * CCRANDOM_MINUS1_1()
		endS = MAX(0,endS)
		p.deltaSize = (endS - startS) / p.timeToLive
	end

	local startA = startSpin + startSpinVar * CCRANDOM_MINUS1_1()
	local endA = endSpin + endSpinVar * CCRANDOM_MINUS1_1()
	p.rotation = startA
	p.deltaRotation = (endA - startA) / p.timeToLive

	local w = p.sprite:getWidth()
	local h = p.sprite:getHeight()
	p.startPos = ccpMult({x=p.sprite:getX()-w/2,y=p.sprite:getY()-h/2},1)
	
	local a = CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() )
	p.pType = t["emitterType"]
	local v = { x=math.cos(a),y=math.sin(a)}
	local s = t["speed"] + t["speedVariance"] * CCRANDOM_MINUS1_1()
	local startRadius = t["maxRadius"]+t["maxRadiusVariance"]*CCRANDOM_MINUS1_1()
	local endRadius = t["endRadius"]+t["endRadiusVariance"]*CCRANDOM_MINUS1_1()
	local er = 0
	if endRadius == -1 then er = 0 else er = (endRadius-startRadius)/p.timeToLive end
	p.mode = {
		A = {
			dir = ccpMult(v,s),
			radialAccel = t["radialAcceleration"]+t["radialAccelVariance"]*CCRANDOM_MINUS1_1(),
			tangentialAccel = t["tangentialAcceleration"]+t["tangentialAccelVariance"]*CCRANDOM_MINUS1_1(),
			gravity = t["gravity"]
		},
		B = {
			angle = a,
			degreesPerSecond = CC_DEGREES_TO_RADIANS(t["rotatePerSecond"]+t["rotatePerSecondVariance"]*CCRANDOM_MINUS1_1()),
			radius = startRadius,
			deltaRadius = er
		},
		C = {
			wellPos = t["wellPos"],
			power = t["power"],
			epsilon = t["epsilon"],
			epsilonSq = t["epsilon"] * t["epsilon"],
			velX = 0,
			velY = 0
		}
		
	}
	cEmitter:setBlendMode(t["blendMode"],p.sprite)
	
	return p
end

function cEmitter:setAngle(a,av)
	self.angleOverride = true
	self.angleA = a
	self.angleAvar = av
end

function cEmitter:reset(p,pSettings,sx,sy,override)
	t = emitter:deepcopy(pSettings)
	p.sprite:setVisible(true)
	local life = t["particleLifeSpan"]
	local lifeVar = t["particleLifespanVariance"]
	local sourcePosition = {}
	if sx ~= nil and sy ~=nil then
		sourcePosition = {x=sx,y=sy}
	else
		sourcePosition = t["sourcePosition"]
	end
	local posVar = t["sourcePositionVariance"]
	local startSize = t["startParticleSize"]
	local startSizeVar = t["startParticleSizeVariance"]
	local endSize = t["finishParticleSize"]
	local endSizeVar = t["FinishParticleSizeVariance"]
	local startSpin = t["rotationStart"]
	local startSpinVar = t["rotationStartVariance"]
	local endSpin = t["rotationEnd"]
	local endSpinVar = t["rotationEndVariance"]
	local angle = t["angle"]
	if override["angle"] ~= nil then angle = override["angle"] end
	local angleVar = t["angleVariance"]
	if override["angleVar"] ~= nil then angleVar = override["angleVar"] end

	local start = {
		r = clampf(t["startColor"].red + t["startColorVariance"].red * CCRANDOM_MINUS1_1(),0,1),
		g = clampf(t["startColor"].green + t["startColorVariance"].green * CCRANDOM_MINUS1_1(),0,1),
		b = clampf(t["startColor"].blue + t["startColorVariance"].blue * CCRANDOM_MINUS1_1(),0,1),
		a = clampf(t["startColor"].alpha + t["startColorVariance"].alpha * CCRANDOM_MINUS1_1(),0,1)
	}
	local End = {
		r = clampf(t["finishColor"].red + t["finishColorVariance"].red * CCRANDOM_MINUS1_1(),0,1),
		g = clampf(t["finishColor"].green + t["finishColorVariance"].green * CCRANDOM_MINUS1_1(),0,1),
		b = clampf(t["finishColor"].blue + t["finishColorVariance"].blue * CCRANDOM_MINUS1_1(),0,1),
		a = clampf(t["finishColor"].alpha + t["finishColorVariance"].alpha * CCRANDOM_MINUS1_1(),0,1)
	}

 	p.timeToLive = life * lifeVar * CCRANDOM_MINUS1_1()
	p.timeToLive = MAX(0,p.timeToLive)
	p.timeToLive = 1
	p.pos = {
		x = sourcePosition.x + posVar.x * CCRANDOM_MINUS1_1(),
		y = sourcePosition.y + posVar.y * CCRANDOM_MINUS1_1()
	}
	p.color = start
	p.deltaColor = {
		r = (End.r - start.r) / p.timeToLive,
		g = (End.g - start.g) / p.timeToLive,
		b = (End.b - start.b) / p.timeToLive,
		a = (End.a - start.a) / p.timeToLive
	}
	local startS = startSize + startSizeVar * CCRANDOM_MINUS1_1()
	startS = MAX(0,startS)
	
	
	p.size = startS
	p.deltaSize = 0
	if endSize == -1 then 
		p.deltaSize = 0
	else
		local endS = endSize + endSizeVar * CCRANDOM_MINUS1_1()
		endS = MAX(0,endS)
		p.deltaSize = (endS - startS) / p.timeToLive
	end

	local startA = startSpin + startSpinVar * CCRANDOM_MINUS1_1()
	local endA = endSpin + endSpinVar * CCRANDOM_MINUS1_1()
	p.rotation = startA
	p.deltaRotation = (endA - startA) / p.timeToLive

	local w = p.sprite:getWidth()
	local h = p.sprite:getHeight()
	p.startPos = ccpMult({x=p.sprite:getX()-w/2,y=p.sprite:getY()-h/2},1)
	
	local a = CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() )
	p.pType = t["emitterType"]
	local v = { x=math.cos(a),y=math.sin(a)}
	local s = t["speed"] + t["speedVariance"] * CCRANDOM_MINUS1_1()
	local startRadius = t["maxRadius"]+t["maxRadiusVariance"]*CCRANDOM_MINUS1_1()
	local endRadius = t["endRadius"]+t["endRadiusVariance"]*CCRANDOM_MINUS1_1()
	local er = 0
	if endRadius == -1 then er = 0 else er = (endRadius-startRadius)/p.timeToLive end
	p.mode = {
		A = {
			dir = ccpMult(v,s),
			radialAccel = t["radialAcceleration"]+t["radialAccelVariance"]*CCRANDOM_MINUS1_1(),
			tangentialAccel = t["tangentialAcceleration"]+t["tangentialAccelVariance"]*CCRANDOM_MINUS1_1(),
			gravity = t["gravity"]
		},
		B = {
			angle = a,
			degreesPerSecond = CC_DEGREES_TO_RADIANS(t["rotatePerSecond"]+t["rotatePerSecondVariance"]*CCRANDOM_MINUS1_1()),
			radius = startRadius,
			deltaRadius = er
		},
		C = {
			wellPos = t["wellPos"],
			power = t["power"],
			epsilon = t["epsilon"],
			epsilonSq = t["epsilon"] * t["epsilon"],
			velX = 0,
			velY = 0
		}
	}
	p.active = true
	
end

function cEmitter:addParticle(x,y)
	local dIdx = self.deadParts[#deadParts]
	cEmitter:reset(self.particles[dIdx],self.template,x,y)
	table.remove(self.deadParts,1)
--[[
	for i=1,self.maxParticles,1 do
		if self.particles[i].active == false then
			cEmitter:reset(self.particles[i],self.template,x,y)
			break
		end
	end
]]
end

function cEmitter:play(dt,x,y,override)
	--local dt = event.deltaTime
	--in old event handler
--[[
	local dt = event.deltaTime
	
	local rate = 1/emitter.emissionRate
	emitCounter = emitCounter + dt
	while emitCounter > rate do
		emitter:addParticle(mx,my)
		particleCount = particleCount + 1
		emitCounter = emitCounter - rate
	end
	
	for i=1,emitter.maxParticles,1 do
		emitter:update(dt,emitter.particles[i])
	end
]]
	if self.active == false then return end
	
	local rate = 1/self.emissionRate
	self.emitCounter = self.emitCounter + dt
	while self.emitCounter > rate do
		for i=1,self.maxParticles,1 do
			if self.particles[i].active == false then
				cEmitter:reset(self.particles[i],self.template,x,y,override)
					--if #self.deadParts < 1 then break end
					--local dIdx = self.deadParts[#deadParts]
					--cEmitter:reset(self.particles[dIdx],self.template,x,y)
					--table.remove(self.deadParts,1)
				break
			end
		end
		self.particleCount = self.particleCount + 1
		self.emitCounter = self.emitCounter - rate
	end

	for i=1,self.maxParticles,1 do
		cEmitter:update(dt,self.particles[i],i)
	end
end

function cEmitter:stop()
	self.duration = nil
	self.active = false
	for i=1,self.maxParticles,1 do
		self.particles[i].sprite:setVisible(false)
	end
end

function cEmitter:start(dur)
	self.duration = dur
	self.active = true
end

function cEmitter:update(dt,p,idx)
	if p.active == false then return end
	--if not self.disabled then
	p.timeToLive = p.timeToLive - dt

	if p.pType == 1 or p.pType == 3 then
		local tmp = {x=0,y=0}
		local radial = {x=0,y=0}
		local tangential = {x=0,y=0}
		if p.pos.x or p.pos.y then
			radial = ccpNormalize(p.pos)
		end
		tangential = radial
		radial = ccpMult(radial,p.mode.A.radialAccel)
		local newy = tangential.x
		tangential.x = -tangential.y
		tangential.y = newy
		tangential = ccpMult(tangential,p.mode.A.tangentialAccel)
		tmp = ccpAdd(ccpAdd(radial,tangential),p.mode.A.gravity)
		tmp = ccpMult(tmp,dt)
		p.mode.A.dir = ccpAdd(p.mode.A.dir,tmp)
		tmp = ccpMult(p.mode.A.dir,dt)
		p.pos = ccpAdd(p.pos,tmp)
	end
	local rpx = 0
	local rpy = 0
	if p.pType == 2 then
	--[[
				// Update the angle and radius of the particle.
				p->mode.B.angle += p->mode.B.degreesPerSecond * dt;
				p->mode.B.radius += p->mode.B.deltaRadius * dt;
				
				p->pos.x = - cosf(p->mode.B.angle) * p->mode.B.radius;
				p->pos.y = - sinf(p->mode.B.angle) * p->mode.B.radius;
	]]
		p.mode.B.angle = p.mode.B.angle + p.mode.B.degreesPerSecond * dt
		p.mode.B.radius = p.mode.B.radius + p.mode.B.deltaRadius * dt
		--p.pos.x = -math.cos(p.mode.B.angle) * p.mode.B.radius
		--p.pos.y = -math.sin(p.mode.B.angle) * p.mode.B.radius
		rpx = -math.cos(p.mode.B.angle) * p.mode.B.radius
		rpy = -math.sin(p.mode.B.angle) * p.mode.B.radius
	end
	
	--color
	p.color.r =  p.color.r + ( p.deltaColor.r * dt )
	p.color.g =  p.color.g + ( p.deltaColor.g * dt )
	p.color.b =  p.color.b + ( p.deltaColor.b * dt )
	p.color.a =  p.color.a + ( p.deltaColor.a * dt )
	p.sprite:setColorTransform(p.color.r,p.color.g,p.color.b,p.color.a)
	
	--size
	p.size = p.size + (p.deltaSize * dt)
	p.size = MAX( 0, p.size)
	p.sprite:setScale(p.size,p.size)
	

	
	--local currentPosition = {x=self.sprite:getX(),y=self.sprite:getY()}
	local newpos = {x=0,y=0}
	local diff = ccpSub({x=0,y=0},p.startPos)
	newpos = ccpSub(p.pos,diff)
	newpos = p.pos
	newpos = ccpAdd(newpos,{x=rpx,y=rpy})
	
	if p.pType == 3 then
		--local x = newpos.x - p.mode.C.wellPos.x -- repel gravity
		--local y = newpos.y - p.mode.C.wellPos.y -- repel gravity
		local power = p.mode.C.power * p.mode.C.power
		local x = p.mode.C.wellPos.x - newpos.x
		local y = p.mode.C.wellPos.y - newpos.y
		local dSq = x * x + y * y
		local d = math.sqrt(dSq)
		if dSq < p.mode.C.epsilon then
			dSq = p.mode.C.epsilon
		end
		local factor = (p.mode.C.power * dt) / (dSq * dt)
		p.mode.C.velX = p.mode.C.velX + x * factor
		p.mode.C.velY = p.mode.C.velY + y * factor
		newpos.x = newpos.x + p.mode.C.velX
		newpos.y = newpos.y + p.mode.C.velY
	end
	
	
	local w = p.sprite:getWidth()
	local h = p.sprite:getHeight()
	p.sprite:setPosition(newpos.x,newpos.y)
	
	--angle
	p.rotation = p.rotation + (p.deltaRotation * dt)

	p.sprite:setRotation(p.rotation)
	
	--self.sprite:setRotation(self.rotation)

	--end
	--local i = idx
	--local dt = self.deadParts
	--print(dt)
	if p.timeToLive < 0 then
		--print("deadPart added",i)
		--table.insert(self.deadParts,i)
		p.active = false
		p.sprite:setVisible(false)
		return
	end
end

--[[
Sprite.ALPHA = "alpha"
Sprite.NO_ALPHA = "noAlpha"
Sprite.ADD = "add"
Sprite.MULTIPLY = "multiply"
Sprite.SCREEN = "screen"
Thx Atilim
]]

function cEmitter:setBlendMode(mode,spr)
	if type(mode) ~= "string" then
		error("bad argument #2 to 'setBlendMode' (string expected, got "..type(mode)..")")
	end
 
	if mode == "alpha" then
		spr:setBlendFunc(BlendFactor.SRC_ALPHA, BlendFactor.ONE_MINUS_SRC_ALPHA)
	elseif mode == "noAlpha" then
		spr:setBlendFunc(BlendFactor.ONE, BlendFactor.ZERO)
	elseif mode == "add" then
		spr:setBlendFunc(BlendFactor.SRC_ALPHA, BlendFactor.ONE)
	elseif mode == "multiply" then
		spr:setBlendFunc(BlendFactor.DST_COLOR, BlendFactor.ONE_MINUS_SRC_ALPHA)
	elseif mode == "screen" then
		spr:setBlendFunc(BlendFactor.ONE, BlendFactor.ONE_MINUS_SRC_COLOR)
	else
		error("Parameter 'blendMode' must be one of the accepted values.")
	end
end

function cEmitter:deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end