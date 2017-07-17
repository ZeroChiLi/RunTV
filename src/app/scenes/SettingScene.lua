
--[[设置界面]]

local SettingScene = class("SettingScene", function()
    if DEFAULT:getBoolForKey(MUSIC_KEY) then
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(MUSIC_FILE,true)
        end
    end
    return display.newScene("SettingScene")
end)

function SettingScene:initBackground()
    local picture 
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
        picture = "black.png"
    else
        picture = "white.png"
    end
    self.background = BackgroundLayer.new(picture,display.width,display.height)
    :addTo(self)
    self.background:setLocalZOrder(-2)
end

function SettingScene:initUI()
    local effect_power = CheckBox.new("音效",display.cx, display.height/10*8,EFFECT_KEY)
        :addTo(self)

    local music_power = CheckBox.new("音乐",display.cx, display.height/10*7,MUSIC_KEY)
        :onButtonClicked(function ()
            if DEFAULT:getBoolForKey(MUSIC_KEY) then 
                AudioEngine.playMusic(MUSIC_FILE,true)
            else
                AudioEngine.stopMusic(false)
            end
        end)
        :addTo(self)

    local autoRestart_power = CheckBox.new("自动重新开始",display.cx, display.height/10*6,AUTO_RESTART_KEY)
        :addTo(self)

    local night_power = CheckBox.new("夜间模式",display.cx, display.height/10*5,NIGHT_KEY)
        :onButtonClicked(function ()
            local picture 
            if DEFAULT:getBoolForKey(NIGHT_KEY) then
                picture = "black.png"
            else
                picture = "white.png"
            end
            self.background = BackgroundLayer.new(picture,display.width,display.height)
            :addTo(self)
            self.background:setLocalZOrder(-1)
        end)
        :addTo(self)

    local particle_power = CheckBox.new("粒子发射器",display.cx, display.height/10*4,PARTICLE_KEY)
        :onButtonClicked(function ()
            if DEFAULT:getBoolForKey(PARTICLE_KEY) then
                self.shit = Particle.new("wine_red.plist",
                    self.tvDog:getContentSize().width/10*8,self.tvDog:getContentSize().height/6)
                self.shit:setLocalZOrder(-1)
                self.shit:addTo(self.tvDog)
            else
                if self.shit then
                    self.shit:removeFromParent()
                end
            end
        end)
        :addTo(self)

    local backBtnImg = {
        normal = "button/back_normal.png",
        pressed = "button/back_pressed.png"
    }
    self.backBtn = cc.ui.UIPushButton.new(backBtnImg,{scale9 = false})
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            display.resume()
            local MainScene = require("src/app/scenes/MainScene")
            local ts = cc.TransitionFade:create(1,MainScene:new())
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.RIGHT_TOP, display.right-50, display.top-30)
        :addTo(self)
end

function SettingScene:initTVDog()
    self.tvDog = display.newSprite("TV_Dog.png")
    self.tvDog:addTo(self)
    self.tvDog:setScale(2,2)
    self.tvDog:setPosition(display.width/4*3,display.cy/2)

    if DEFAULT:getBoolForKey(PARTICLE_KEY) then
        self.shit = Particle.new("wine_red.plist",
            self.tvDog:getContentSize().width/10*8,self.tvDog:getContentSize().height/6)
        self.shit:setLocalZOrder(-1)
        self.shit:addTo(self.tvDog)
    end
end

function SettingScene:ctor()
    self:initBackground()
    self:initTVDog()
    self:initUI()
end

return SettingScene