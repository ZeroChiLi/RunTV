--
-- Author: Your Name
-- Date: 2016- 03- 16 11 :01 :28
--
--[[创建粒子]]
--[[参数 ：粒子plist文件位置，发射器相对位置]]
local Particle = class("Particle",function(plist,x,y)
	local emitter = cc.ParticleSystemQuad:create(plist)
    emitter:setPosition(cc.p(x,y))
    emitter:setAutoRemoveOnFinish(true)
    local batch = cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
    batch:addChild(emitter)

    batch.emitter = emitter
    return batch
end)

return Particle