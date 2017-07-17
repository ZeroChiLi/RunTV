
local MainScene = class("MainScene", function()
    if DEFAULT:getBoolForKey(MUSIC_KEY) then
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(MUSIC_FILE,true)
        end
    end
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self:initUI()
    self:initPlayerName()
    self:initStartBtn()
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
        self:initBallLight()
    end
    self:initHero()
    if DEFAULT:getBoolForKey(PARTICLE_KEY) then
        self:upDateParticle()
    end
end

--[[初始化玩家名]]
function MainScene:initPlayerName()
    local function onEdit(event,editbox)
        if event == "return" then
            if self.editbox:getText() == "" then
                DEFAULT:setStringForKey(PLAYER_NAME,"无名傻叼")
            else
                DEFAULT:setStringForKey(PLAYER_NAME,self.editbox:getText())
            end
        end
    end

    self.editbox = cc.ui.UIInput.new({
        listener = onEdit,
        image = "editbox2.png",
        x = display.cx/3,
        y = display.height/10*9,
        size = cc.size(280, 50) 
    }):addTo(self)
    self.editbox:setPlaceHolder("玩家大名")
    self.editbox:setLocalZOrder(50)
    self.editbox:setMaxLength(7)
    if DEFAULT:getStringForKey(PLAYER_NAME) then
        self.editbox:setText(DEFAULT:getStringForKey(PLAYER_NAME))
    end
end

--[[初始化 背景(包括夜间模式) 三个圆形按钮]]
function MainScene:initUI()
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
    	BackgroundLayer.new("black.png",display.width,display.height):addTo(self)
    else
        BackgroundLayer.new("white.png",display.width,display.height):addTo(self)
    end
    local achieveImg = {
        normal = "button/achievement_normal.png",
        pressed = "button/achievement_pressed.png"
    }
    self.achieveBtn = cc.ui.UIPushButton.new(achieveImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            local AchieveScene = require("src/app/scenes/AchieveScene")
            local ts = cc.TransitionFade:create(1,AchieveScene:new())
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.RIGHT_BOTTOM, display.right-50, display.bottom+30)
        :addTo(self)
    self.achieveBtn:setLocalZOrder(50)

    local settingImg = {
        normal = "button/setting_normal.png",
        pressed = "button/setting_pressed.png"
    }
    self.settingBtn = cc.ui.UIPushButton.new(settingImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            local SettingScene = require("src/app/scenes/SettingScene")
            local ts = cc.TransitionFade:create(1,SettingScene:new())
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.RIGHT_TOP, display.right-200, display.top-30)
        :addTo(self)
    self.settingBtn:setLocalZOrder(50)

    local helpImg = {
        normal = "button/help_normal.png",
        pressed = "button/help_pressed.png"
    }
    self.helpBtn = cc.ui.UIPushButton.new(helpImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            local HelpScene = require("src/app/scenes/HelpScene")
            local ts = cc.TransitionFade:create(1,HelpScene:new())
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.RIGHT_TOP, display.right-50, display.top-30)
        :addTo(self)
    self.helpBtn:setLocalZOrder(50)
end

--[[初始化中间的大电视机 还有下面的电源按钮]]
function MainScene:initStartBtn()
    self.tvBtn = display.newSprite("#bigTV_pressed_05.png")
    self.tvBtn:setAnchorPoint(0.5,0.33)
    self.tvBtn:setPosition(display.cx,display.cy)
    self.tvBtn:addTo(self)
    self:changeBigTV("normal", true)

    local label = cc.ui.UILabel.new(
        {text = "点击开始",size = 35,color = cc.c3b(11,116,72),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(1, -1), 20)

    self.isOnPressed = false
    local startImg = {
        normal = "button/power_normal.png",
        pressed = "button/power_pressed.png"
    }
    self.startBtn = cc.ui.UIPushButton.new(startImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if self.ballLight then
                transition.removeAction(self.ballLightAction)
                self.ballLight:removeFromParent()
            end
            self:changeBigTV("pressed", false)
            self:changeLight(true)
            self.tvBtn:setLocalZOrder(100)
            self.tvBtn:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.2)
                ,cc.EaseExponentialIn:create(cc.ScaleBy:create(1,4)) 
                ,cc.CallFunc:create(function ()
                    local PlayScene = require("src/app/scenes/PlayScene")
                    local ts = cc.TransitionFade:create(1,PlayScene:new())
                    cc.Director:getInstance():replaceScene(ts)
                end)))
        end)
        :onButtonPressed(function ()
            self:changeLight(true)
            if self.ballLight then
                transition.removeAction(self.ballLightAction)
                self.ballLightAction = self.ballLight:playAnimationForever(display.getAnimationCache("ballLight_fast"),0)
            end
            self.isOnPressed = true
        end)
        :onButtonRelease(function ()
            self:changeLight(false)
            if self.ballLight then
                transition.removeAction(self.ballLightAction)
                self.ballLightAction = self.ballLight:playAnimationForever(display.getAnimationCache("ballLight"),0)
            end
            self.isOnPressed = false
        end)
        :align(display.CENTER, display.cx, display.cy/3)
        --添加个文本提示开始游戏
        :setButtonLabel(label)
        :setButtonLabelOffset(0,-60)
        :setButtonLabelAlignment(display.TOP_CENTER)
        :addTo(self)

    self.startBtnNormalLight = display.newSprite("button/power_normal_light.png")
    self.startBtnPressedLight = display.newSprite("button/power_pressed_light.png")
    self.normalLight = cc.RepeatForever:create(
        cc.Sequence:create(cc.TintTo:create(1,0,255,0),cc.TintTo:create(1,255,255,255)))
    self.pressedLight = cc.RepeatForever:create(
        cc.Sequence:create(cc.TintTo:create(0.5,255,0,0),cc.TintTo:create(0.5,255,255,255)))
    self.startBtnNormalLight:runAction(self.normalLight)
    self.startBtnPressedLight:runAction(self.pressedLight)
    self.startBtn:setLocalZOrder(2)
    self.startBtnNormalLight:addTo(self.startBtn)
    self.startBtnPressedLight:addTo(self.startBtn)
    self:changeLight(false)
end

--[[初始化球灯(只有夜间模式才开启)]]
function MainScene:initBallLight()
    self.ballLight = display.newSprite("#light_00.png")
    self.ballLight:setAnchorPoint(0.5,0.5)
    self.ballLight:setPosition(display.cx,display.cy)
    self.ballLight:addTo(self)
    self.ballLight:setScale(display.width/self.ballLight:getContentSize().width
        ,display.height/self.ballLight:getContentSize().height)
    self.ballLightAction =  self.ballLight:playAnimationForever(display.getAnimationCache("ballLight"),0)
end

--[[改变下面电源按钮变化的颜色]]
function MainScene:changeLight(open)
    if open then
        self.startBtnNormalLight:runAction(cc.FadeOut:create(0.1))
        self.startBtnPressedLight:runAction(cc.FadeIn:create(0.1))
    else
        self.startBtnPressedLight:runAction(cc.FadeOut:create(0.1))
        self.startBtnNormalLight:runAction(cc.FadeIn:create(0.1))
    end
end

--[[改变中间大电视的动画(按下电源时)]]
function MainScene:changeBigTV(act,isForever)
    if self.lastAction then
        transition.removeAction(self.lastAction)
    end
    local action = display.getAnimationCache("bigtv_"..act)
    if action then
        if isForever then
            self.lastAction = self.tvBtn:playAnimationForever(action,0)
        else
            self.lastAction = self.tvBtn:playAnimationOnce(action)
        end
    end
end

--[[初始化三个傻叼]]
function MainScene:initHero()
    self.hero = Hero.new()
    self.hero:addTo(self)
    self.hero:setPosition(display.cx/3,display.cy)
    self.hero:changeAct("stand",true)   

    self.hero3 = Hero.new()
    self.hero3:addTo(self)
    self.hero3:setPosition(display.cx/3*5,display.cy)
    self.hero3:changeAct("stand",true)
    self.hero3:runAction(cc.FlipX:create(true))

    self.hero2 = Hero.new()
    self.hero2:addTo(self)
    self.hero2:setPosition(display.width/10*7,display.cy/3)
    self.hero2:changeAct("moonwalk", true)
    self.hero2:setLocalZOrder(3)
    self.hero2:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveTo:create(5,cc.p(display.width/10*3,display.cy/3))
        ,cc.FlipX:create(true)
        ,cc.CallFunc:create(function ()
            self.hero2:setLocalZOrder(1)
        end)
        ,cc.MoveTo:create(5,cc.p(display.width/10*7,display.cy/3))
        ,cc.FlipX:create(false)
        ,cc.CallFunc:create(function ()
            self.hero2:setLocalZOrder(3)
        end))))
end

--[[更新粒子位置]]
function MainScene:upDateParticle()
    local color = 1
    local angle = 0
    local angle2 = 180
    self.hero:scheduleUpdate()
    self.hero:schedule(function ()
        local p_x = self.hero:getPositionX()
        local p_y = self.hero:getPositionY()+self.hero:getContentSize().height/4
        local heroParticle = Particle.new("cube_plist/cube_dance_"..color..".plist", p_x,p_y)
        heroParticle:addTo(self)
        heroParticle.emitter:setAngle(angle)
        heroParticle.emitter:setAngleVar(15)
        angle = angle + 30
        if angle > 360 then
            angle = angle - 360
        end

        local p_x = self.hero3:getPositionX()
        local p_y = self.hero3:getPositionY()+self.hero3:getContentSize().height/4
        local hero3Particle = Particle.new("cube_plist/cube_dance_"..color..".plist", p_x,p_y)
        hero3Particle:addTo(self)
        hero3Particle.emitter:setAngle(angle2)
        hero3Particle.emitter:setAngleVar(15)
        angle2 = angle2 - 30
        if angle2 < 0 then
            angle2 = angle2 + 360
        end

        color = color + 1
        if color > 7 then
            color = 1
        end

        if self.isOnPressed then
            heroParticle.emitter:setAngle(180)
            hero3Particle.emitter:setAngle(0)
        end
    end,0.4,true)

    self.hero2:scheduleUpdate()
    self.hero2:schedule(function ()
        local hero2Particle = Particle.new("square.plist",self.hero2:getContentSize().width/2
        ,self.hero2:getContentSize().height/16*11)
        if self.isOnPressed then
            hero2Particle.emitter:setGravity({y=1000})
        else
            hero2Particle.emitter:setGravity({y=0})
        end
        hero2Particle:addTo(self.hero2)
    end,1,true)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
