local anim8=require 'anim8'
local t={}
t.img=love.graphics.newImage("assets/bullet.png")
t.imgAnim=love.graphics.newImage("assets/animation/bullet_anim.png")
t.grid = anim8.newGrid(15,15 , 30,15,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-2',1), 0.2)
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.life=4
t.isDead=false

function t:new (x0,y0,offX,offY,angle,sx,sy)
	obj={}
	direction = angle
    
    if direction==math.rad(0) then
        obj.x = x0 + offX
        obj.y = y0 + offY
        obj.speedX = 0
        obj.speedY = 250
    else
        obj.x = x0 + 24*math.sin(direction)*2 
        obj.y = y0 - 24*math.cos(direction)*2 
        obj.speedX = sx+ math.sin(direction)*400
        obj.speedY = sy-math.cos(direction)*400
    end

    obj.newX=obj.x
    obj.newY=obj.y
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

	self.x=self.newX
	self.y=self.newY
end

return t