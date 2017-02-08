local anim8=require 'anim8'
local t={}

t.imgAnim=love.graphics.newImage("assets/animation/bomb_anim.png")
t.grid = anim8.newGrid(134,134 , 1072,134,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-8',1), 0.1)
t.w=134
t.h= 134
t.isDead=false
t.i=0
t.counter=0
t.asinCord=-math.pi/2
t.iCounter=0
t.reached=false
t.life=3
t.doOnce=false

function t:new(obj,x0,y0)
	local obj={} or obj
	obj.x=x0
	obj.y=y0
	obj.angle=math.rad(180)
	obj.newX=obj.x
	obj.newY=obj.y
	obj.oriX=obj.x
	obj.distanceToGo=math.random(100,500)
	obj.speedX=0
	obj.speedY=0
	obj.spawnTime = love.timer.getTime()
    obj.currentTime=obj.spawnTime
    stage3=true
	setmetatable(obj, t)
    self.__index = self
	return obj
end
function t:UpdateAnim(dt)
	self.anim:update(dt)
end	

function t:Update(dt)
	

	self.currentTime=love.timer.getTime()
	if self.currentTime-self.spawnTime>=self.life then
		--self.isDead=true
	end

	if self.counter<=self.distanceToGo then
		--self.anim:gotoFrame(1)
		--straight line phase
		self.newY=self.y+2
		--if self.y>50 then
		self.counter=self.counter+2
		--end
	
	-----straight line phase ends-----
	else
		
		
	end
	
	for i,v in ipairs(bullets) do 
		 local distance=-1
        local bulletR = self.w/2
        local enemyR = v.w/2
        local tempX, tempY,tempAngle
        --use x and y to get the angle, then get the distance between two centers
        tempX=math.abs(self.x-v.x)
        tempY=math.abs(self.y-v.y)
        tempAngle=math.atan(tempY/tempX)
        distance=tempX/math.cos(tempAngle)
        if distance<= bulletR+enemyR then
            --collision
            v.isDead=true
        else
            --no collision
        end
	end	
	
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
        --self.isDead=true
    else
        --no collision
    end
    --collision with player ends


	self.x=self.newX
	self.y=self.newY
end

return t


