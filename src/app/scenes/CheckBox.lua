--
-- Author: Your Name
-- Date: 2016- 03- 17 10 :38 :56
--

--[[创建统一格式的checkbox]]
--[[参数 ：文字，坐标，保存的key]] 

local CheckBox = class("CheckBox",function(string,x,y,safe_key)
	local im_power = {
        off = "button/checkbox_off.png",
        off_pressed = "button/checkbox_pressed.png",
        on = "button/checkbox_on.png",
        on_pressed = "button/checkbox_pressed.png",
    }
	local label = cc.ui.UILabel.new(
        {text = string,size = 60,color = cc.c3b(55,96,255),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    local power = cc.ui.UICheckBoxButton.new(im_power)
        :setButtonLabel(label)
        :setButtonLabelOffset(-125,-5)
        :setButtonLabelAlignment(display.RIGHT_CENTER)
        :align(display.LEFT_CENTER, x, y)
        :setButtonSelected(true)
        :onButtonClicked(function ()
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if DEFAULT:getBoolForKey(safe_key) then 
                DEFAULT:setBoolForKey(safe_key,false)
            else
                DEFAULT:setBoolForKey(safe_key,true)
            end
        end)

    --[[依据获取到的用户配置 为checkbox更改状态]]

    if DEFAULT:getBoolForKey(safe_key) then 
        power:setButtonSelected(true)
    else
        power:setButtonSelected(false)
    end
    return power
end)

return CheckBox