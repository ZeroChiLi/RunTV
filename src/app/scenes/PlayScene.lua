
--[[游戏场景]]

local PlayScene = class("PlayScene", function()
    local scene = display.newPhysicsScene("PlayScene")
    -- scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    scene:getPhysicsWorld():setGravity({x= 0,y = -800})
    if DEFAULT:getBoolForKey(MUSIC_KEY) then
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(MUSIC_FILE,true)
        end
    end
    return scene
end)

function PlayScene:ctor()
    self.needBack = false
    self.evolveTime = 20.0
    self.coolTime = 0.0
    self.fristCrash = true
    self.rankingTime = 0
    math.randomseed(os.time())
    self.randomTime = math.random() + 1.7

    self:initUI()
    self:initBackground()
    self:initGround()
    self:initHero()
    self:changeHeroAct(false)
    self:onContact()
    self:initTouchLayer()

    self:addOneToKey(PLAY_TOTAL_TIME)
end

function PlayScene:addOneToKey(key)
    DEFAULT:setIntegerForKey(key,DEFAULT:getIntegerForKey(key,0) + 1)
end

function PlayScene:initUI()
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
        labelColor = cc.c3b(204, 197, 134)
    else
        labelColor = cc.c3b(27, 34, 43)
    end
    self.timeFontLabel = cc.ui.UILabel.new({
        text = "Time:", font="fonts/STENCILSTD.OTF",size = 30,color = labelColor})
        :align(display.LEFT_TOP, display.left+50, display.top-50)
        :addTo(self)
    self.timeFontLabel:setLocalZOrder(100)
    self.timeLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "0.0", font="fonts/STENCILSTD.OTF",size = 30,color = labelColor})
        :align(display.LEFT_TOP, display.left+160, display.top-50)
        :addTo(self)
    self.timeLabel:setLocalZOrder(100)
    self.recordFontLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "Record:", font="fonts/STENCILSTD.OTF",size = 30,color = labelColor})
        :align(display.LEFT_TOP, display.left+300, display.top-50)
        :addTo(self)
    self.recordFontLabel:setLocalZOrder(100)

    self.recordLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = string.format("%.1f"
            ,DEFAULT:getFloatForKey("ranking_"..self:getLastRanking(self.rankingTime), 0))
            , font="fonts/STENCILSTD.OTF",size = 30,color = labelColor})
        :align(display.LEFT_TOP, display.left+460, display.top-50)
        :addTo(self)
    self.recordLabel:setLocalZOrder(100)

    local backBtnImg = {
        normal = "button/back_normal_m.png",
        pressed = "button/back_pressed_m.png"
    }
    self.backBtn = cc.ui.UIPushButton.new(backBtnImg,{scale9 = false})
        :onButtonClicked(function(event)
            display.resume()
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if self.fristCrash and self.time > 5 then
                PlayScene:upDateInformation(self.time,false,self.hero.run_time,self.hero.fly_time,self.hero.swim_time)
            end
            self:setChacheAndBackToFristScene()
        end)
        :onButtonPressed(function (event)
        end)
        :align(display.RIGHT_TOP, display.right-250, display.top-30)
        :addTo(self)
    self.backBtn:setLocalZOrder(102)

    local restartBtnImg = {
        normal = "button/restart_normal_m.png",
        pressed = "button/restart_pressed_m.png"
    }
    self.restartBtn = cc.ui.UIPushButton.new(restartBtnImg,{scale9 = false})
        :onButtonClicked(function(event)
            display.resume()
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if self.fristCrash and self.time > 5 then
                PlayScene:upDateInformation(self.time,false,self.hero.run_time,self.hero.fly_time,self.hero.swim_time)
            end
            local PlayScene = require("src/app/scenes/PlayScene")
            local ts = cc.TransitionFade:create(1,PlayScene:new())
            cc.Director:getInstance():replaceScene(ts)
        end)
        :onButtonPressed(function (event)
        end)
        :align(display.RIGHT_TOP, display.right-150, display.top-30)
        :addTo(self)
    self.restartBtn:setLocalZOrder(102)

    self.gameStop = false
    local im_stop = {
        off = "button/stop_normal_m.png",
        off_pressed = "button/stop_pressed_m.png",
        on = "button/continue_normal_m.png",
        on_pressed = "button/continue_pressed_m.png",
    }
    self.stopBtn = cc.ui.UICheckBoxButton.new(im_stop)
        :onButtonClicked(function(event)
            if DEFAULT:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if event.target:isButtonSelected() then
                self.gameStop = true
                display.pause()
            else
                self.gameStop = false
                display.resume()
            end
        end)
        :onButtonPressed(function (event)
        end)
        :align(display.RIGHT_TOP, display.right-50, display.top-30)
        :addTo(self)
    self.stopBtn:setLocalZOrder(102)
    self.time = 0.0
end

    --[[获取当前时间的上一个排名人的分数]]
function PlayScene:getLastRanking(time)
    for i=10,1,-1 do
        if DEFAULT:getFloatForKey("ranking_"..i) then
            if DEFAULT:getFloatForKey("ranking_"..i) > time then
                return i
            end
            if i == 1 then
                return 0
            end
        end
    end
    return -1
end

    --[[初始化背景 渐变色 雾霾动态 物理背景]]
function PlayScene:initBackground()
    --[[渐变色背景]]
    if DEFAULT:getBoolForKey(NIGHT_KEY) then
        self.backgroundLayer = display.newSprite("black_background.png")
    else
        self.backgroundLayer = display.newSprite("background.png")
    end
    self.backgroundLayer:setPosition(display.cx,display.cy)
    self.backgroundLayer:setScale(display.width/self.backgroundLayer:getContentSize().width,3)
    self.backgroundLayer:addTo(self)
    --[[加层雾霾 让背景动起来]]
    self:runBackground()
    --[[初始化物理背景层]]
    -- self.PhysicalLayer = cc.LayerColor:create(cc.c4b(255,255,255,0),display.width,display.height)
    --     :addTo(self)
    self.PhysicalLayer = BackgroundLayer.new("transparency.png",display.width,display.height/7*8)
        :addTo(self)
    self.PhysicalLayerBody = cc.PhysicsBody:createEdgeBox({width = display.width,height = display.height/7*8},cc.PHYSICSBODY_MATERIAL_DEFAULT,5.0)
    self.PhysicalLayerBody:setContactTestBitmask(0x2)  
    -- local edgeNode = cc.Node:create()
    -- edgeNode:setPosition(display.cx,display.cy)
    -- edgeNode:setPhysicsBody(self.PhysicalLayerBody)
    -- self.PhysicalLayer:addChild(edgeNode)
    self.PhysicalLayer:setPhysicsBody(self.PhysicalLayerBody)
end

    --[[初始化地板]]
function PlayScene:initGround()
    local line_ContentSize = display.newSprite("line_4.png"):getContentSize()
    self.lineGround = BackgroundLayer.new("line_4.png",display.width*2,line_ContentSize.height)
    self.lineGround:setPosition(display.width,display.cy/10 - line_ContentSize.height/4)
    self.lineGround:addTo(self)
    self.lineGround:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(1,cc.p(-display.width,0))
        ,cc.MoveBy:create(0.3,cc.p(display.width,0)))))
    --添加物理边框
    self.lineGround:setPhysicsEnable(true)
end

    --[[向左移动的背景]]
function PlayScene:runBackground()
    local runbg = display.newSprite("background_fog.png"):addTo(self)
    runbg:setPosition(display.cx*3,display.cy)
    runbg:setScale(display.width/runbg:getContentSize().width,display.height/runbg:getContentSize().height)
    runbg:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(3,cc.p(-display.cx*2,0))
            ,cc.CallFunc:create(function ()
                runbg:setPosition(display.cx*3,display.cy)
            end))))
    local runbg2 = display.newSprite("background_fog.png"):addTo(self)
    runbg2:setPosition(display.cx,display.cy)
    runbg2:setScale(display.width/runbg2:getContentSize().width,display.height/runbg2:getContentSize().height)
    runbg2:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(3,cc.p(-display.cx*2,0))
            ,cc.CallFunc:create(function ()
                runbg2:setPosition(display.cx,display.cy)
            end))))
end

    --[[添加英雄]]
function PlayScene:initHero()
    self.hero = Hero.new():addTo(self)
    self.hero:setPosition(display.cx/2,display.cy)
    self.hero:setStartPos(display.cx/2,display.cy)
    self.hero:setTag(111)
    self.hero:changeAct("run",true)
    self.hero:setPhysicsEnable(true,"ver")
    self.hero:reset()

    self.needEvolve = true
    self.needDegeneration = true
    self.isChanging = false
end

    --[[设置‘碰撞监听’]]
function PlayScene:onContact()
    local function onContactBegin(contact)
        local crash = false
        local spriteA = contact:getShapeA():getBody():getNode()
        local spriteB = contact:getShapeB():getBody():getNode()
        if spriteA and spriteA:getTag() == 111 and spriteB and spriteB:getTag() == 111 then
            crash = true
        else
            if self.hero.act == Hero.ACT_FLY then
                crash = true
            elseif self.hero.act == Hero.ACT_SWIM then
                self.hero:swim()
            end
        end
        if crash then
            if DEFAULT:getBoolForKey(EFFECT_KEY) then
                audio.playSound(EFFECT_FAILED_FILE)
            end
            self.hero.needReset = true
            self.hero.restTime = 3
            --更新各种纪录
            if self.fristCrash then
                self:upDateInformation(self.time,true,self.hero.run_time,self.hero.fly_time,self.hero.swim_time)
                self.fristCrash = false

                --定住当前纪录label
                self.recordLabel:setString(string.format("%.1f",self.time))
                self.recordLabel:runAction(cc.TintTo:create(0.5,255,0,0))
                self.recordFontLabel:runAction(cc.TintTo:create(0.5,255,0,0))
            end

            --加层爆血层
            local bloodLayer = cc.LayerColor:create(cc.c4b(255,0,0,0),display.width,display.height)
                :addTo(self)
            bloodLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,0)
                ,cc.CallFunc:create(function ()
                    --如果设置了自动重新开始 那就重新开始咯
                    if DEFAULT:getBoolForKey(AUTO_RESTART_KEY) then 
                        local PlayScene = require("src/app/scenes/PlayScene")
                        local ts = cc.TransitionFade:create(1,PlayScene:new())
                        cc.Director:getInstance():replaceScene(ts)
                    end

                    bloodLayer:removeFromParent()
                end)))

        end
        return true      
    end
    
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self.PhysicalLayer)
end

    --[[更新纪录]]
function PlayScene:upDateInformation(thisTime,isDied,r,f,s)
    if isDied then
        if self.hero.act == Hero.ACT_RUN then
            self:addOneToKey(DIED_RUN_TIME)
        elseif self.hero.act == Hero.ACT_FLY then
            self:addOneToKey(DIED_FLY_TIME)
        elseif self.hero.act == Hero.ACT_SWIM then
            self:addOneToKey(DIED_SWIM_TIME)
        end
        self:addOneToKey(DIED_TOTAL_TIME)
    end

    DEFAULT:setIntegerForKey(JUMP_RUN_TIME,
        DEFAULT:getIntegerForKey(JUMP_RUN_TIME,0) + r)
    DEFAULT:setIntegerForKey(JUMP_FLY_TIME,
        DEFAULT:getIntegerForKey(JUMP_FLY_TIME,0) + f)
    DEFAULT:setIntegerForKey(JUMP_SWIM_TIME,
        DEFAULT:getIntegerForKey(JUMP_SWIM_TIME,0) + s)
    DEFAULT:setIntegerForKey(JUMP_TOTAL_TIME,DEFAULT:getIntegerForKey(JUMP_TOTAL_TIME,0) + r + f + s)

    DEFAULT:setFloatForKey(RECORD_SCORE,thisTime)
    DEFAULT:setFloatForKey(PLAY_TOTAL_SCORE,DEFAULT:getFloatForKey(PLAY_TOTAL_SCORE,0.0) + thisTime)
    DEFAULT:setFloatForKey(PLAY_AVERAGE_SCORE,
        DEFAULT:getFloatForKey(PLAY_TOTAL_SCORE,0.0)/DEFAULT:getIntegerForKey(PLAY_TOTAL_TIME,1))

    local j = 10
    for i=1,10 do
        j = j - 1
        if DEFAULT:getFloatForKey("ranking_"..i,0.0) < thisTime then
            for k=1,j do
                local m = 10 - k + 1
                local n = m - 1
                if DEFAULT:getFloatForKey("ranking_"..n,0.0) ~= 0.0 then
                    DEFAULT:setStringForKey("ranking_name_"..m,DEFAULT:getStringForKey("ranking_name_"..n,""))
                    DEFAULT:setFloatForKey("ranking_"..m,DEFAULT:getFloatForKey("ranking_"..n,0.0))
                end
            end
            DEFAULT:setStringForKey("ranking_name_"..i,DEFAULT:getStringForKey(PLAYER_NAME,"无名傻叼"))
            DEFAULT:setFloatForKey("ranking_"..i, thisTime)
            break
        end
    end
end

    --[[透明层 用来添加触摸监听器 ]]
function PlayScene:initTouchLayer()
    self.touchLayer = BackgroundLayer.new("transparency.png",display.width,display.height)
    self.touchLayer:setLocalZOrder(101)
    self.touchLayer:addTo(self)

    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            self.hero:jump()
            return true
        end
    end)
end

    --[[创建一个自己移动的障碍]]
function PlayScene:createOneBarricade()
    local barricade = Barricade.new(self.hero.act):addTo(self)
    barricade:setPhysicsEnable(true)
    barricade:setTag(111)  
    barricade:runAction(cc.Sequence:create(cc.MoveBy:create(2.5,cc.p(-display.width-barricade.width*2,0))
        ,cc.CallFunc:create(function ()
            barricade:removeFromParent()
        end)))
end

    --[[随机创建下一个动作 并更换背景]]
    --[[ R : run ---- F : fly ---- S : swim ]]
function PlayScene:changeHeroAct(newAct)
    local guess = math.random(1,2)
    if not newAct then
        guess = math.random(1,3)
    end
    if self.hero.act == Hero.ACT_RUN then
        if guess == 1 then
            self.hero:heroRtoF()
            self.hero:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.3)
                ,cc.CallFunc:create(function ()
                    self:moveGround("DOWN")
                end)))
            self:addOneToKey(PLAY_FLY_TIME)
        elseif guess == 2 then
            self.hero:heroRtoS()
            self:moveGround("UP")
            self:addOneToKey(PLAY_SWIM_TIME)
        else
            self:addOneToKey(PLAY_RUN_TIME)
        end
    elseif self.hero.act == Hero.ACT_FLY then
        if guess == 1 then
            self.hero:heroFtoR()
            self:moveGround("UP",true)
            self:addOneToKey(PLAY_RUN_TIME)
        else
            self.hero:heroFtoS()
            self:moveGround("DOUBLE_UP")
            self:addOneToKey(PLAY_SWIM_TIME)
        end
    elseif self.hero.act == Hero.ACT_SWIM then
        if guess == 1 then
            self.hero:heroStoR()
            self:moveGround("DOWN",true)
            self:addOneToKey(PLAY_RUN_TIME)
        else
            self.hero:heroStoF()
            self:moveGround("DOUBLE_DOWN")
            self:addOneToKey(PLAY_FLY_TIME)
        end
    end
end

    --[[上下移动背景和地板]]
function PlayScene:moveGround(dir,needGround)
    --先停掉物理身体
    self.lineGround:setPhysicsEnable(false)
    local moveTime
    local distance
    if dir == "DOWN" then
        moveTime = 1
        distance = -display.height
    elseif dir == "DOUBLE_DOWN" then
        moveTime = 1
        distance = -display.height*2
    elseif dir == "UP" then
        moveTime = 1
        distance = display.height
    elseif dir == "DOUBLE_UP" then
        moveTime = 1
        distance = display.height*2
    end
    self.lineGround:runAction(cc.Sequence:create(
        cc.MoveBy:create(moveTime,cc.p(0,distance))
        ,cc.CallFunc:create(function ()
            if needGround then
                self.lineGround:setPhysicsEnable(true)
            end
        end)))
    --移动背景
    self.backgroundLayer:runAction(cc.MoveBy:create(moveTime,cc.p(0,distance)))
end

    --[[更新时间 包括变化时间 还有]]
function PlayScene:updateTime()
    self.timeLabel:scheduleUpdate()
    self.timeLabel:schedule(function ()
        if self.fristCrash then
            if self.time > DEFAULT:getFloatForKey("ranking_"..self:getLastRanking(self.rankingTime), 0) then
                self.recordLabel:setColor(cc.c3b(41, 205, 0))
                self.recordFontLabel:setColor(cc.c3b(41, 205, 0))
                if self:getLastRanking(self.rankingTime) <= 0 then
                    self.recordLabel:setString(string.format("%.1f",self.time))
                else
                    if DEFAULT:getBoolForKey(EFFECT_KEY) then
                        audio.playSound(EFFECT_CONGRATULATION_FILE)
                    end
                    self.toast  = Toast.new(
                        string.format("超越了第%d名",self:getLastRanking(self.rankingTime))
                        , display.left+300, display.top-50)
                    self.toast:addTo(self)
                    self.rankingTime = self.time
                    self.recordLabel:setString(string.format("%.1f",
                        DEFAULT:getFloatForKey("ranking_"..self:getLastRanking(self.rankingTime), 0)))
                end
            end
        end
        self.time = self.time + 0.1
        self.coolTime = self.coolTime + 0.1
        self.timeLabel:setString(string.format("%.1f",self.time))
        if self.coolTime > self.evolveTime then
            self.coolTime = 0.0
            self:changeHeroAct(true)
        end
        --[[不断加障碍]]
        if (self.evolveTime - 3 > self.coolTime and self.coolTime > 2) and self.hero.heroBody:isEnabled() then
            self.randomTime = self.randomTime - 0.1
            if self.randomTime < 0 then
                self:createOneBarricade()
                self.randomTime = math.random() + 1
                if self.hero.act == Hero.ACT_SWIM then
                    self.randomTime = 1
                end
            end
        end
        --[[更新粒子位置]]
        if self.heroParticle and self.heroParticle.emitter and self.hero then
            self.heroParticle.emitter:setPosition({x = self.hero:getPositionX()
                ,y = self.hero:getPositionY() + self.hero:getContentSize().height/4})
        end
    end,0.1,true)
end

    --[[进入场景后加载粒子 清除缓存]]
function PlayScene:onEnterTransitionFinish()
    if DEFAULT:getBoolForKey(PARTICLE_KEY) then
        --[[创建粒子]]
        self.heroParticle = Particle.new("cube.plist",self.hero:getPosition())
        self.heroParticle:addTo(self)
    end
    --[[清除上一场景的缓存 包括其他动画]]
    TEXTURE_CHACHE:removeUnusedTextures()
    display.removeSpriteFramesWithFile("bigTV.plist","bigTV.png")
    display.removeSpriteFramesWithFile("ball_light.plist","ball_light.png")
    display.removeSpriteFramesWithFile("control.plist","control.png")

    self:updateTime()
end

    --[[加载缓存 ，并回到主场景]]
function PlayScene:setChacheAndBackToFristScene()
    local FristScene = require("src/app/scenes/FristScene")
    local ts = cc.TransitionFade:create(1,FristScene:new())
    cc.Director:getInstance():replaceScene(ts)
end

return PlayScene