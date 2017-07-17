
--[[创建背景层 需要纹理素材图片]]
--[[参数 ： 纹理图片 32*32 64*64 128*128.... ，要铺满的宽和高]]

local BackgroundLayer = class("BackgroundLayer",function(texture,Width,Height)
	Width = Width or 0
	Height = Height or 0
	local backgroundLayer = cc.Sprite:create(texture,cc.rect(0,0,Width,Height))
    backgroundLayer:getTexture():setTexParameters(gl.LINEAR,gl.LINEAR,gl.REPEAT,gl.REPEAT)
    backgroundLayer:setPosition(display.cx,display.cy)
	return backgroundLayer
end)

function BackgroundLayer:setPhysicsEnable(enabled)
	--[[设置是否需要物理边框 默认不受重力影响]]
	if enabled then
	    self.line_body = cc.PhysicsBody:createEdgeBox(self:getContentSize(),cc.PhysicsMaterial(1,0,0),2.0)
	    self.line_body:setGravityEnable(false)
	    self:setPhysicsBody(self.line_body)
	else
		if self.line_body then
			self.line_body:setEnable(false)
		end
	end
end

return BackgroundLayer