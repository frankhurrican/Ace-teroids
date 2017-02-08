local anim8=require 'anim8'
local t={}
t.img=love.graphics.newImage("assets/enemyL.png")
t.imgAnim=love.graphics.newImage("assets/animation/enemyL_anim.png")
t.grid = anim8.newGrid(78,90 , 156,90,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-2',1), 0.1)
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.isDead=false
t.i=0
t.counter=0
t.asinCord=-math.pi/2
t.iCounter=0
t.smooth=false
t.fireDelay=2

function t:new(obj,x0,y0)
	obj={} or obj
	obj.x=x0
	obj.y=y0
	obj.angle=math.rad(180)
	obj.newX=obj.x
	obj.newY=obj.y
	obj.oriX=obj.x
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
	if self.currentTime-self.spawnTime>=self.fireDelay then
		local ebullet = Init_EnemyBullet(self.x,self.y,30,40,0,0,0)
		local ebullet2 = Init_EnemyBullet(self.x,self.y,-30,40,0,0,0)
		table.insert(enemyBullets, ebullet)
		table.insert(enemyBullets, ebullet2) 
		self.spawnTime=love.timer.getTime() 	
	end

	if self.counter<=100 then
		--straight line phase
		self.newY=self.y+1
		if self.y>50 then
		self.counter=self.counter+1
		end
	
	-----straight line phase ends-----
	else
		if self.iCounter>0 then
			self.newX=self.x+1
			self.iCounter=self.iCounter+1
			if self.iCounter==100 then
				self.iCounter=-1
			end
		else
			self.newX=self.x-1
			self.iCounter=self.iCounter-1
			if self.iCounter==-100 then
				self.iCounter=1
			end
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
        self.isDead=true
    else
        --no collision
    end
    --collision with player ends


	--teleport to another edge after out of boundary
	
	if self.newY-self.h/2>love.graphics.getHeight() then
	    self.newY= -self.h
	    self.i=0
	    self.counter=0
	    self.asinCord=-math.pi/2
	    self.iCounter=0
	    self.angle=math.rad(180)
	    self.oriX=self.x
	    self.smooth=false
	end


	self.x=self.newX
	self.y=self.newY
end

return t


