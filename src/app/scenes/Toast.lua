--
-- Author: Your Name
-- Date: 2016- 03- 20 14 :24 :41
--

--[[小弹窗 来显示刷新的成绩]]
--[[参数 ： 弹出的字，坐标]]
local Toast = class("Toast",function(str,x,y)
	local label = cc.ui.UILabel.new({text = str, font="fonts/gang.ttf"
		,size = 40,color = cc.c3b(255, 136, 129)})
        :align(display.LEFT_TOP, x, y)
    label:setLocalZOrder(100)
    label:runAction(cc.Sequence:create(
    	cc.Spawn:create(
    		cc.FadeIn:create(0.5),cc.TintTo:create(0.5, 255, 202, 56)
    		,cc.EaseBackOut:create(cc.MoveBy:create(0.5, cc.p(0,-display.cy/10)))) 
    	,cc.DelayTime:create(2)
    	,cc.Spawn:create(
    		cc.FadeOut:create(0.5),cc.TintTo:create(0.5, 255, 136, 129)
    		,cc.EaseBackIn:create(cc.MoveBy:create(0.5, cc.p(0,display.cy/10)))) 
    	,cc.CallFunc:create(function ()
    		label:removeFromParent()
    	end)
    	))
    return label
end)

return Toast