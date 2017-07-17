
--[[帮助界面]]

local HelpScene = class("HelpScene", function()
    local scene = display.newPhysicsScene("HelpScene")
    -- scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    scene:getPhysicsWorld():setGravity({x= 0,y = -800})
    if DEFAULT:getBoolForKey(MUSIC_KEY) then
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(MUSIC_FILE,true)
        end
    end
    return scene
end)

function HelpScene:ctor()
    self:initUI()
    self:initBackground()
    self:initLabel()
    self:touchEvent()
    self:initHero()
    self:onContact()
end

function HelpScene:initUI()
    self.brownBackground = BackgroundLayer.new("brown.png",display.width/3,display.height)
        :addTo(self)
    self.brownBackground:setPosition(display.cx/3,display.cy)
    self.whiteBackground = BackgroundLayer.new("white.png",display.width/3,display.height)
        :addTo(self)
    self.wineBackground = BackgroundLayer.new("wine_red.png",display.width/3,display.height)
        :addTo(self)
    self.wineBackground:setPosition(display.cx/3*5,display.cy)
    self.lineBackground = BackgroundLayer.new("red2.png",display.width,70)
        :addTo(self)
    self.lineBackground:setPosition(display.cx,display.height - 30)
    local backBtnImg = {
        normal = "button/back_normal_m.png",
        pressed = "button/back_pressed_m.png"
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
        :onButtonPressed(function (event)
        end)
        :align(display.RIGHT_TOP, display.right-50, display.top-30)
        :addTo(self)
    self.backBtn:setLocalZOrder(50)
end

function HelpScene:touchEvent()
    self.whiteBackground:setTouchEnabled(true)
    self.whiteBackground:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            self.flyHero:jump()
            return true
        end
    end)
    self.brownBackground:setTouchEnabled(true)
    self.brownBackground:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            self.runHero:jump()
            return true
        end
    end)
    self.wineBackground:setTouchEnabled(true)
    self.wineBackground:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            self.swimHero:jump()
            return true
        end
    end)
end

function HelpScene:initBackground()
    --[[初始化物理背景层]]
    self.PhysicalLayer = cc.LayerColor:create(cc.c4b(0,0,0,30),display.width,display.cy)
        :addTo(self)
    self.PhysicalLayer:ignoreAnchorPointForPosition(false)
    self.PhysicalLayer:setAnchorPoint(0,0.5)
    self.PhysicalLayer:setPosition(0,display.cy)
    self.PhysicalLayerBody = cc.PhysicsBody:createEdgeBox({width = display.width,height = display.cy}
        ,cc.PHYSICSBODY_MATERIAL_DEFAULT,5.0)
    self.PhysicalLayerBody:setContactTestBitmask(0x2)  
    local edgeNode = cc.Node:create()
    edgeNode:setPosition(display.cx,display.cy/2)
    edgeNode:setPhysicsBody(self.PhysicalLayerBody)
    self.PhysicalLayer:addChild(edgeNode)
end

function HelpScene:initLabel()
    local label = cc.ui.UILabel.new(
        {text = "新手帮助",size = 70,color = cc.c3b(181,125,229),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 180), cc.size(2, -2), 50)
    label:setPosition(display.cx,display.height - 40)
    label:setAnchorPoint(0.5,0.5)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "裸奔模式",size = 60,color = cc.c3b(182,248,60),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(10,display.height/6*5)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "上天模式",size = 60,color = cc.c3b(92,119,166),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(display.width/3+10,display.height/6*5)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "溺水模式",size = 60,color = cc.c3b(231,166,53),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(display.width/3*2+10,display.height/6*5)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "点击跳跃\n碰到障碍就死掉了\n你飞不出界的",size = 40,color = cc.c3b(182,248,60),
        dimensions = cc.size(display.width/3-20, display.height/4),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(10,10)
    label:setAnchorPoint(0,0)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "持续点击保持飞行\n碰障碍会死掉的\n飞出界也会死掉的",size = 40,color = cc.c3b(92,119,166),
        dimensions = cc.size(display.width/3-20, display.height/4),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(display.width/3+10,10)
    label:setAnchorPoint(0,0)
    label:addTo(self)
    local label = cc.ui.UILabel.new(
        {text = "点击变向\n碰到障碍就死掉了\n碰到边界就反弹",size = 40,color = cc.c3b(231,166,53),
        dimensions = cc.size(display.width/3-20, display.height/4),font="fonts/gang.ttf"})
    label:enableShadow(cc.c4b(0, 0, 0, 170), cc.size(2, -2), 20)
    label:setPosition(display.width/3*2+10,10)
    label:setAnchorPoint(0,0)
    label:addTo(self)
end

function HelpScene:initHero()
    self.runHero = Hero.new():addTo(self)
    self.runHero:setPosition(display.cx/3,display.cy)
    self.runHero:changeAct("run",true)
    self.runHero:setPhysicsEnable(true, "ver")

    self.flyHero = Hero.new():addTo(self)
    self.flyHero:reset()
    self.flyHero:setPosition(display.cx,display.cy)
    self.flyHero:changeAct("fly", true)
    self.flyHero:setPhysicsEnable(true, "hor")

    self.swimHero = Hero.new():addTo(self)
    self.swimHero:reset()
    self.swimHero:setPosition(display.cx/3*5,display.cy)
    self.swimHero:changeAct("swim", true)
    self.swimHero:setPhysicsEnable(true, "hor2")
    self.swimHero.heroBody:setGravityEnable(false)
    self.swimHero:swim()
    self.swimHero:setTag(111)
end

function HelpScene:onContact()
    --[[设置‘碰撞监听’]]
    local function onContactBegin(contact)
        local crash = false
        local spriteA = contact:getShapeA():getBody():getNode()
        local spriteB = contact:getShapeB():getBody():getNode()
        if spriteA and spriteA:getTag() == 111 or spriteB and spriteB:getTag() == 111 then
            self.swimHero:swim()
        end
        return true
    end
    
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self.PhysicalLayer)
end

return HelpScene