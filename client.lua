local Data = {}
local id_ui = {     -- 名字序列
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

local beat_ui = {       -- 排序值序列
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

local mini_ui = {       -- 迷你号序列
    "7540194344203696498-149492_13",
    "7540194344203696498-149492_18",
    "7540194344203696498-149492_23",
    "7540194344203696498-149492_28",
    "7540194344203696498-149492_29",
    "7540194344203696498-149492_33",
    "7540194344203696498-149492_38",
    "7540194344203696498-149492_43",
    "7540194344203696498-149492_48",
    "7540194344203696498-149492_53",
    "7540194344203696498-149492_58"
}

local rand_ui = {       -- 名次序列
    "7540194344203696498-149492_13",
    "7540194344203696498-149492_18",
    "7540194344203696498-149492_23",
    "7540194344203696498-149492_28",
    "7540194344203696498-149492_29",
    "7540194344203696498-149492_33",
    "7540194344203696498-149492_38",
    "7540194344203696498-149492_43",
    "7540194344203696498-149492_48",
    "7540194344203696498-149492_53",
    "7540194344203696498-149492_58"
}

local my_ui = {     -- 自己四个数据序列
    "7540194344203696498-149492_61",     --自己排名
    "7540194344203696498-149492_62",         --自己名字
    "7540194344203696498-149492_63",         --自己迷你号
    "7540194344203696498-149492_64",         --自己击杀数
}

local page_ui = {       -- 页相关
    "7540194344203696498-149492_70", --页码
    "7540194344203696498-149492_65", --左翻
    "7540194344203696498-149492_66", --右翻
}

local page = 1      -- 当前页码
local pagesize = 10      -- 每页显示的条数


--自定义事件监听
local function func_event(param)        -- 从server那边搞过来的数据，自定义事件传递
    local ret, data = pcall(JSON.decode,JSON,param.customdata)
    Data = data or {}
end

local function My_info(eventobjid)      -- 自己数据的处理
    local found = false
    for k, v in ipairs(Data) do
        if v.k == tostring(eventobjid) then       -- 改v.k，前100
            found = true
            Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[1], tostring(k))
            Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[2], v.nick or "")
            Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[3], v.k or "")
            Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[4], tostring(v.v) or "")
            break
        end
    end
    if not found then       -- 100开外
        Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[1], "99+")
        local result,name=Player:getNickname(eventobjid)
        Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[2], name)
        Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[3], tostring(eventobjid) or "")
        local result, value = VarLib2:getPlayerVarByName(eventobjid, 3, "击杀数")
        Customui:setText(eventobjid, "7540194344203696498-149492", my_ui[4], tostring(value) or "")
    end
end

local function Render(eventobjid)       -- 渲染主函数
    local startIndex = (page - 1) * pagesize + 1
    local endIndex = math.min(page * pagesize, #Data)
    Customui:setText(eventobjid, "7540194344203696498-149492", page_ui[1], page)      -- 页码
    for k, v in ipairs(rand_ui) do
        local index = startIndex + k - 1
        local rand = (index >= startIndex and index <= endIndex) and tostring(index) or ""
        Customui:setText(eventobjid, "7540194344203696498-149492", v, rand)
    end
    for k, v in ipairs(id_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[index]
        local nick = (dataItem and dataItem["nick"]) or ""
        Customui:setText(eventobjid, "7540194344203696498-149492", v, nick)
    end
    for k, v in ipairs(mini_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[index]
        local kValue = (dataItem and dataItem["k"]) or ""
        Customui:setText(eventobjid, "7540194344203696498-149492", v, kValue)
    end
    for k, v in ipairs(beat_ui) do
        local index = startIndex + k - 1
        local dataItem = Data[index]
        local vValue = (dataItem and tostring(dataItem["v"])) or ""
        Customui:setText(eventobjid, "7540194344203696498-149492", v, vValue)
    end
    My_info(eventobjid) -- 渲染自己的信息
end

local function LeftPage(e)      -- 左翻
    if e.uielement == page_ui[2] then
        if page > 1 then
            page = page - 1
            Render(e.eventobjid)
        else
            local result = Player:notifyGameInfo2Self(e.eventobjid, "已经是第一页了！")
        end
    end
end

local function RightPage(e)     -- 右翻
    if e.uielement == page_ui[3] then
        if page < math.ceil(#Data / pagesize) then
            page = page + 1
            Render(e.eventobjid)
        else
            local result = Player:notifyGameInfo2Self(e.eventobjid, "没有更多啦！")
        end
    end
end

local function OnOpenUI(e)      -- 每次打开页面都渲染，打开逻辑需要自己加，或者触发器里拼
    --打开界面渲染
    Render(e.eventobjid)
end

local function OnCloseUI()
    page = 1
end

ScriptSupportEvent:registerEvent('GetServerData', func_event)
ScriptSupportEvent:registerEvent('UI.Button.Click', LeftPage)
ScriptSupportEvent:registerEvent('UI.Button.Click', RightPage)
ScriptSupportEvent:registerEvent('UI.Show', OnOpenUI)
ScriptSupportEvent:registerEvent('UI.Hide', OnCloseUI)