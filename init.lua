-- hammerspoon-right-click-minimize
-- 右键快速下滑手势 -> 最小化当前窗口
--
-- 安装: 复制本文件到 ~/.hammerspoon/init.lua，然后在 Hammerspoon 菜单中 Reload Config
-- 详细说明见 README.md

local eventtap = hs.eventtap
local mouse = hs.mouse
local window = hs.window
local timer = hs.timer

-- ============ 可调参数 ============
local MIN_DISTANCE = 30   -- 触发手势所需的最小垂直拖动距离（像素）
local MAX_TIME = 0.8      -- 手势允许的最长持续时间（秒），超过视为普通拖动

-- 手势状态
GestureData = { startPos = nil, startTime = nil, dragDistance = 0 }

-- 执行最小化
local function doMinimize()
    local win = window.focusedWindow()
    if win then
        print("正在最小化窗口: " .. (win:title() or "无标题"))
        win:minimize()
        return true
    end
    print("无法最小化: 无焦点窗口")
    return false
end

-- 主监听器：监听右键的按下 / 拖动 / 抬起
RightClickWatcher = eventtap.new({
    eventtap.event.types.rightMouseDown,
    eventtap.event.types.rightMouseUp,
    eventtap.event.types.rightMouseDragged
}, function(e)
    local eventType = e:getType()
    local currentPos = mouse.getAbsolutePosition()

    if eventType == eventtap.event.types.rightMouseDown then
        -- 记录起点与时间
        GestureData.startPos = {x = currentPos.x, y = currentPos.y}
        GestureData.startTime = timer.secondsSinceEpoch()
        GestureData.dragDistance = 0
        return false

    elseif eventType == eventtap.event.types.rightMouseDragged then
        -- 累计垂直拖动距离
        if GestureData.startPos then
            local deltaY = math.abs(currentPos.y - GestureData.startPos.y)
            GestureData.dragDistance = deltaY
        end
        return false

    elseif eventType == eventtap.event.types.rightMouseUp then
        if not GestureData.startPos then return false end

        local endTime = timer.secondsSinceEpoch()
        local timeTaken = endTime - GestureData.startTime
        local distanceY = GestureData.dragDistance
        local deltaY = currentPos.y - GestureData.startPos.y

        -- 判定：距离够长 + 速度够快 + 方向向下
        if distanceY > MIN_DISTANCE and timeTaken < MAX_TIME and deltaY > 0 then
            print("检测到右键下滑手势")
            doMinimize()
            GestureData.startPos = nil
            return true   -- 吞掉该事件，避免弹出右键菜单
        end

        GestureData.startPos = nil
        return false
    end

    return false
end)

-- 启动监听
RightClickWatcher:start()
print("🎯 右键下滑最小化脚本已启动")
hs.alert.show("右键手势: 快速下滑最小化窗口", 2)
