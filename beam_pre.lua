local anim8=require 'anim8'
local t={}

t.imgAnim=love.graphics.newImage("assets/animation/beam_pre_anim.png")
t.grid = anim8.newGrid(36,34 , 360,34,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-10',1), 0.1)
t.isDead=false
t.life=1

function t:new(obj,x0,y0)
	obj={} or obj
	obj.x=x0
	obj.y=y0
	obj.angle=math.rad(180)
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
		--spawn true beam
		beams={}
		local beam1 = Init_Beam(obj,self.x,self.y)
    	table.insert(beams, beam1)
	end

	

	--detect collision with player
	local distance=-1
    local bulletR = 36/2
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
    else
        --no collision
    end
    --collision with player ends
	

	self.x=finalboss.x
	self.y=finalboss.y+100
end

return t


