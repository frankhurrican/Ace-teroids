local t={}
t.img=love.graphics.newImage("assets/enemyM1.png")
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.isDead=false

function t:new(obj)
	obj={}
	obj.x=-100
	obj.y=-100
	obj.angle=math.rad(math.random(-180, 180))
	obj.newX=obj.x
	obj.newY=obj.y
	obj.speedX=math.random(-120, 120)
	obj.speedY=math.random(-120, 120)
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)

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