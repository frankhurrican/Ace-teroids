local t={}
t.img=love.graphics.newImage("assets/heart.png")
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.x= 30
t.y= 80
	

function t:new (obj)
	obj=obj or {}
	setmetatable(obj, t)
    self.__index = self
	return obj
end

return t