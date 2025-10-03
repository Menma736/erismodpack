local M = {}

function M.shoot(api)
    if(api:getFireMode() == AUTO)then
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    elseif (api:getFireMode() == BURST) then
        if(api:getAmmoCountInMagazine()>1)then
            api:shootOnce(api:isShootingNeedConsumeAmmo())
        end
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    end
end

local function getReloadType(api)
    local type = 0
    if (api:getAmmoAmount() > 1) then
        type = 0
    elseif(api:getAmmoAmount() == 1)then
        type = 1
    elseif (api:getAmmoAmount() == 0) then
        type = 2
    end
    return type
end

function M.start_reload(api)
    
    local cache = {
        reloaded = 0,
        needed_count = api:getNeededAmmoAmount(),
        is_tactical = api:getReloadStateType() == TACTICAL_RELOAD_FEEDING,
        reload_type = 0, -- 0 战术， 1 左手， 2 空枪
    }
    cache.reload_type = getReloadType(api)
    api:cacheScriptData(cache)
    return true
end

local function getReloadTimingFromParam(param)
    local reload_tactical_feed = param.reload_tactical_feed * 1000
    local reload_tactical_cooldown = param.reload_tactical_cooldown * 1000
    local reload_last_feed = param.reload_last_feed * 1000
    local reload_last_cooldown = param.reload_last_cooldown * 1000
    local reload_empty_feed = param.reload_empty_feed * 1000
    local reload_empty_cooldown = param.reload_empty_cooldown * 1000
    if (reload_tactical_feed == nil or reload_tactical_cooldown == nil or reload_last_feed == nil or reload_last_cooldown == nil or reload_empty_feed == nil or reload_empty_cooldown == nil) then
        return nil
    end
    return reload_tactical_feed, reload_tactical_cooldown, reload_last_feed, reload_last_cooldown, reload_empty_feed, reload_empty_cooldown
end


return M