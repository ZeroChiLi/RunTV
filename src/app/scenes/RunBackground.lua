
--[[移动的背景]]
--[[背景图片]]

local RunBackground = class("RunBackground",function(bg)
    local runbg = display.newSprite(bg)
        runbg:setPosition(display.cx*3,display.cy)
        runbg:setScale(display.width/runbg:getContentSize().width,3)
        runbg:runAction(cc.Sequence:create(cc.MoveBy:create(10,cc.p(-display.cx*4,0))
        ,cc.CallFunc:create(function ()
            runbg:removeFromParent()
        end)))
	return runbg
end)

return RunBackground