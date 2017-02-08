local anim8=require 'anim8'
local t={}
t.imgAnim=love.graphics.newImage("assets/animation/hp_anim.png")
t.grid = anim8.newGrid(48,36 , 192,36,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-4',1), 0.2)
t.w= 48
t.h= 36
t.life=6
t.isDead=false
t.once=false

function t:new(obj)
	obj={}
	obj.x=-100
	obj.y=-100
	obj.angle=math.rad(0)
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
	self.anim:update(dt)
	self.currentTime=love.timer.getTime()
	if self.currentTime-self.spawnTime>=self.life then
		self.isDead=true
	end

	local distance=-1
    local bulletR = self.w/2
    local enemyR = player_ship.w/2
    local tempX, tempY,tempAngle
    --use x and y to get the angle, then get the distance between two centers
    tempX=math.abs(self.x-player_ship.x)
    tempY=math.abs(self.y-player_ship.y)
    tempAngle=math.atan(tempY/tempX)
    distance=tempX/math.cos(tempAngle)
    if distance<= bulletR+enemyR then
    	--collision
    	if self.once==false then
    		self.once=true
    	    local numberofHP=0
	    	for i,v in ipairs(currentHealth) do
	    		numberofHP=numberofHP+1
	    	end

	        local hp = Init_Health()
			hp.x=currentHealth[numberofHP].x+40
	      	table.insert(currentHealth, hp)
	      	pickhp:stop()
	      	local vol=math.random(0.5,1)
      		pickhp:setVolume(vol)
	      	pickhp:play()	
	        self.isDead=true
    	end
	 
    else
        --no collision
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