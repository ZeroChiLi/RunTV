--
-- Author: Your Name
-- Date: 2016- 03- 21 21 :46 :41
--

Hero = import("app.scenes.Hero")
Barricade = import("app.scenes.Barricade")
BackgroundLayer = import("app.scenes.BackgroundLayer")
RunBackground = import("app.scenes.RunBackground")
Particle = import("app.scenes.Particle")
CheckBox = import("app.scenes.CheckBox")
ControlBtn = import("app.scenes.ControlBtn")
ListViewItem = import("app.scenes.ListViewItem")
Toast = import("app.scenes.Toast")

ONE_KEY = "one_key"
AUTO_RESTART_KEY = "restart_key"
NIGHT_KEY = "night_key"
PARTICLE_KEY = "particle_key"
PLAYER_NAME = "playerName"
PLAY_RUN_TIME = "playRunTime"
PLAY_FLY_TIME = "playFlyTime"
PLAY_SWIM_TIME = "playSwimTime"
PLAY_TOTAL_TIME = "playTotalTime"
RECORD_SCORE = "recordScore"
PLAY_TOTAL_SCORE = "playTotalScore"
PLAY_AVERAGE_SCORE = "playAveragerScore"
DIED_TOTAL_TIME = "diedTotalTime"
DIED_RUN_TIME = "diedRunTime"
DIED_FLY_TIME = "diedFlyTime"
DIED_SWIM_TIME = "diedSwimTime"
JUMP_TOTAL_TIME = "jumpTotalTime"
JUMP_RUN_TIME = "jumpRunTime"
JUMP_FLY_TIME = "jumpFlyTime"
JUMP_SWIM_TIME = "jumpSwimTime"
RANKING_1 = "ranking_1"
RANKING_2 = "ranking_2"
RANKING_3 = "ranking_3"
RANKING_4 = "ranking_4"
RANKING_5 = "ranking_5"
RANKING_6 = "ranking_6"
RANKING_7 = "ranking_7"
RANKING_8 = "ranking_8"
RANKING_9 = "ranking_9"
RANKING_10 = "ranking_10"
RANKING_NAME_1 = "ranking_name_1"
RANKING_NAME_2 = "ranking_name_2"
RANKING_NAME_3 = "ranking_name_3"
RANKING_NAME_4 = "ranking_name_4"
RANKING_NAME_5 = "ranking_name_5"
RANKING_NAME_6 = "ranking_name_6"
RANKING_NAME_7 = "ranking_name_7"
RANKING_NAME_8 = "ranking_name_8"
RANKING_NAME_9 = "ranking_name_9"
RANKING_NAME_10 = "ranking_name_10"

EFFECT_KEY = "sound_key"
MUSIC_KEY = "music_key"
EFFECT_FILE = "sound/power.wav"
EFFECT_JUMP_FILE = "sound/jump.wav"
EFFECT_FAILED_FILE = "sound/failed.wav"
EFFECT_CONGRATULATION_FILE = "sound/congratulation.wav"
MUSIC_FILE = "sound/TPCO.mp3"

DEFAULT = cc.UserDefault:getInstance()
TEXTURE_CHACHE = cc.Director:getInstance():getTextureCache()

local FristScene = class("FristScene", function()
    return display.newScene("FristScene")
end)

function FristScene:ctor()
	self.count = 0
	self.total = 29
    self:initAllKey()
	self:initUI()
end

--[[第一次运行游戏的初始化KEY]]
function FristScene:initAllKey()
    if not DEFAULT:getBoolForKey(ONE_KEY) then
    	self.frist = true
        DEFAULT:setBoolForKey(ONE_KEY, true)
        DEFAULT:setBoolForKey(EFFECT_KEY,true)
        DEFAULT:setBoolForKey(MUSIC_KEY,true)
        DEFAULT:setBoolForKey(AUTO_RESTART_KEY,true)
        DEFAULT:setBoolForKey(NIGHT_KEY,false)
        DEFAULT:setBoolForKey(PARTICLE_KEY,false)
        DEFAULT:setIntegerForKey(PLAY_RUN_TIME, 0)
        DEFAULT:setIntegerForKey(PLAY_FLY_TIME, 0)
        DEFAULT:setIntegerForKey(PLAY_SWIM_TIME, 0)
        DEFAULT:setIntegerForKey(PLAY_TOTAL_TIME, 0)
        DEFAULT:setFloatForKey(RECORD_SCORE, 0.0)
        DEFAULT:setFloatForKey(PLAY_TOTAL_SCORE, 0.0)
        DEFAULT:setFloatForKey(PLAY_AVERAGE_SCORE, 0.0)
        DEFAULT:setIntegerForKey(DIED_TOTAL_TIME, 0)
        DEFAULT:setIntegerForKey(DIED_RUN_TIME, 0)
        DEFAULT:setIntegerForKey(DIED_FLY_TIME, 0)
        DEFAULT:setIntegerForKey(DIED_SWIM_TIME, 0)
        DEFAULT:setIntegerForKey(JUMP_TOTAL_TIME, 0)
        DEFAULT:setIntegerForKey(JUMP_RUN_TIME, 0)
        DEFAULT:setIntegerForKey(JUMP_FLY_TIME, 0)
        DEFAULT:setIntegerForKey(JUMP_SWIM_TIME, 0)
        DEFAULT:setStringForKey(RANKING_NAME_1,"当然是炽利帅哥")
        DEFAULT:setFloatForKey(RANKING_1,233.33)
    end
end

function FristScene:initUI()
	local background = display.newSprite("poster.png"):addTo(self)
	background:setAnchorPoint(0.5,0.5)
	background:setPosition(display.cx,display.cy)
	local slide_empty = display.newScale9Sprite("slide_empty.png"
		,display.cx,display.cy/5,cc.size(display.width/3*2,50)):addTo(self)
	-- local slide_full = display.newScale9Sprite("slide_full2.png"
	-- 	,display.cx,display.cy/5,cc.size(display.width/3*2,50)):addTo(self)
	self.slide_full = cc.ui.UILoadingBar.new({scale9 = true
		,capInsets = cc.rect(20,20,160,60)
		,image = "slide_full2.png"
		,viewRect = cc.rect(0,0,display.width/3*2,50)
		,percent = 0}):addTo(self)
	self.slide_full:setPosition(display.cx-display.width/3,display.cy/5-25)

	self.persentLabel = cc.ui.UILabel.new({text = "0.0%"
		,font = "fonts/STENCILSTD.OTF",size = 30,color = cc.c3b(49, 59, 100)})
        :align(display.CENTER, display.cx, display.cy/5-5)
        :addTo(self)
end

function FristScene:initTexture()
	display.addSpriteFrames("hero/TV.plist","hero/TV.png")
	display.addSpriteFrames("bigTV.plist","bigTV.png")
    display.addSpriteFrames("ball_light.plist","ball_light.png")
    display.addSpriteFrames("control.plist","control.png")
    local function setChache(name,framesName,from,to,fps)
        if not display.getAnimationCache(name) then
            display.setAnimationCache(name
                ,display.newAnimation(display.newFrames(framesName,from,to),fps))
        end
    end
    setChache("bigtv_normal","bigTV_normal_%02d.png",0,6,0.2)
    setChache("bigtv_pressed","bigTV_pressed_%02d.png",0,6,0.2)
    setChache("ballLight","light_%02d.png",0,8,0.3)
    setChache("ballLight_fast","light_%02d.png",0,8,0.1,true)
    setChache("control_pressed","control_%02d.png",0,4,0.1)
    setChache("changeChannel","changeChannel_%02d.png",0,5,0.1)
	setChache("tv_stand","TV_Stand_%02d.png",0,4,0.3)
	setChache("tv_moonwalk","TV_MoonWalk_%02d.png",0,4,0.3)
    setChache("tv_run","TV_Run_%02d.png",0,4,0.1)
    setChache("tv_jump","TV_Jump_%02d.png",1,4,0.1)
	setChache("tv_evolve","TV_Evolve_%02d.png",0,9,0.1)
	setChache("tv_fly","TV_Fly_%02d.png",0,4,0.2)
    setChache("tv_flap","TV_Flap_%02d.png",0,4,0.1)
	setChache("tv_degeneration","TV_Degeneration_%02d.png",1,7,0.1)
	setChache("tv_dive","TV_Dive_%02d.png",0,3,0.1)
	setChache("tv_emersion","TV_Emersion_%02d.png",0,3,0.1)
	setChache("tv_swim","TV_Swim_%02d.png",0,4,0.1)
    setChache("tv_turn","TV_turn_%02d.png",0,2,0.1)

    audio.preloadMusic(MUSIC_FILE)
    audio.preloadSound(EFFECT_FILE)
    audio.preloadSound(EFFECT_JUMP_FILE)
    audio.preloadSound(EFFECT_FAILED_FILE)
    audio.preloadSound(EFFECT_CONGRATULATION_FILE)

	TEXTURE_CHACHE:addImageAsync("background.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("background_fog.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("barricade_0.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("barricade_1.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("barricade_2.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("barricade_3.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("barricade_4.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("black.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("black_background.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("editbox.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("editbox2.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("line_4.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("transparency.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("TV_Dog.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("white.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/achievement_normal.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/achievement_pressed.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/help_normal.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/help_pressed.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/setting_normal.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/setting_pressed.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/back_normal_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/back_pressed_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/restart_normal_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/restart_pressed_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/stop_normal_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/stop_pressed_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/continue_normal_m.png",handler(self,self.updateSlide))
	TEXTURE_CHACHE:addImageAsync("button/continue_pressed_m.png",handler(self,self.updateSlide))
end

function FristScene:updateSlide()
	self.count = self.count + 1
	percent = self.count / self.total * 100
	self.slide_full:setPercent(percent)
	self.persentLabel:setString(string.format("%.1f%%",percent))

	if self.count == self.total then
		self.persentLabel:runAction(cc.Sequence:create(cc.DelayTime:create(1),
			cc.CallFunc:create(function ()
				local scene
				if self.frist then
					scene = require("src/app/scenes/HelpScene")
				else
					scene = require("src/app/scenes/MainScene")
				end
		        local ts = cc.TransitionFade:create(1,scene:new())
		        cc.Director:getInstance():replaceScene(ts)	
			end)))
    end
end

function FristScene:onEnter()
	self:initTexture()
end

return FristScene