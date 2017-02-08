local anim8=require 'anim8'
local t={}
--t.img=love.graphics.newImage("assets/debris1.png")
t.imgAnim=love.graphics.newImage("assets/animation/explosion_anim.png")
t.grid = anim8.newGrid(128,128 , 640,128,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-5',1), 0.1)
t.w= 128
t.h= 128
t.life=0.49
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