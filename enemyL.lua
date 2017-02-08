--local anim8=require 'anim8' animation works so dont care!
local t={}
t.img=love.graphics.newImage("assets/enemyL1.png")
--t.imgAnim=love.graphics.newImage("assets/animation/enemyL_anim.png") animation works so dont care!
--t.grid = anim8.newGrid(78 ,90 , 156, 90,  0,0,   0) animation works so dont care!
--t.anim   = anim8.newAnimation(t.grid('1-2',1), 0.4) animation works so dont care!
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.isDead=false

function t:new(obj)

	local ranPositionX,ranPositionY
	local validPosition=false
    while validPosition==false do
        ranPositionX=math.random (0,love.graphics.getWidth())
        ranPositionY=math.random (0,love.graphics.getHeight())
        if  ranPositionX<300 or ranPositionX>700 then
            validPosition=true
        elseif ranPositionY<200 or ranPositionY>600 then
            validPosition=true
        end
    end

	obj={}
	obj.x=ranPositionX
	obj.y=ranPositionY
	obj.angle=math.rad(math.random(-180, 180))
	obj.newX=obj.x
	obj.newY=obj.y
	obj.speedX=math.random(-80, 80)
	obj.speedY=math.random(-80, 80)
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)
	--self.anim:update(dt) animation works so dont care!
	--detect collision with player
	local distance=-1
    local bulletR = self.w/2
    local enemyR = player_ship.w/2
    local tempX, tempY,tempAngle
    --use x and y to get the angle, then get the distance between two centers
    tempX=math.abs(self.x-player_ship.x)
    tempY=math.abs(self.y-player_ship.y)
    tempAngle=math.atan(tempY/tempX)
    distance=tempX/math.cos(tempAngle)
    if distance<= bulletR+enemyR and player_ship.isImmune==false then
    	--collision
        local lastHP=0
        for i,v in ipairs(currentHealth) do
            lastHP=lastHP+1
        end
        if lastHP==1 then
            table.remove(currentHealth,lastHP)
            player_ship.isDead=true
            deathTime=love.timer.getTime()
        else
            table.remove(currentHealth,lastHP)
            hurt:stop()
            hurt:play() 
            player_ship.dmgTime=love.timer.getTime()
        end
        self.isDead=true
    else
        --no collision
    end
    --collision with player ends

	self.newX=self.x+self.speedX*dt
	self.newY=self.y+self.speedY*dt

	--teleport to another edge after out of boundary
	if self.newX-self.w>love.graphics.getWidth() then
	    self.newX= -self.w/2
	end
	if self.newY-self.h>love.graphics.getHeight() then
	    self.newY= -self.h/2
	end
	if self.newX+self.w<0 then
	    self.newX= love.graphics.getWidth()+self.w/2
	end
	if self.newY+self.h<0 then
	    self.newY= love.graphics.getHeight()+self.h/2
	end
	
	self.x=self.newX
	self.y=self.newY
end

return t