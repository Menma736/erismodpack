---@diagnostic disable: trailing-space
local M = {}

function M.calcSpread(api, num, spread)
    -- 初始化计数器
    local cache = api:getCachedScriptData()
    if (cache == nil) then
        cache = {
            melee_light_count = 0
        }
    end
    if (api:getFireMode() == AUTO) then
        return{0,0}
    end
    -- 根据计数器返回弹道形状
    if (cache.melee_light_count == 0) then
        return{(((-1)^num)*num)/3,-((-1)^num*num)/18}
    elseif (cache.melee_light_count == 1) then
        return{-(((-1)^num)*num)/3,-((-1)^num*num)/18}
    elseif (cache.melee_light_count == 2) then
        return{(((-1)^num)*num)/3,-((-1)^num*num)/50}
    elseif (cache.melee_light_count == 200) then
        return{-(((-1)^num)*num)/18,-((-1)^num*num)/3}
    elseif (cache.melee_light_count == 3) then
        return{0,0}
    end
end

function M.shoot(api)
    -- 初始化计数器
    local cache = api:getCachedScriptData()
    if (cache == nil) then
        cache = {
            melee_light_count = 0
        }
    end
    -- 重置计数器
    local last_shoot_timestamp = api:getLastShootTimestamp()
    local current_timestamp = api:getCurrentTimestamp()
    local shoot_interval = api:getShootInterval()
    if (current_timestamp - last_shoot_timestamp > shoot_interval + 400) then
        cache.melee_light_count = 0
    end
    -- 初始化射速计数器
    if (api:getShootInterval() >= 400) then
        api:adjustShootInterval(300-api:getShootInterval())
    end
    -- 攻击
    if (api:getFireMode() == SEMI) then
        if (cache.melee_light_count == 0) then
            api:shootOnce(false)
            cache.melee_light_count = 1
        elseif (cache.melee_light_count == 1) then
            api:shootOnce(false)
            cache.melee_light_count = 2
        elseif (cache.melee_light_count == 2) then
            api:adjustShootInterval(250)
            api:shootOnce(false)
            cache.melee_light_count = 200
            api:safeAsyncTask(function ()
                    api:shootOnce(false)
                    cache.melee_light_count = 3
                    return false
                end,1480,0,1)
        elseif (cache.melee_light_count == 3) then
            api:adjustShootInterval(400)
            api:safeAsyncTask(function ()
                api:shootOnce(false)
                api:shootOnce(false)
                cache.melee_light_count = 0
                return false
            end,1200,0,1)
        end
    else
        api:shootOnce(false)
    end
    api:cacheScriptData(cache)
end

return M