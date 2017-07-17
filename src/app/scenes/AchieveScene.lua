--
-- Author: Your Name
-- Date: 2016- 03- 18 13 :33 :44
--
--[[成就系统]]

local AchieveScene = class("AchieveScene", function()
    if DEFAULT:getBoolForKey(MUSIC_KEY) then
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(MUSIC_FILE,true)
        end
    end
    return display.newScene("AchieveScene")
end)

function AchieveScene:ctor()
	self:initUI()
    self:initTV()
end

function AchieveScene:initUI()
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
    	BackgroundLayer.new("black.png",display.width,display.height):addTo(self)
    else
        BackgroundLayer.new("white.png",display.width,display.height):addTo(self)
    end
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

function AchieveScene:initTV()
    --[[初始化显示器]]
    self.tvBackground = display.newSprite("#changeChannel_00.png"):addTo(self)
    self.tvBackground:setPosition(display.width/5*3,display.cy/10)
    self.tvBackground:setAnchorPoint(0.5,0)
    self.tvBackground:setScale(display.height/self.tvBackground:getContentSize().height)
    self.tvWidth = self.tvBackground:getContentSize().width*display.height/self.tvBackground:getContentSize().height
    self.tvHeight = display.height

    self.listView = cc.ui.UIListView.new({
        bgScale9 = true,
        viewRect = cc.rect(self.tvBackground:getPositionX() - self.tvWidth/3
            ,self.tvBackground:getPositionY() + display.cy/5,self.tvWidth/3*2,display.cy/7*6),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    }):addTo(self)

    --[[初始化遥控器]]
    self.tvControl = display.newSprite("#control_00.png"):addTo(self)
    self.tvControl:setAnchorPoint(0.5,0)
    self.tvControl:setPosition(self.tvBackground:getContentSize().width/3,display.cy/15)
    local tvControlSize = self.tvControl:getContentSize()
    self.tvControl:setScaleY((display.height/15*14) / tvControlSize.height)

    --[[增加按钮]]
    local btn = ControlBtn.new("排行榜",tvControlSize.width/2,tvControlSize.height/4*3,self.tvControl,self.tvBackground)
        :addTo(self.tvControl)
    btn:onButtonClicked(function()
            self:changeView(1)
        end)
    local btn = ControlBtn.new("游戏记录",tvControlSize.width/2,tvControlSize.height/4*2,self.tvControl,self.tvBackground)
        :addTo(self.tvControl)
    btn:onButtonClicked(function()
            self:changeView(2)
        end)
    local btn = ControlBtn.new("英雄记录",tvControlSize.width/2,tvControlSize.height/4,self.tvControl,self.tvBackground)
        :addTo(self.tvControl)
    btn:onButtonClicked(function()
            self:changeView(3)
        end)
end

function AchieveScene:changeView(channel)
    self.listView:removeAllItems()
    if channel == 1 then
        for i=1,10 do
            local str = ""
            if DEFAULT:getStringForKey("ranking_name_"..i) then
                str = string.format("第%d名：%s (%.1f)",i
                ,DEFAULT:getStringForKey("ranking_name_"..i),DEFAULT:getFloatForKey("ranking_"..i))
            end
            ListViewItem.new(self.listView,str,self.tvWidth)
        end
    elseif channel == 2 then
        ListViewItem.new(self.listView,"总时间 ："..self:changeTime(DEFAULT:getFloatForKey(PLAY_TOTAL_SCORE,0))
            ,self.tvWidth)
        ListViewItem.new(self.listView,"最后一局时间 ："..self:changeTime(DEFAULT:getFloatForKey(RECORD_SCORE,0))
            ,self.tvWidth)
        ListViewItem.new(self.listView,"平均每局时间 ："..self:changeTime(DEFAULT:getFloatForKey(PLAY_AVERAGE_SCORE,0))
            ,self.tvWidth)
        ListViewItem.new(self.listView,"游戏总共次数 ："..DEFAULT:getIntegerForKey(PLAY_TOTAL_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"跑步模式次数 ："..DEFAULT:getIntegerForKey(PLAY_RUN_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"飞行模式次数 ："..DEFAULT:getIntegerForKey(PLAY_FLY_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"游泳模式次数 ："..DEFAULT:getIntegerForKey(PLAY_SWIM_TIME, 0)
            ,self.tvWidth)
    elseif channel == 3 then
        ListViewItem.new(self.listView,"总共点击次数 ："..DEFAULT:getIntegerForKey(JUMP_TOTAL_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"奔跑跳跃次数 ："..DEFAULT:getIntegerForKey(JUMP_RUN_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"飞行喷气次数 ："..DEFAULT:getIntegerForKey(JUMP_FLY_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"游泳变向次数 ："..DEFAULT:getIntegerForKey(JUMP_SWIM_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"总共死亡次数 ："..DEFAULT:getIntegerForKey(DIED_TOTAL_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"跑步摔死次数 ："..DEFAULT:getIntegerForKey(DIED_RUN_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"飞行坠机次数 ："..DEFAULT:getIntegerForKey(DIED_FLY_TIME, 0)
            ,self.tvWidth)
        ListViewItem.new(self.listView,"游泳溺水次数 ："..DEFAULT:getIntegerForKey(DIED_SWIM_TIME, 0)
            ,self.tvWidth)
    end

    self.listView:reload()
end

function AchieveScene:changeTime(time)
    local scecond,minute,hour = 0.0,nil,nil
    if time >= 3600 then
        hour = self:getCeil(time / 3600)
        minute = (time - hour*3600) % 60
        scecond = time % 60
    elseif time > 600 then 
        minute = self:getCeil(time / 60)
        scecond = (time - minute*60) % 60
    else
        scecond = time
    end
    if hour then
        return string.format("%dH %dM %.1fS",hour,minute,scecond)
    elseif minute then
        return string.format("%dm %.1fs",minute,scecond)
    else
        return string.format("%.1fS",scecond)
    end
end

function AchieveScene:getCeil(x)
    if x <= 0 then
        return math.ceil(x)
    end
    if x == math.ceil(x) then
        return x
    else
        return math.ceil(x) - 1
    end
end

return AchieveScene