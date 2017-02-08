local anim8=require 'anim8'
local t={}
t.img=love.graphics.newImage("assets/laser.png")
t.imgAnim=love.graphics.newImage("assets/animation/laser_anim.png")
t.grid = anim8.newGrid(15,36 , 30,36,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-2',1), 0.1)
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.life=1
t.isDead=false

function t:new (player)
	obj={}
	direction = player.angle
    obj.x = player.x + player.w/2*math.sin(direction)*2	
    obj.y = player.y - player.w/2*math.cos(direction)*2
    obj.newX=obj.x
    obj.newY=obj.y
    obj.angle=player.angle
    obj.speedX = player.speedX + math.sin(direction) * 700
    obj.speedY = player.speedY - math.cos(direction) * 700
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

	--bullet collision
    for i,v in ipairs(enemyShips) do --detect collision with enemy ships
        --get radius (approximate) of asteroids and bullets, initial distance
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
            self.isDead=true
            score=score+1

            local chance= math.random (0,100)
            if chance>60 then--------------------------------------------------------------spawn health pickup
                local hPick=Init_HealthPickup()
                hPick.x=v.x
                hPick.y=v.y
                hPick.speedX=math.random (-25,25)
                hPick.speedY=math.random (-25,50)
                table.insert(hPicks,hPick)
            end
        else
            --no collision
        end
    end

    for i,v in ipairs(bossSpawn) do --detect collision with enemy ships
        --get radius (approximate) of asteroids and bullets, initial distance
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
            self.isDead=true
            score=score+1

            local chance= math.random (0,100)
            if chance>75 then--------------------------------------------------------------spawn health pickup
                local hPick=Init_HealthPickup()
                hPick.x=v.x
                hPick.y=v.y
                hPick.speedX=math.random (-25,25)
                hPick.speedY=math.random (-25,50)
                table.insert(hPicks,hPick)
            end
        else
            --no collision
        end
    end

    for i,v in ipairs(enemyShipsLarge) do --detect collision with enemy ships
        --get radius (approximate) of asteroids and bullets, initial distance
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
            self.isDead=true
            score=score+1
        else
            --no collision
        end
    end

	for i,v in ipairs(enemies) do --detect collision with large enemies
 		--get radius (approximate) of asteroids and bullets, initial distance
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
        	self.isDead=true
        	score=score+1
        else
            --no collision
        end
	end
	for i,v in ipairs(enemiesM) do --detect collision with medium enemies
 		--get radius (approximate) of asteroids and bullets, initial distance
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
        	self.isDead=true
        	score=score+1
        else
            --no collision
        end
	end
	for i,v in ipairs(enemiesS) do --detect collision with small enemies
 		--get radius (approximate) of asteroids and bullets, initial distance
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
        	self.isDead=true
        	score=score+1

            local chance= math.random (0,100)
            if chance>80 then--------------------------------------------------------------spawn health pickup
                local hPick=Init_HealthPickup()
                hPick.x=v.x
                hPick.y=v.y
                hPick.speedX=math.random (-25,25)
                hPick.speedY=math.random (-25,50)
                table.insert(hPicks,hPick)
            end
        else
            --no collision
        end
	end
    if finalboss.isDead==false then
        
        local distance=-1
        local bulletR = self.w/2
        local enemyR = finalboss.w/2
        local tempX, tempY,tempAngle
        --use x and y to get the angle, then get the distance between two centers
        tempX=math.abs(self.x-finalboss.x)
        tempY=math.abs(self.y-finalboss.y)
        tempAngle=math.atan(tempY/tempX)
        distance=tempX/math.cos(tempAngle)
        if distance<= bulletR+enemyR then
            --collision
            local lastHP=0
            for i,v in ipairs(currentBossHealth) do
                lastHP=lastHP+1
            end
            if lastHP==1 then
                table.remove(currentBossHealth,lastHP)
                finalboss.hp=finalboss.hp-1
                finalboss.isDead=true
                bossDeathTime = love.timer.getTime()
                finalExplosion=Init_FinalExplosion()
                win=true
                score=score+100
                local expTest= Init_Explosion()
                expTest.x=finalboss.x
                expTest.y=finalboss.y
                table.insert(explosions, expTest)
                
            else
                table.remove(currentBossHealth,lastHP)
                finalboss.hp=finalboss.hp-1
                score=score+1
                bosshurt:stop()
                local vol=math.random(0.2,0.6)
                bosshurt:setVolume(vol)
                bosshurt:play()   
            end
            self.isDead=true
            
        else
            --no collision
        end
    end
	--bullet collision ends

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