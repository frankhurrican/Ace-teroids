local anim8=require 'anim8'
local t={}
t.img=love.graphics.newImage("assets/player.png")
--animation test!!!!
t.imgAnim=love.graphics.newImage("assets/animation/player_anim.png")
t.grid = anim8.newGrid(48,75 , 144,75,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-3',1), 0.1)
--animation test ends!!!!!!     
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.x= love.graphics.getWidth()/2-t.w/2
t.y= love.graphics.getHeight()/2-t.h/2+200
t.newX=t.x
t.newY=t.y
t.scroe=0
t.speedX=0
t.speedY=0
t.maxX=5
t.maxY=5
t.angle=0
t.isDead=false
t.isImmune=false
t.dmgTime=0
	

function t:new(obj)
	obj=obj or {}
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)
	self.anim:update(dt)
	local currentTime=love.timer.getTime()
	if currentTime-self.dmgTime<=2 then
		self.isImmune=true
		self.imgAnim=love.graphics.newImage("assets/animation/player_dmg_anim.png")
	else
		self.isImmune=false
		self.imgAnim=love.graphics.newImage("assets/animation/player_anim.png")
	end

	--constant input handler
	if love.mouse.isDown(2) or love.keyboard.isDown("w") then --left button or key w is pressed
    	self.speedX=self.speedX+10*math.sin(self.angle)*dt
    	self.speedY=self.speedY-10*math.cos(self.angle)*dt
   	end

	--update player rotation
	self:angleUpdate()

	--player moves with speed, get new position
	self.newX=self.x+self.speedX
	self.newY=self.y+self.speedY
	
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

	--current position equals to new position
	self.x=self.newX
	self.y=self.newY
end

function t:angleUpdate()
	--player angle, changing with mouse movement
	local xc = love.mouse.getX()
	local yc = love.mouse.getY()
	local xp = self.x
	local yp = self.y
	--use cotan function to get the correct angle of player
	if xc-xp>0 then
		if yp-yc>0 then
			self.angle=math.atan((xc-xp)/(yp-yc))
		else
			self.angle=math.atan((yc-yp)/(xc-xp))+(math.pi/2)
		end
	end
	if xc-xp<0 then
		if yp-yc>0 then
			self.angle=math.atan((xp-xc)/(yp-yc))*(-1)
		else
			self.angle=(math.atan((xp-xc)/(yc-yp))+math.pi)
		end
	end
	if xc==xp then
		if yp>=yc then
			self.angle=0
		else self.angle=math.pi
		end
	end
end

return t