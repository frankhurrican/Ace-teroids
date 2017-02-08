local anim8=require 'anim8'
local t={}
--t.img=love.graphics.newImage("assets/debris1.png")
t.imgAnim=love.graphics.newImage("assets/animation/explosion1.png")
t.grid = anim8.newGrid(96,96 , 480,288,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-5','1-3'), 0.1)
t.w= 96
t.h= 96
t.life=1.5
t.isDead=false

function t:new(obj)
	obj={}
	
	obj.angle=math.rad(math.random(-180, 180))
	
	obj.spawnTime = love.timer.getTime()
	obj.currentTime=obj.spawnTime
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)
	self.anim:update(dt)
	self.currentTime=love.timer.getTime()
	if self.currentTime-self.spawnTime>=self.life then
		self.isDead=true
	end

end

return t