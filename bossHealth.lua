local t={}
t.img=love.graphics.newImage("assets/bosshp_high.png")
t.w= t.img:getWidth()
t.h= t.img:getHeight()
t.x= 180
t.y= 35
	

function t:new (obj)
	obj=obj or {}
	setmetatable(obj, t)
    self.__index = self
	return obj
end

return t