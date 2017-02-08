local anim8=require 'anim8'
local t={}
t.imgAnim=love.graphics.newImage("assets/animation/beam_anim.png")
t.grid = anim8.newGrid(60,458 , 600, 458,  0,0,   0)
t.anim   = anim8.newAnimation(t.grid('1-10',1), 0.1)
t.isDead=false
t.life=1

function t:new(obj,x0,y0)
	obj={} or obj
	obj.x=x0
	obj.y=y0
	obj.angle=math.rad(0)
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

	--detect collision with player---------------------------this cannot using the circle one
	local xmin=self.x-45
	local xmax=self.x+45
	if (player_ship.x-player_ship.w/2>xmin) and (player_ship.x-player_ship.w/2<xmax) and player_ship.isImmune==false then
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
    elseif (player_ship.x+player_ship.w/2>xmin) and (player_ship.x+player_ship.w/2<xmax) and player_ship.isImmune==false then
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
    end
    --collision with player ends

	self.x=finalboss.x-28
	self.y=finalboss.y+90
end

return t


