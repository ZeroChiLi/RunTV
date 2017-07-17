
--[[不同场景添加不同障碍]]
--[[参数 ：当前英雄的状态]]

local Barricade = class("Barricade",function(act)
	local barricade_width = 50
    local barricade_height = 50
    local barricade_y = display.cy
    local color = 0

    if act == Hero.ACT_RUN then
        color = 3
        barricade_width = math.random(20,45)
        barricade_height = math.random(45,80)
        barricade_y = display.cy/9+barricade_height/2
    elseif act == Hero.ACT_FLY then
        color = 0
        barricade_width = math.random(80,130)
        barricade_height = math.random(display.height/4,display.height/2)
        barricade_y = math.random(barricade_height/2,display.height - barricade_height/2)
    elseif act == Hero.ACT_SWIM then
        color = 4
    	barricade_width = 55
    	barricade_height = math.random(display.height/2,display.height/5*3)
    	if math.random(1,2) == 1 then
    		barricade_y = barricade_height / 2
    	else
    		barricade_y = display.height - barricade_height / 2
    	end
    end
    --画矩形，妈个鸡，设置锚点无效
    -- local barricade = display.newRect(cc.rect(-barricade_width/2, -barricade_height/2,barricade_width, barricade_height), {fillColor = cc.c4f(0,0,0,1)})
    -- barricade:setAnchorPoint(0.5,0.5)
    local barricade = display.newScale9Sprite("barricade_"..color..".png",0,0, cc.size(barricade_width, barricade_height))
    barricade.width = barricade_width
    barricade.height = barricade_height
    barricade.y = barricade_y
    barricade:setPosition({x = display.width+barricade.width/2,y = barricade.y})
	return barricade
end)

function Barricade:setPhysicsEnable(enabled)
	if enabled then
		self.barricadeBody = cc.PhysicsBody:createBox({width = self.width,height = self.height})
		self.barricadeBody:setContactTestBitmask(0x2)
	    self.barricadeBody:setRotationEnable(false)
	    self.barricadeBody:setDynamic(false)
	    self.barricadeBody:setGravityEnable(false)
		self:setPhysicsBody(self.barricadeBody)
	else
		if self.barricadeBody then
			self.barricadeBody:setEnable(false)
		end
	end
end

return Barricade