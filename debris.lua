local t={}
t.img=love.graphics.newImage("assets/debris1.png")
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.life=1
t.isDead=false

function t:new(obj)
	obj={}
	obj.x=-100
	obj.y=-100
	obj.angle=math.rad(math.random(-180, 180))
	obj.newX=obj.x
	obj.newY=obj.y
	obj.speedX=0
	obj.speedY=0
	obj.spawnTime = love.timer.getTime()
	obj.currentTime=obj.spawnTime
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)

	self.currentTime=love.timer.getTime()
	if self.currentTime-self.spawnTime>=self.life then
		self.isDead=true
	end

	self.newX=self.x+self.speedX*dt
	self.newY=self.y+self.speedY*dt

	--teleport to another edge after out of boundary
	if self.newX>love.graphics.getWidth() then
	    self.newX= -self.w
	end
	if self.newY>love.graphics.getHeight() then
	    self.newY= -self.h
	end
	if self.newX+self.w<0 then
	    self.newX= love.graphics.getWidth()
	end
	if self.newY+self.h<0 then
	    self.newY= love.graphics.getHeight()
	end
	
	self.x=self.newX
	self.y=self.newY
end

return t