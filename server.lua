local Player_data = {}
local CloudData = {}

local function Player_Beat_info()       -- 玩家自己的数据
    for k, _ in pairs(Player_data) do
        local result, value = VarLib2:getPlayerVarByName(k, 3, "击杀数")        -- 获取要排行的玩家个人数据
        Player_data[k] = value      -- 添加到全局以便上传
    end
end

local function func_event(param)        -- 编码完事后通过迷你的自定义事件把数据传给client
    local ok, json = pcall(JSON.encode, JSON, param)
    Game:dispatchEvent("GetServerData", { customdata = json })
end

local function PullServer()
    local callback = function(ret, value)
        if ret == ErrorCode.OK and value then
            for k, v in ipairs(value) do
                CloudData[k] = v
            end
            func_event(CloudData)
        end
    end
    -- 从云端拉取数据
    local ret = CloudSever:getOrderDataIndexAreaEx("rank_1755592011", -100, callback)       -- 下载
end

local function PushServer(e)
    local current = e.second
    if (current ~= nil and current >= 10 and (current - 10) % 10 == 0) then     -- 10、20、30，强烈推荐这三个值
        Player_Beat_info()
        for k, v in pairs(Player_data) do
            local ret = CloudSever:setOrderDataBykey("rank_1755592011", k, v)       -- 上传
        end
        PullServer()
    end
end

--初始化服务，让排行榜有数据，不然是空的
local function InitServer(e)
    local result, value = VarLib2:getPlayerVarByName(e.eventobjid, 3, "击杀数")
    Player_data[e.eventobjid] = value
    PullServer()
end

local function Player_Close(e)      -- 玩家退出后清数据，防止数据重复上传导致请求上限
    Player_data[e.eventobjid] = nil
end

-- 仨事件都能看得懂，定时上传、初始化、清理
ScriptSupportEvent:registerEvent("Game.RunTime", PushServer)
ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", InitServer)
ScriptSupportEvent:registerEvent("Game.AnyPlayer.LeaveGame", Player_Close)