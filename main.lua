--load all classes
local Background=require ("background")
local Player=require ("player")
local Bullet=require ("bullet")
local EnemyL=require("enemyL")
local EnemyM=require("enemyM")
local EnemyS=require("enemyS")
local Debris=require("debris")
local EnemyShip=require("enemyShip")
local EnemyShipL=require("enemyShipL")
local Explosion=require("explosion")
local FinalExplosion=require("finalExplosion")
local Boss=require("boss")
local EnemyBullet=require("enemyBullet")
local Health=require("health")
local BossHealth=require("bossHealth")
local BeamPre=require("beam_pre")
local Beam=require("beam")
local HealthPickup=require("healthPickup")
local Bomb=require("bomb")

local anim8=require 'anim8'
local image,animation --test
local startScale=1
local optionScale=1
local exitScale=1
local instructionScale=1
local onStart=false
local onOption=false
local onExit=false
local onInstruction=false
local gameRunning=false

stage3=false

bullets={}
enemies={}
enemiesM={}
enemiesS={}
debris={}
enemyShips={}
bossSpawn={}
enemyShipsLarge={}
explosions={}
finalboss={}
enemyBullets={}
currentHealth={}
currentBossHealth={}
beamPre={}
beams={}
hPicks={}
bombs={}
bossDeathTime={}
finalExplosion={}

player_ship={}
deathTime=-1
afterDeathTime=-1
win=false

local doOnce=false
local doOnceBoss=false
local inMainMenu=true
score_label = "Score: "
score = 0

bgm_menu= love.audio.newSource("assets/sound/menu.mp3")
bgm_normal= love.audio.newSource("assets/sound/normal.mp3")
bgm_boss= love.audio.newSource("assets/sound/boss.mp3")
bgm_win= love.audio.newSource("assets/sound/win.mp3")
bgm_menu:setVolume(0.75)
bgm_normal:setVolume(0.75)
bgm_boss:setVolume(0.75)
shoot= love.audio.newSource("assets/sound/shoot.ogg", "static")
resize= love.audio.newSource("assets/sound/resize.ogg", "static")
boom= love.audio.newSource("assets/sound/boom.ogg", "static")
crack= love.audio.newSource("assets/sound/crack.ogg", "static")
pickhp= love.audio.newSource("assets/sound/pickhp.ogg", "static")
bosshurt= love.audio.newSource("assets/sound/bosshurt.ogg", "static")
hurt= love.audio.newSource("assets/sound/hurt.ogg", "static")
bossboom= love.audio.newSource("assets/sound/bossboom.ogg", "static")

function Init_Background ()
	return Background:new()
end
function Init_Health ()
	return Health:new()
end
function Init_Player ()
	return Player:new()
end
function Init_Bullet()
	return Bullet:new(player_ship)
end
function Init_EnemyL()
	return EnemyL:new()
end
function Init_EnemyM()
	return EnemyM:new()
end
function Init_EnemyS()
	return EnemyS:new()
end
function Init_Debris()
	return Debris:new()
end
function Init_HealthPickup()
	return HealthPickup:new()
end

function Init_Explosion()
	return Explosion:new()
end
function Init_FinalExplosion()
	return FinalExplosion:new()
end
function Init_Boss(obj,x1,y1)
	return Boss:new(obj,x1,y1)
end
function Init_EnemyShip(obj,x1,y1)
	return EnemyShip:new(obj,x1,y1)
end
function Init_EnemyShipL(obj,x1,y1)
	return EnemyShipL:new(obj,x1,y1)
end
function Init_Bomb(obj,x1,y1)
	return Bomb:new(obj,x1,y1)
end
function Init_EnemyBullet(x1,y1,offX1,offY1,angle1,sx1,sy1)
	return EnemyBullet:new(x1,y1,offX1,offY1,angle1,sx1,sy1)
end
function Init_BossHealth ()
	return BossHealth:new()
end
function Init_BeamPre (obj,x1,y1)
	return BeamPre:new(obj,x1,y1)
end
function Init_Beam (obj,x1,y1)
	return Beam:new(obj,x1,y1)
end

function Init_Level()
	bgm_menu:stop()
	bgm_boss:stop()
	bgm_normal:play()
	cursor = love.graphics.newImage('assets/crosshair1.png')
	score=0
	bullets={}
	enemies={}
	enemiesM={}
	enemiesS={}
	debris={}
	hpicks={}
	currentHealth={}

	currentBossHealth={}
	
	explosions={}
	player_ship=Init_Player()
	doOnce=false
	for i=0, 4 do
		local enemy = Init_EnemyL()
      	table.insert(enemies, enemy)
    end 
    for i=0, 2 do
		local hp = Init_Health()
		hp.x=hp.x+i*40
      	table.insert(currentHealth, hp)
    end
    
    enemyShips={}
	enemyShipsLarge={}
	finalboss={}
	enemyBullets={}
	bossSpawn={}
	beamPre={}
	beams={}
	bombs={}
end	

function Init_Level_stage2()
	enemyShips={}
	enemyShipsLarge={}
	doOnceBoss=false
	local enemyShipTest = Init_EnemyShip(obj,250,0)
    table.insert(enemyShips, enemyShipTest)
    local enemyShipTest1 = Init_EnemyShip(obj,450,0)
    table.insert(enemyShips, enemyShipTest1)
    local enemyShipTest2 = Init_EnemyShip(obj,650,0)
    table.insert(enemyShips, enemyShipTest2)

    local enemyShipTestLarge = Init_EnemyShipL(obj,150,0)
    table.insert(enemyShipsLarge, enemyShipTestLarge)
    local enemyShipTestLarge1 = Init_EnemyShipL(obj,350,0)
    table.insert(enemyShipsLarge, enemyShipTestLarge1)
    local enemyShipTestLarge2 = Init_EnemyShipL(obj,550,0)
    table.insert(enemyShipsLarge, enemyShipTestLarge2)
    local enemyShipTestLarge2 = Init_EnemyShipL(obj,750,0)
    table.insert(enemyShipsLarge, enemyShipTestLarge2)
end

function Init_Level_boss()
	bgm_menu:stop()
	bgm_boss:play()
	bgm_normal:stop()
	finalboss=Init_Boss(obj,450,0)
	for i=0, finalboss.hp do
		local bhp = Init_BossHealth()
		bhp.x=bhp.x+i*18
      	table.insert(currentBossHealth, bhp)
    end
    --local boss1 = Init_Boss(obj,450,0)
    --table.insert(finalboss, boss1)
end

function Draw_Menu()
	bgm_menu:play()
	bgm_boss:stop()
	bgm_normal:stop()
	inMainMenu=true
	love.graphics.draw(love.graphics.newImage("assets/menu/logo.png"), 100, 10,0 , 1, 1, 0, 0)
	love.graphics.draw(love.graphics.newImage("assets/menu/start.png"), 450, 556,0 , startScale, startScale, 225, 50.5)
	love.graphics.draw(love.graphics.newImage("assets/menu/option1.png"), 450, 687,0 , optionScale, optionScale, 225, 50.5)
	love.graphics.draw(love.graphics.newImage("assets/menu/exit.png"), 450, 818,0 , exitScale, exitScale, 225, 50.5)
end

function Draw_Instruction()
	inMainMenu=false
	love.graphics.draw(love.graphics.newImage("assets/menu/instruction.png"), 100, 100,0 , 1, 1, 0, 0)
	love.graphics.draw(love.graphics.newImage("assets/menu/back.png"), 450, 818,0 , instructionScale, instructionScale, 225, 50.5)
end

function Draw_Game_Content()
	--draw player, (IMG,position of Y,position of Y, rotation, scale of X, scale of Y, origin of X, origon of Y). origin decide how to rotate
	if player_ship.isDead==false then
		--love.graphics.draw(player_ship.img, player_ship.x, player_ship.y, player_ship.angle, 1, 1, player_ship.w/2, player_ship.h/2)
		--animation test!!!!!
		player_ship.anim:draw(player_ship.imgAnim, player_ship.x, player_ship.y, player_ship.angle, 1, 1, player_ship.w/2, player_ship.h/2)
		--test ends
		
		--testing enemyship
		for i,v in ipairs(enemyBullets) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.newX, v.newY, 0, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
				table.remove(enemyBullets,i)
			end
		end
		for i,v in ipairs(enemyShips) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
				local expTest= Init_Explosion()
				expTest.x=v.x 
				expTest.y=v.y 
	    		table.insert(explosions, expTest)
	    		boom:stop()
	    		boom:play()
				table.remove(enemyShips,i)
			end
		end

		for i,v in ipairs(bombs) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
			
				table.remove(bombs,i)
			end
		end

		for i,v in ipairs(bossSpawn) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
				local expTest= Init_Explosion()
				expTest.x=v.x 
				expTest.y=v.y 
	    		table.insert(explosions, expTest)
	    		boom:stop()
	    		boom:play()
				table.remove(bossSpawn,i)
			end
		end

		for i,v in ipairs(enemyShipsLarge) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
				local expTest= Init_Explosion()
				expTest.x=v.x 
				expTest.y=v.y 
	    		table.insert(explosions, expTest)
	    		boom:stop()
	    		boom:play()
				table.remove(enemyShipsLarge,i)
			end
		end



		for i,v in ipairs(beamPre) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 2, 2, 36/2, 34/2)
			else 
				table.remove(beamPre,i)
			end
		end
		for i,v in ipairs(beams) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 2, 2, 36/2, 0)
			else 
				table.remove(beams,i)
			end
		end

		
		--testing enemyship ends


		for i,v in ipairs(bullets) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.newX, v.newY, 0, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
			else 
				table.remove(bullets,i)
			end
		end

		for i,v in ipairs(enemies) do
			if v.isDead==false then
				love.graphics.draw(v.img, v.newX, v.newY, v.angle, 1, 1, v.w/2,v.h/2)
			else
		    	--spawn smaller enemies
		    	for i=0, 1 do
					local enemyM = Init_EnemyM()
					enemyM.x=v.x
					enemyM.y=v.y
	      			table.insert(enemiesM, enemyM)
	      			crack:stop()
	      			local vol=math.random(0.2,0.6)
      				crack:setVolume(vol)
	      			crack:play()
	    		end
	    		table.remove(enemies,i)
			end
		end
		
		for i,v in ipairs(enemiesM) do
			if v.isDead==false then
				love.graphics.draw(v.img, v.newX, v.newY, v.angle, 1, 1, v.w/2,v.h/2)
			else
				--spawn smaller enemies
		    	for i=0, 1 do
					local enemyS = Init_EnemyS()
					enemyS.x=v.x
					enemyS.y=v.y
	      			table.insert(enemiesS, enemyS)
	      			crack:stop()
	      			local vol=math.random(0.2,0.6)
      				crack:setVolume(vol)
	      			crack:play()
	    		end
		    	table.remove(enemiesM,i)
			end
		end

		for i,v in ipairs(enemiesS) do
			if v.isDead==false then
				love.graphics.draw(v.img, v.newX, v.newY, v.angle, 1, 1, v.w/2,v.h/2)
			else
				--spawn debris
				for i=0, 2 do
					local debrisT = Init_Debris()
					debrisT.x=v.x
					debrisT.y=v.y
					debrisT.speedX=v.speedX+math.random (-100,100)
					debrisT.speedY=v.speedY+math.random (-100,100)
		      		table.insert(debris, debrisT)
		      		crack:stop()
		      		local vol=math.random(0.2,0.6)
      				crack:setVolume(vol)
	      			crack:play()
	      		end
		    	table.remove(enemiesS,i)
			end
		end

		for i,v in ipairs(debris) do
			if v.isDead==false then
				love.graphics.draw(v.img, v.newX, v.newY, v.angle, 1, 1, v.w/2,v.h/2)
			else
		    	table.remove(debris,i)	
			end
		end
		for i,v in ipairs(hPicks) do
			if v.isDead==false then
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 1, 1.5, v.w/2,v.h/2)
			else
		    	table.remove(hPicks,i)
			end
		end

		for i,v in ipairs(explosions) do
			if v.isDead==false then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				v.anim:draw(v.imgAnim, v.x, v.y, v.angle, 0.6, 0.6, v.w/2,v.h/2)
			else 
				table.remove(explosions,i)
			end
		end
		if win==false then
		   love.graphics.print(score_label .. score, 15, 15)
		end
		
		for i,v in ipairs(currentHealth) do
				--love.graphics.draw(v.img, v.newX, v.newY, 0, 1, 1, v.w/2,v.h/2)
				love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
		end
		for i,v in ipairs(currentBossHealth) do
				--love.graphics.draw(v.img, v.newX, v.newY, 0, 1, 1, v.w/2,v.h/2)
				love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
		end


		if finalboss.isDead==false and gameRunning==true then
				--love.graphics.draw(v.img, v.x, v.y, v.angle, 1, 1, v.w/2,v.h/2)
				finalboss.anim:draw(finalboss.imgAnim, finalboss.x, finalboss.y, finalboss.angle, 1, 1, finalboss.w/2,finalboss.h/2)
		elseif finalboss.isDead==true and gameRunning==true then
			bombs={}
			finalExplosion.anim:draw(finalExplosion.imgAnim, finalboss.x+50, finalboss.y+50, finalboss.angle, 3, 3, finalExplosion.w/2,finalExplosion.h/2)
			finalExplosion.anim:draw(finalExplosion.imgAnim, finalboss.x+50, finalboss.y-50, finalboss.angle, 3, 3, finalExplosion.w/2,finalExplosion.h/2)
			finalExplosion.anim:draw(finalExplosion.imgAnim, finalboss.x-50, finalboss.y+50, finalboss.angle, 3, 3, finalExplosion.w/2,finalExplosion.h/2)
			finalExplosion.anim:draw(finalExplosion.imgAnim, finalboss.x-50, finalboss.y-50, finalboss.angle, 3, 3, finalExplosion.w/2,finalExplosion.h/2)
			finalExplosion.anim:draw(finalExplosion.imgAnim, finalboss.x, finalboss.y, finalboss.angle, 3, 3, finalExplosion.w/2,finalExplosion.h/2)
            bossboom:play()
		end
	else
	    love.graphics.draw(love.graphics.newImage("assets/lose.png"),250, 250)
	end

	if win==true and stage3==true and love.timer.getTime()-bossDeathTime>=3 then
		bossboom:stop()
		bgm_boss:stop()
		bgm_win:play()
		currentHealth={}
		love.graphics.clear()
		love.graphics.draw(bg.img, bg.x, bg.y,0 , 1.2, 1.2, 0, 0)
		love.graphics.draw(love.graphics.newImage("assets/win.png"),300, 250)
		Font = love.graphics.newFont("assets/198O.ttf", 120)
		love.graphics.print(score_label .. score, 250, 550)
	end
	
end

function Game_Content_Update(dt)

	if player_ship.isDead==false then
	   	--update player through its own update function
		player_ship:Update(dt)
		--count the elements in each table, somehow table:getn(name) does not work
		local emptyL=0
		local emptyM=0
		local emptyS=0
		local emptyShipL=0
		local emptyShip=0
		local emptyDebris=0
		local hPickCount=0
		for i,v in ipairs(enemies) do
			emptyL=emptyL+1
		end

		for i,v in ipairs(enemiesM) do
			emptyM=emptyM+1
		end
			
		for i,v in ipairs(enemiesS) do
			emptyS=emptyS+1
		end

		for i,v in ipairs(debris) do
			emptyDebris=emptyDebris+1
		end

		for i,v in ipairs(hPicks) do
			hPickCount=hPickCount+1
		end

		if emptyDebris>0 then
		    for i,v in ipairs(debris) do
				v:Update(dt)
			end
		end
		

		if (emptyL+emptyM+emptyS==0) then
			--win
			--win=true
			--do once
			enemies={}
			enemiesM={}
			enemiesS={}
			if doOnce==false then
				Init_Level_stage2()
				doOnce=true
			end
			
			for i,v in ipairs(bullets) do
				v:Update(dt)
			end

			for i,v in ipairs(enemyBullets) do
				v:Update(dt)
			end
			--stage 2 
			for i,v in ipairs(enemyShips) do
				v:Update(dt)
			end
			for i,v in ipairs(enemyShipsLarge) do
				v:Update(dt)
			end
			for i,v in ipairs(explosions) do
				v:Update(dt)
			end

			for i,v in ipairs(enemyShipsLarge) do
				emptyShipL=emptyShipL+1
			end

			for i,v in ipairs(enemyShips) do
				emptyShip=emptyShip+1
			end

			for i,v in ipairs(hPicks) do
				v:Update(dt)
			end

			if (emptyShip+emptyShipL==0) then
				debris={}
				enemyShips={}
				enemyShipsLarge={}

				if doOnceBoss==false then
				    Init_Level_boss()
				    doOnceBoss=true
				    
				end
				--stage 3
				if finalboss.isDead==false and gameRunning==true and doOnceBoss==true then
				    finalboss:Update(dt)
				end
				
				for i,v in ipairs(beamPre) do
					v:Update(dt)
				end
				for i,v in ipairs(beams) do
					v:Update(dt)
				end
				for i,v in ipairs(bossSpawn) do
					v:Update(dt)
				end
				for i,v in ipairs(bombs) do
					v:Update(dt)
				end
				if finalboss.isDead==true and gameRunning==true and doOnceBoss==true then
					finalExplosion:Update(dt)
				end
			end
		else
			--continue till player dies
			for i,v in ipairs(bullets) do
				v:Update(dt)
			end

			for i,v in ipairs(enemies) do
				v:Update(dt)
			end

			for i,v in ipairs(enemiesM) do
				v:Update(dt)
			end

			for i,v in ipairs(enemiesS) do
				v:Update(dt)
			end

			for i,v in ipairs(debris) do
				v:Update(dt)
			end

			for i,v in ipairs(hPicks) do
				v:Update(dt)
			end
		end
	else 
		afterDeathTime=love.timer.getTime()
		if afterDeathTime-deathTime>=3 then
			love.graphics.clear()
			cursor = love.graphics.newImage('assets/crosshair_menu.png')
			gameRunning=false
		end
	end
end

function love.load()
	Font = love.graphics.newFont("assets/198O.ttf", 40)
	 --test cursor!!!!!!!!!!!!!!!!

    cursor = love.graphics.newImage('assets/crosshair_menu.png')
  	love.mouse.setVisible(false)
  	love.mouse.setGrabbed(true)

	--initial classes: background, player
	--Init_Level()
	--Init_Level_stage2()

end

function love.update(dt)
	if gameRunning==true then
		Game_Content_Update(dt)
	end
end

function love.draw()
	bg=Init_Background()
	--draw background
	love.graphics.draw(bg.img, bg.x, bg.y,0 , 1.2, 1.2, 0, 0)
	--draw score text
	love.graphics.setFont(Font)
	
	--test menu
	if gameRunning==false and inMainMenu==true then
		Draw_Menu()
	--draw all gameplay -----------------------------------------------------------------
	elseif gameRunning==false and inMainMenu==false then
		Draw_Instruction()
	else
		Draw_Game_Content()
	end

	love.graphics.draw(cursor, love.mouse.getX() - cursor:getWidth() / 2, love.mouse.getY() - cursor:getHeight() / 2)
end

--handle one time keyboard input here
function love.keypressed(key)
	if key == "escape" then
	    love.event.quit()
	end
	if key == "space" then
	    --spawn bomb
	end
end
local resizeSound1=false
local resizeSound2=false
local resizeSound3=false
local resizeSound4=false
function love.mousemoved(x,y)
	local mX=love.mouse.getX()
	local mY=love.mouse.getY()
	if mX<=675 and mX>=225 and mY>=505.5 and mY<=606.5 and gameRunning==false and inMainMenu==true then
	    startScale=1.25
	    onStart=true
	    if resizeSound1==false then
	    	resize:stop()
	    	resize:play()
	    	resizeSound1=true
		end
	else
		startScale=1
		onStart=false
		resizeSound1=false
	end
	if mX<=675 and mX>=225 and mY>=636.5 and mY<=737.5 and gameRunning==false and inMainMenu==true then
	    optionScale=1.25
	    onOption=true
	    if resizeSound2==false then
	    	resize:stop()
	    	resize:play()
	    	resizeSound2=true
		end
	else
		optionScale=1
		onOption=false
		resizeSound2=false
	end
	if mX<=675 and mX>=225 and mY>=767.5 and mY<=868.5 and gameRunning==false and inMainMenu==true then
	    exitScale=1.25
	    onExit=true
	    if resizeSound3==false then
	    	resize:stop()
	    	resize:play()
	    	resizeSound3=true
		end
	else
		exitScale=1
		onExit=false
		resizeSound3=false
	end
	if mX<=675 and mX>=225 and mY>=767.5 and mY<=868.5 and gameRunning==false and inMainMenu==false then
	    instructionScale=1.25
	    onInstruction=true
	    if resizeSound4==false then
	    	resize:stop()
	    	resize:play()
	    	resizeSound4=true
		end
	else
		instructionScale=1
		onInstruction=false
		resizeSound4=false
	end
end

local waitTime=0.5
local clickTime
function love.mousepressed(x, y, button)
	if button == 1 and onStart==true and gameRunning==false then
		gameRunning=true
		Init_Level()
		clickTime = love.timer.getTime()
	end
	if button == 1 and onOption==true and gameRunning==false then
		Draw_Instruction()
	end
	if button == 1 and onExit==true and gameRunning==false then
		love.event.quit()
	end
	if button == 1 and onInstruction==true and gameRunning==false and inMainMenu==false then
		love.graphics.clear()
		inMainMenu=true
		gameRunning=false
	end
	
	if button == 1 and player_ship.isDead== false and gameRunning==true and (love.timer.getTime()-clickTime>=waitTime) and win==false then
		--add bullet
		local bullet = Init_Bullet()
		if table.getn(bullets)<3 then
      		table.insert(bullets, bullet)
      		shoot:stop()
      		local vol=math.random(0.3,0.8)
      		shoot:setVolume(vol)
      		shoot:play()
      	end
	end
end
