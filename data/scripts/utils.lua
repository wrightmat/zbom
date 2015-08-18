
--[[
float clampf(float value, float min_inclusive, float max_inclusive)
{
	if (min_inclusive > max_inclusive) {
		CC_SWAP(min_inclusive,max_inclusive);
	}
	return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}
]]

function clampf(value,min_inclusive,max_inclusive)
	if value < min_inclusive then value = min_inclusive end
	if value > max_inclusive then value = max_inclusive end
	return value
end

function CCRANDOM_MINUS1_1()
	return (((math.random(1000)*.001)*-1) + (math.random(1000)*.001)*1)
end

function CC_DEGREES_TO_RADIANS(a)
	return a * 0.01745329252
end

function CC_RADIANS_TO_DEGREES(r)
	return r * 57.29577951
end

function MAX(a,b)
	if a > b then return a end
	return b
end

function MIN(a,b)
	if a < b then return a end
	return b
end

function CCRANDOM_0_1()
	return math.random()
end

function ccpNEG(v)
	return { x = -v.x, y =- v.y }
end

function ccpMult(v,s)
	return { x = v.x*s, y = v.y*s }
end

function ccpAdd(v1,v2)
	return { x = v1.x + v2.x, y = v1.y + v2.y }
end

function ccpSub(v1,v2)
	return { x = v1.x - v2.x, y = v1.y - v2.y }
end

function ccpMidpoint(v1,v2)
	return ccpMult(ccpAdd(v1,v2),0.5)
end

function ccpDot(v1,v2)
	return v1.x*v2.x + v1.y*v2.y
end

function ccpCross(v1,v2)
	return v1.x*v2.y - v1.y*v2.x
end

function ccpPerp(v)
	return { x = -v.y, y = v.x }
end

function ccpRPerp(v)
	return { x = v.y, y = -v.x }
end

function ccpProject(v1,v2)
	return ccpMult(v2,ccpDot(v1,v2)/ccpDot(v2,v2))
end

function ccpRotate(v1,v2)
	return { x = v1.x*v2.x - v1.y*v2.y, y = v1.x*v2.y + v1.y*v2.x }
end

function ccpUnrotate(v1,v2)
	return { x = v1.x*v2.x + v1.y*v2.y, y = v1.y*v2.x - v1.x*v2.y }
end

function ccpLengthSQ(v)
	return ccpDot(v,v)
end

function ccpLength(v)
	return math.sqrt(ccpLengthSQ(v))
end

function ccpDistance(v1,v2)
	return ccpLength(ccpSub(v1,v2))
end

function ccpNormalize(v)
	return ccpMult(v,1.0/ccpLength(v))
end

function ccpForAngle(a)
	return { x = math.cos(a), y = math.sin(a) }
end

function ccpToAngle(v)
	return math.atan2(v.y,v.x)
end

function ccpLerp(a,b,alpha)
	ccpAdd(ccpMult(a, 1.0 - alpha), ccpMult(b, alpha))
end

function ccpFromSize(s)
	return { x = s.width, y = s.height }
end

function ccpFuzzyEqual(a,b,var)
	if a.x-var <= b.x and b.x <= a.x + var then
		if a.y - var <= b.y and b.y <= a.y + var then
			return true
		end
	end
	return false
end

function ccpCompMult(a,b)
	return { x = a.x * b.x, y = a.y*b.y }
end

function ccpAngleSigned(a,b)
	local a2 = ccpNormalize(a)
	local b2 = ccpNormalize(b)
	local angle = math.atan2(a2.x*b2.y - a2.y*b2.x, ccpDot(a2,b2))
	-- kCGPointEpsilon = .0000001192092896
	if math.abs(angle) < .0000001192092896 then return 0 end
	return angle
end

function ccpRotateByAngle(v,pivot,angle)
	local r = ccpSub(v,pivot)
	local cosa = math.cos(angle)
	local sina = math.sin(angle)
	local t = r.x
	r.x = t*cosa - r.y*sina + pivot.x
	r.y = t*sina + r.y*cosa + pivot.y
	return r
end

function ccpSegmentIntersect(A,B,C,D)
	local S,T = 0,0
	local li = ccpLineIntersect(A,B,C,D,S,T)
	if li[1] and (li[2] >= 0 and li[2] <= 1 and li[3]>=0 and li[3] <= 1) then
		return true
	end	
	return false
		

end

function ccpIntersectPoint(A,B,C,D)
	local S,T = 0,0
	local li = ccpLineIntersect(A, B, C, D, S, T)
	if li[1] then
		local p = {
			x = A.x + li[2] * (B.x - A.x),
			y = A.y + li[2] * (B.y - A.y)
		}
		return p
		
	end
	return { x=0,y=0 }
end

function ccpLineIntersect(A,B,C,D,s,t)
	if (A.x == B.x and A.y == B.y) or (C.x == D.x and C.y == D.y) then return {false,s,t} end
	
	local BAx = B.x - A.x
	local BAy = B.y - A.y
	local DCx = D.x - c.x
	local DCy = D.y - C.y
	local ACx = A.x - C.x
	local ACy = A.y - C.y
	
	local denom = DCy*BAx - DCx*BAy
	
	s = DCx*ACy - DCy*ACx
	t = BAx*ACy - BAy*ACx
	
	if denom == 0 then
		if s == 0 or t == 0 then
			return {true,s,t}
		end
		return {false,s,t}
	end
	
	s = s / denom;
	t = t / denom;
	
	return {true,s,t}
end

function ccpAngle(a,b)
	local angle = math.acos(ccpDot(ccpNormalize(a), ccpNormalize(b)))
	--kCGPointEpsilon = .0000001192092896
	if math.abs(angle) < .0000001192092896 then return 0 end
	return angle
end