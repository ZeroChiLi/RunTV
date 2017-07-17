--
-- Author: Your Name
-- Date: 2016- 03- 19 14 :44 :09
--

--[[成就系统的遥控器按钮]]
--[[参数 ： 按钮上的字，坐标，父遥控器，显示器，后面两个用来搞动画效果的]]

local ControlBtn = class("ControlBtn",function(string,x,y,control,view)
	local conBtnImg = {
        normal = "button/controlBtn_normal.png",
        pressed = "button/controlBtn_pressed.png"
    }
    local label = cc.ui.UILabel.new(
        {text = string,size = 40,color = cc.c3b(0,33,11),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(1, -1), 20)
	local controlBtn = cc.ui.UIPushButton.new(conBtnImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if control then
            	control:playAnimationOnce(display.getAnimationCache("control_pressed"))
            end
            if view then
            	view:playAnimationOnce(display.getAnimationCache("changeChannel"))
            end
        end)
        :align(display.CENTER, x, y)
        :setButtonLabel(label)
        :setButtonLabelOffset(0,0)

    return controlBtn
end)

return ControlBtn