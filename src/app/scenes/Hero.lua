
--[[英雄]]

local Hero = class("Hero",function()
	local hero = display.newSprite("#TV_Stand_00.png")
	--三种物理bodySize
	hero.verSize = {width = hero:getContentSize().width/3, height = hero:getContentSize().height}
	hero.horSize = {width = hero:getContentSize().width/3*2, height = hero:getContentSize().height/2}
	hero.hor2Size = {width = hero:getContentSize().width/3*2, height = hero:getContentSize().height/10*3}
	--初始化各种英雄属性
	hero.jump = false
	hero.act = "ACTION_RUNNING"
	hero.restTime = 0
    hero.needReset = false
    hero.startX = display.cx/2
    hero.startY = display.cy
    hero.swimDir = "down"
    hero.run_time = 0
    hero.fly_time = 0
    hero.swim_time = 0
	return hero
end)

Hero.ACT_RUN = "ACTION_RUNNING"
Hero.ACT_FLY = "ACTION_FLYING"
Hero.ACT_SWIM = "ACTION_SWIMMING"
Hero.ACT_CHANGE = "ACTION_CHANGING"

function Hero:setStartPos(x,y)
	self.startX = x
	self.startY = y
end

function Hero:setPhysicsEnable(enabled,dir)
	--[[设置是否要物理身体]]
	if enabled then
		local size = self:getContentSize()
		if dir == "ver" then
			size = self.verSize
		elseif dir == "hor" then
			size = self.horSize
		elseif dir == "hor2" then
			size = self.hor2Size
		end
        if dir == "hor" then
            --[[~~~~~~~~~~~！！！！！！！！！！！！！~~~~~~~~~~~~~~~~
                -----------------前方高能----------------------------
                搞多边形的时候，一定要是凸的，凹的话会懵逼，发烂渣，
                而且不用参数表示顶点个数， 要不然会炸]]
            local p_array = {}
            table.insert(p_array,cc.p(-55,-20))
            table.insert(p_array,cc.p(-20,25))
            table.insert(p_array,cc.p(20,25))
            table.insert(p_array,cc.p(55,-20))
            table.insert(p_array,cc.p(0,-30))
            self.heroBody = cc.PhysicsBody:createPolygon(p_array,cc.PhysicsMaterial(0.1,0,0))
        else
            self.heroBody = cc.PhysicsBody:createBox(size,cc.PhysicsMaterial(0.1,0,0))
        end
        self.heroBody:setContactTestBitmask(0x2)
        self.heroBody:setRotationEnable(false)
        self.heroBody:setMass(1)
		self:setPhysicsBody(self.heroBody)
	else
		if self.heroBdoy then
			self.heroBody:setEnable(false)
		end
	end
end

function Hero:jump()
	if self.heroBody:isEnabled() then
        if self.act == "ACTION_RUNNING" then
            if not self.isJump then
                if DEFAULT:getBoolForKey(EFFECT_KEY) then
                    audio.playSound(EFFECT_JUMP_FILE)
                end
                self.run_time = self.run_time + 1
                self.heroBody:setVelocity({x=0,y=0})
                self.heroBody:applyImpulse({x=0,y=400})
                self.isJump = true
                self:changeAct("jump", false)
                self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function ()
                        self.isJump = false
                        self:changeAct("run",true)
                    end)))
            end
        elseif self.act == "ACTION_FLYING" then
            if DEFAULT:getBoolForKey(EFFECT_KEY) then
                audio.playSound(EFFECT_JUMP_FILE)
            end
            self:changeAct("flap",false)
            self.isFlap = true
            self.fly_time = self.fly_time + 1
            self.heroBody:applyImpulse({x=0,y=400})
        elseif self.act == "ACTION_SWIMMING" then
            self.swim_time = self.swim_time + 1
        	self:swim()
		end
    end
end

function Hero:swim()
    if DEFAULT:getBoolForKey(EFFECT_KEY) then
        audio.playSound(EFFECT_JUMP_FILE)
    end
    self.isSwimTurn = true
    self:changeAct("turn", false)
	if self.swimDir == "up" then
		self.swimDir = "down"
        -- self:changeAct("swim_up")
        self.heroBody:setVelocity({x=0,y=400})
        self.heroBody:setPositionOffset({x = self.hor2Size.width/8,y = self.hor2Size.height/3})
        self:setRotation(-45)
    elseif self.swimDir == "down" then
        self.swimDir = "up"
        -- self:changeAct("swim_dowm")
		self.heroBody:setVelocity({x=0,y=-400})
        self.heroBody:setPositionOffset({x = self.hor2Size.width/8,y = self.hor2Size.height/-3})
		self:setRotation(45)
	end
end

function Hero:reset()
	--[[更新英雄调度器  休息时间 变换动作后恢复]]
	self:scheduleUpdate()
    self:schedule(function ()
        -- print(self.heroBody:getVelocityLimit()) 
        --飞行时加速旋转后恢复
        if self.isFlap then
            self.isFlap = false
            self.flapTime = 0.4
        end
        if self.flapTime then
            if self.flapTime > 0 then
                self.flapTime = self.flapTime - 0.2
            elseif self.flapTime == 0 then
                self:changeAct("fly", true)
                self.flapTime = nil
            else
                self.flapTime = nil
            end
        end
        --游泳变向后变直
        if self.isSwimTurn then
            self.isSwimTurn = false
            self.turnTime = 0.2
        end
        if self.turnTime then
            if self.turnTime > 0 then
                self.turnTime = self.turnTime - 0.2
            elseif self.turnTime == 0 then
                self:changeAct("swim", true)
                self.turnTime = nil
            else
                self.turnTime = nil
            end
        end
        if self.restTime > 0 then
            self.restTime = self.restTime - 0.2
            self.heroBody:setEnable(false)
        else
            if self.restTime < 0 and not self.heroBody:isEnabled() then
                self.heroBody:setEnable(true)
            end
        end
        if self.needReset then
            self.needReset = false
            self:runAction(cc.Sequence:create(
            	cc.Spawn:create(cc.Blink:create(self.restTime, self.restTime*3)
                	,cc.MoveTo:create(0.5,cc.p(self.startX,self.startY)))
            	,cc.CallFunc:create(function ()
                    self.heroBody:setVelocity({x=0,y=0})
		            if self.act == "ACTION_SWIMMING" then
			            self:swim()
		            end
            	end)))
        end
    end,0.2,true)
end

function Hero:stopAct()
	--[[终止最后的动作]]
	if self.lastAction then
		transition.removeAction(self.lastAction)
	end
end

function Hero:changeAct(act,isForever)
    --先终止掉前面的动作
    self:stopAct()
    --改变状态
    if act == "run" or act == "jump" then
        self.act = "ACTION_RUNNING"
    elseif act == "fly" or act == "flap" then
        self.act = "ACTION_FLYING"
    elseif act == "swim" or act == "turn"then
        self.act = "ACTION_SWIMMING"
    else
        self.act = "ACTION_CHANGING"
        self.flapTime = -1
        self.turnTime = -1
    end

    --[[改变当前动作]]
    local action = display.getAnimationCache("tv_"..act)
    if action then
        if isForever then
			self.lastAction = self:playAnimationForever(action,0)
		else
			self.lastAction = self:playAnimationOnce(action)
		end
	else
		printError("Hero:changeAct() --丢你，没有这个动作 -((tv_%s))-",act)
	end
end

    --[[ R : run ---- F : fly ---- S : swim ]]

function Hero:heroRtoF()
    self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ()
                self:setRotation(0)
                self:changeAct("evolve", false)
                self.restTime = 1.5
            end)
            ,cc.DelayTime:create(0.3)
            ,cc.EaseSineIn:create(cc.MoveTo:create(0.7,cc.p(self.startX,self.startY)))
            ,cc.CallFunc:create(function ()
                self:changeAct("fly", true)
                self:setPhysicsEnable(true, "hor")
                self.heroBody:applyImpulse({x=0,y=400})
            end)))
end

function Hero:heroRtoS()
    self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ()
                self:changeAct("dive", false)
                self.restTime = 1.5
            end)
            ,cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(self.startX,self.startY)))
            ,cc.CallFunc:create(function ()
                self:changeAct("swim", true)
                self:setPhysicsEnable(true, "hor2")
                self.heroBody:setGravityEnable(false)
                self:swim()
            end)))
end

function Hero:heroFtoR()
    self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ()
                self:setRotation(0)
                self:changeAct("degeneration", false)
                self.restTime = 1.5
            end)
            ,cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(self.startX,self.startY)))
            ,cc.CallFunc:create(function ()
                self:changeAct("run", true)
                self:setPhysicsEnable(true, "ver")
                self.heroBody:applyImpulse({x=0,y=200})
            end)))
end

function Hero:heroFtoS()
    self:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(self.startX,self.startY)))
                ,cc.Sequence:create(
                    cc.CallFunc:create(function ()
                        self:changeAct("degeneration", false)
                        self.restTime = 1.5
                    end)
                    ,cc.DelayTime:create(0.7)
                    ,cc.CallFunc:create(function ()
                        self:changeAct("dive", false)
                    end)
                    ,cc.DelayTime:create(0.3)
                    ))
            ,cc.CallFunc:create(function ()
                self:changeAct("swim", true)
                self:setPhysicsEnable(true, "hor2")
                self.heroBody:setGravityEnable(false)
                self:swim()
            end)))
end

function Hero:heroStoR()
     self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ()
                self:setRotation(0)
                self:changeAct("emersion", false)
                self.restTime = 1.5
            end)
            ,cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(self.startX,self.startY)))
            ,cc.CallFunc:create(function ()
                self:changeAct("run", true)
                self:setPhysicsEnable(true, "ver")
                self.heroBody:applyImpulse({x=0,y=200})
            end)))
end

function Hero:heroStoF()
    self:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(self.startX,self.startY)))
            ,cc.Sequence:create(
                cc.CallFunc:create(function ()
                    self:setRotation(0)
                    self:changeAct("emersion", false)
                    self.restTime = 1.5
                end)
                ,cc.DelayTime:create(0.3)
                ,cc.CallFunc:create(function ()
                    self:changeAct("evolve", false)
                end)
                ,cc.DelayTime:create(0.7)
                ))
        ,cc.CallFunc:create(function ()
            self:changeAct("fly", true)
            self:setPhysicsEnable(true, "hor")
            self.heroBody:applyImpulse({x=0,y=400})
        end)))
end

return Hero