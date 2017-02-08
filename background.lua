local t={}
t.img=love.graphics.newImage("assets/background.png")
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.x= 0
t.y= 0
	

function t:new (obj)
	obj=obj or {}
	setmetatable(obj, t)
    self.__index = self
	return obj
end

return t