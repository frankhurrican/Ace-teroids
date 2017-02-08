local anim8=require 'anim8'
local t={}
t.img=love.graphics.newImage("assets/boss.png")
t.imgAnim=love.graphics.newImage("assets/animation/boss_anim.png")
t.grid = anim8.newGrid(220,210 , 440,210,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-2',1), 0.1)
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.isDead=false
t.i=0
t.counter=0
t.asinCord=-math.pi/2
t.iCounter=0
t.first=true
t.hp=35
t.spawnTime=0
t.doOnce=false
t.doOnce2=false
t.created=false

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
	setmetatable(obj, t)
    self.__index = self
	return obj
end

function t:Update(dt)
	self.anim:update(dt)
	if self.counter<=150 then
	    --do
	
		--straight line phase
		self.newY=self.y+2
		if self.y>50 then
		self.counter=self.counter+2
		end

	-----straight line phase ends-----
	else
		if self.first==true then
			if self.iCounter>=0 then
				self.newX=self.x+2
				self.iCounter=self.iCounter+1
				if self.iCounter==200 then
					self.iCounter=-1
				end
			else
				self.newX=self.x-2
				self.iCounter=self.iCounter-1
				if self.iCounter==-400 then
					self.iCounter=1
					self.first=false
				end
			end
		else
		    if self.iCounter>=0 then
				self.newX=self.x+2
				self.iCounter=self.iCounter+1
				if self.iCounter==400 then
					self.iCounter=-1
				end
			else
				self.newX=self.x-2
				self.iCounter=self.iCounter-1
				if self.iCounter==-400 then
					self.iCounter=1
					self.first=false
				end
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
        --self.isDead=true
    else
        --no collision
    end
    --collision with player ends

    --attacking phase
    if self.hp>24 then
    	if love.timer.getTime() - self.spawnTime>=2 then
    	    self.spawnTime=love.timer.getTime()
    	    local enemyShipTest = Init_EnemyShip(obj,self.x,self.y)
    		table.insert(bossSpawn, enemyShipTest)
    		local ebullet = Init_EnemyBullet(self.x,self.y,45,100,0,0,0)
			local ebullet2 = Init_EnemyBullet(self.x,self.y,-45,100,0,0,0)
			table.insert(enemyBullets, ebullet)
			table.insert(enemyBullets, ebullet2) 
    	end

    elseif self.hp>12 and self.hp<=24 then
    	if self.doOnce==false then
	        for i,v in ipairs(currentBossHealth) do
	    		v.img=love.graphics.newImage("assets/bosshp_mid.png") 
	    	end
	    	self.doOnce=true
    	end
    	if love.timer.getTime() - self.spawnTime>=3 then
    	    self.spawnTime=love.timer.getTime()
    	    beamPre={}
    	    
    	    local beamPre1 = Init_BeamPre(obj,self.x,self.y)
    	    table.insert(beamPre, beamPre1)

    	    local ebullet = Init_EnemyBullet(self.x,self.y,45,100,0,0,0)
			local ebullet2 = Init_EnemyBullet(self.x,self.y,-45,100,0,0,0)
			local ebullet3 = Init_EnemyBullet(self.x,self.y,90,100,0,0,0)
			local ebullet4 = Init_EnemyBullet(self.x,self.y,-90,100,0,0,0)
			table.insert(enemyBullets, ebullet)
			table.insert(enemyBullets, ebullet2) 
			table.insert(enemyBullets, ebullet3)
			table.insert(enemyBullets, ebullet4) 
    	    
    	end

    else
    	if self.doOnce2==false then
    	    for i,v in ipairs(currentBossHealth) do
    		v.img=love.graphics.newImage("assets/bosshp.png") 
    		end
    		self.doOnce2=true
    	end
    	
    	if love.timer.getTime() - self.spawnTime>=2 and self.isDead==false then
    		self.spawnTime=love.timer.getTime()
    		local bomb1 = Init_Bomb(obj,self.x,self.y+100)
    		table.insert(bombs, bomb1)
    		self.created=true
    		
    	end
    	if self.created==true and self.isDead==false then
    	    bombs[1]:UpdateAnim(dt)
    	end
    	
    end
    --attack phase ends


	self.x=self.newX
	self.y=self.newY
end

return t