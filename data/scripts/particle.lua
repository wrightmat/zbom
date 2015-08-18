local particle = {}

function particle:initialize(s)
  self.sprite = s
  self.XPos = math.random(400)
  self.YPos = math.random(400)
  self.XVel = 0
  self.YVel = 0
  self.XThrust = 0
  self.YThrust = 0
  self.Thrust = 0
  self.Active = false
  self.Next = {}
end

function particle:run()
  self.XPos = self.XPos + self.XThrust * self.Thrust
  self.YPos = self.YPos + self.YThrust * self.Thrust
  self.Thrust = self.Thrust / 1.01;
  self.sprite:setPosition(self.XPos,self.YPos)
end