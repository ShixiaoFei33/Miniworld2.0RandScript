--------------------元数据分割线--------------------
local Data = {}
local player_data = {}
local id_ui = {     -- 名字序列(由上到下，不限数量)
    "7540194344203696498-149492_12",
    "7540194344203696498-149492_17",
    "7540194344203696498-149492_22",
    "7540194344203696498-149492_27",
    "7540194344203696498-149492_32",
    "7540194344203696498-149492_37",
    "7540194344203696498-149492_42",
    "7540194344203696498-149492_47",
    "7540194344203696498-149492_52",
    "7540194344203696498-149492_57"
}

local data_ui = {       -- 排序值序列(由上到下，不限数量)
    "7540194344203696498-149492_14",
    "7540194344203696498-149492_19",
    "7540194344203696498-149492_24",
    "7540194344203696498-149492_29",
    "7540194344203696498-149492_34",
    "7540194344203696498-149492_39",
    "7540194344203696498-149492_44",
    "7540194344203696498-149492_49",
    "7540194344203696498-149492_54",
    "7540194344203696498-149492_59"
}

local mini_ui = {       -- 迷你号序列(由上到下，不限数量)
    "7540194344203696498-149492_13",
    "7540194344203696498-149492_18",
    "7540194344203696498-149492_23",
    "7540194344203696498-149492_28",
    "7540194344203696498-149492_33",
    "7540194344203696498-149492_38",
    "7540194344203696498-149492_43",
    "7540194344203696498-149492_48",
    "7540194344203696498-149492_53",
    "7540194344203696498-149492_58"
}

local rand_ui = {       -- 名次序列(由上到下，不限数量)
    "7540194344203696498-149492_11",
    "7540194344203696498-149492_16",
    "7540194344203696498-149492_21",
    "7540194344203696498-149492_26",
    "7540194344203696498-149492_31",
    "7540194344203696498-149492_36",
    "7540194344203696498-149492_41",
    "7540194344203696498-149492_46",
    "7540194344203696498-149492_51",
    "7540194344203696498-149492_56",
}

local my_ui = {     -- 自己四个数据序列
    "7540194344203696498-149492_61",     --自己排名
    "7540194344203696498-149492_62",         --自己名字
    "7540194344203696498-149492_63",         --自己迷你号
    "7540194344203696498-149492_64",         --自己击杀数
}

local page_ui = {       -- 页相关
    "7540194344203696498-149492_70", -- 页码
    "7540194344203696498-149492_65", -- 左翻
    "7540194344203696498-149492_66", -- 右翻
    "已经是第一页了！",-- 左翻提示信息
    "没有更多啦！" -- 右翻提示信息
}

local convert_units = {     --单位转换(科学计数法)
    {value = 1e20, name = "垓"},
    {value = 1e16, name = "京"},
    {value = 1e12, name = "兆"},
    {value = 1e8,  name = "亿"},
    {value = 1e4,  name = "万"}
}

local ui = "7540194344203696498-149492"     -- 当前UI页

local pagesize = 10      -- 每页显示的条数
local RandPage = {      -- 排行榜按钮(对应UI由上到下，由左到右)
    "7540194344203696498-149492_67",
    "7540194344203696498-149492_72"
}
local Rand_vValue = {       --排行的变量名，与RankPage顺序必须一致
    "qishi",
    "danshi"
}
--------------------元数据分割线--------------------

local function Convert(num)
    if num == nil then
        return ""
    end
    if num < 10000 then
        if num == math.floor(num) then
            return tostring(math.floor(num))
        else
            return tostring(num)
        end
    end
    
    for _, unit in ipairs(convert_units) do
        if num >= unit.value then
            local quotient = num / unit.value
            quotient = math.floor(quotient * 100) / 100
            if quotient == math.floor(quotient) then
                quotient = math.floor(quotient)
            end
            return tostring(quotient) .. unit.name
        end
    end
end

local function My_info(eventobjid)      -- 自己数据的处理
    local found = false
    for k, v in ipairs(Data[player_data[eventobjid].currentRankIndex]) do
        if v.k == tostring(eventobjid) then       -- 改v.k，前100
            found = true
            Customui:setText(eventobjid, ui, my_ui[1], tostring(k))
            Customui:setText(eventobjid, ui, my_ui[2], v.nick or "")
            Customui:setText(eventobjid, ui, my_ui[3], v.k or "")
            Customui:setText(eventobjid, ui, my_ui[4], Convert(v.v) or "")
            break
        end
    end
    if not found then
        Customui:setText(eventobjid, ui, my_ui[1], "99+")
        local result,name=Player:getNickname(eventobjid)
        Customui:setText(eventobjid, ui, my_ui[2], name)
        Customui:setText(eventobjid, ui, my_ui[3], tostring(eventobjid) or "")
        local result, value = VarLib2:getPlayerVarByName(eventobjid, 3, Rand_vValue[player_data[eventobjid].currentRankIndex])
        Customui:setText(eventobjid, ui, my_ui[4], Convert(value) or "")
    end
end

local function Render(eventobjid)       -- 渲染主函数
    local startIndex = (player_data[eventobjid].page - 1) * pagesize + 1
    local endIndex = math.min(player_data[eventobjid].page * pagesize, #Data[player_data[eventobjid].currentRankIndex])
    Customui:setText(eventobjid, ui, page_ui[1], player_data[eventobjid].page)      -- 页码
    for k, v in ipairs(rand_ui) do
        local index = startIndex + k - 1
        local rand = (index >= startIndex and index <= endIndex) and tostring(index) or ""
        Customui:setText(eventobjid, ui, v, rand)
    end
    for k, v in ipairs(id_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[player_data[eventobjid].currentRankIndex][index]
        local nick = (dataItem and dataItem.nick) or ""
        Customui:setText(eventobjid, ui, v, nick)
    end
    for k, v in ipairs(mini_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[player_data[eventobjid].currentRankIndex][index]
        local kValue = (dataItem and dataItem.k) or ""
        Customui:setText(eventobjid, ui, v, kValue)
    end
    for k, v in ipairs(data_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[player_data[eventobjid].currentRankIndex][index]
        vValue = (dataItem and dataItem.v) or ""
        Customui:setText(eventobjid, ui, v, Convert(tonumber(vValue)))
    end
    My_info(eventobjid) -- 渲染自己的信息
end

-- 接收来自server的信息
local function func_event(param)        -- 从server那边搞过来的数据，自定义事件传递
    local ret, data = pcall(JSON.decode,JSON,param.customdata)
    Data = data or {}
    for k, _ in pairs(player_data) do
        Render(k)
    end
end

local function LeftPage(e)      -- 左翻
    if e.uielement == page_ui[2] then
        if player_data[e.eventobjid].page > 1 then
            player_data[e.eventobjid].page = player_data[e.eventobjid].page - 1
            Render(e.eventobjid)
        else
            local result = Player:notifyGameInfo2Self(e.eventobjid, page_ui[4])
        end
    end
end

local function RightPage(e)     -- 右翻
    if e.uielement == page_ui[3] then
        if player_data[e.eventobjid].page < math.ceil(#Data[player_data[e.eventobjid].currentRankIndex] / pagesize) then
            player_data[e.eventobjid].page = player_data[e.eventobjid].page + 1
            Render(e.eventobjid)
        else
            local result = Player:notifyGameInfo2Self(e.eventobjid, page_ui[5])
        end
    end
end

local function ChangeRand(e)
    for index, value in ipairs(RandPage) do
        if value == e.uielement then
            player_data[e.eventobjid].currentRankIndex = index
            player_data[e.eventobjid].page = 1
            Render(e.eventobjid)
            break
        end
    end
end

local function OnOpenUI(e)      -- 每次打开页面都渲染，打开逻辑需要自己加，或者触发器里拼
    player_data[e.eventobjid] = {page = 1, currentRankIndex = 1}
    Render(e.eventobjid)
end

local function OnPlayerLeaveGame(e)
    player_data[e.eventobjid] = nil
end

ScriptSupportEvent:registerEvent('GetServerData', func_event)
ScriptSupportEvent:registerEvent('UI.Button.Click', LeftPage)
ScriptSupportEvent:registerEvent('UI.Button.Click', RightPage)
ScriptSupportEvent:registerEvent('UI.Button.Click', ChangeRand)
ScriptSupportEvent:registerEvent('UI.Show', OnOpenUI)
ScriptSupportEvent:registerEvent('Game.AnyPlayer.LeaveGame', OnPlayerLeaveGame)
