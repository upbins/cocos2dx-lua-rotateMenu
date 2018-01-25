-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      伪立体菜单实现
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
CallRotateMenu = class("CallRotateMenu", function()
	return ccui.Widget:create()
end)

MENU_ASLOPE = 60
function CallRotateMenu:ctor(lenght)
    self.item_list = {} --按钮列表
    self.partner_list = {}
    self.select_item = nil --已选择
    self.index = 0
    self.last_index = 0
    self.cur_last_index = 0
    self.move_index = 0
    self:setContentSize(cc.size(1000,450))
    self:setAnchorPoint(0.5,0.5)
    self.lenght = lenght or 0
    self.close = true
    self.is_show = false
    self.is_not_can_touch  = false
    local function onTouchBegan(touch, event)
        if self.item_list and tableLen(self.item_list) ~= 0 and self.is_not_can_touch  == false then
            for i,item in ipairs(self.item_list) do
                if item then
                    item:stopAllActions()
                end
            end
            local position = self:convertToNodeSpace(touch:getLocation())
            local size = self:getContentSize()
            local rect = cc.rect(0, 0, size.width, size.height)
            if cc.rectContainsPoint(rect,position)then
                return true
            end
        end
        return false
    end


    local function onTouchMoved(touch, event)
        local size = self:getContentSize()
        local xDelta = touch:getDelta().x
        self.last_index = self.index
        self.index = self.index - xDelta / (size.width * (1.0/tableLen(self.item_list))) 
        self:updatePosition()
    end

    local function onTouchEnded(touch, event)
        local  xDelta = touch:getLocation().x - touch:getStartLocation().x
        self:rectify(xDelta > 0)
        local is_open,open_lev= self:checkItem(self.move_index)
        if is_open == false then
            if self.move_index >= (tableLen(self.item_list) - 1) and  self:checkCurMaxIndex() > (tableLen(self.item_list) - 1) then
                message(PartnercallController:getInstance():getString("call_lable_2"))
            else
                local str = string.format(PartnercallController:getInstance():getString("call_lable_3"),open_lev)
                message(str)
            end
            self:setIndex(self.cur_last_index)
            self:updatePositionWithAnimation()
            return
        end
        self:updatePositionWithAnimation()
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
end

--添加菜单项
function CallRotateMenu:addMenuItem(item,index)
    self:addChild(item)
    if not self.item_list then
        self.item_list = {}
    end
    table.insert(self.item_list,item)
    item:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    self:reset()

    if tableLen(self.item_list) >= self.lenght then
        self:updatePositionWithAnimation(index)
    end
end

--更新位置  
function CallRotateMenu:updatePosition()
    local menuSize = self:getContentSize()  
	local  disY = menuSize.height / 8
    local  disX = menuSize.width / 3
    local count = -1
    for i,item in ipairs(self.item_list) do
        count = count + 1
        --local  x = self:calcFunction(count - self.index, menuSize.width * 10 / 24)
        local x = self:calcFunction(count - self.index , menuSize.width * 12 / 24)
        item:setPosition(cc.p(menuSize.width/2 + x , menuSize.height/2)) 
        --设置zOrder,即绘制顺序  
        item:setZOrder(-math.abs((count - self.index) * 100))

        local scale = 1 - math.abs(self:calcFunction(count - self.index, 0.3)) 
        item:setScale(scale) 
        -- local lable_x = item:getContentSize().width * scale / 2
        -- local lable_y = item:getContentSize().height * scale / 2
        -- item.have_label:setPosition(lable_x, lable_y - 100) 
        --设置倾斜，Node没有setCamera函数，将OrbitCamera的运行时间设为0来达到效果  
        -- local  orbit1 = cc.OrbitCamera:create(0, 1, 0, self:calcFunction(i - self.last_index, MENU_ASLOPE), self:calcFunction(i - self.last_index, MENU_ASLOPE) - self:calcFunction(i - self.index, MENU_ASLOPE), 0, 0);  
        -- item:runAction(orbit1);  
    end 
end

--更新位置，有动画  
function CallRotateMenu:updatePositionWithAnimation(index)
    --动画运行时间  
	local  animationDuration=0.3;
    --先停止所有可能存在的动作  
    for i,item in ipairs(self.item_list) do
        item:stopAllActions()
    end
    local menuSize = self:getContentSize()
    local count = -1
    local select_index = index or self.index
    for i,item in ipairs(self.item_list) do
        count = count + 1
        item:setZOrder(-math.abs((count - select_index)*100))  
        local x = self:calcFunction(count - select_index, menuSize.width * 12/24) 
        local  moveTo = cc.MoveTo:create(animationDuration, cc.p(menuSize.width / 2 + x , menuSize.height / 2))
        item:runAction(moveTo)
        item.back_pos = cc.p(menuSize.width / 2 + x, menuSize.height / 2)
        local  scaleTo = cc.ScaleTo:create(animationDuration, (1 - math.abs(self:calcFunction(count - select_index, 0.3)))) 
        item:runAction(scaleTo)
        -- local angleZ  = self:calcFunction(count - self.last_index, MENU_ASLOPE)
        -- local deltaAngleZ = self:calcFunction(count - self.index, MENU_ASLOPE) - self:calcFunction(count - self.last_index, MENU_ASLOPE)
        -- local orbit1 = cc.OrbitCamera:create(animationDuration, 1,0,angleZ,deltaAngleZ,0, 0)
        --item:runAction(orbit1)
    end
    self.index = select_index
    self:actionEndCallBack(select_index) --当前选在index
    self.sum_count = self:findOpenItemSum() --计算列表有多少个开放列表
end

--位置矫正  修改角度 forward为移动方向  当超过1/3，进1  

--true 为正向  false 负  
function CallRotateMenu:rectify(forward)
    local  index = math.floor(self:getIndex())
    self.move_index = index
    if index < 0 then
        index = 0
    elseif index >= tableLen(self.item_list) - 1 then
        index = tableLen(self.item_list) - 1
    end
    if forward == true  then
        index = math.floor(index + 0.2) 
    else  
        index = math.ceil(index + 0.4)
    end
    if index >= self.sum_count then
        index = self.sum_count
    end
   
    self:setIndex(index)
end

--重置  操作有旋转角度设为0  
function CallRotateMenu:reset()
    self.cur_last_index = 0
    self.last_index = 0 
    self.index = 0
    self.move_index = 0
end

function CallRotateMenu:setIndex(index)
    self.last_index = index
    self.index = index
end

function CallRotateMenu:getIndex()
    return self.index
end

function CallRotateMenu:calcFunction(index,width)
    return width * index / (math.abs(index) + 1)
end

function CallRotateMenu:findOpenItemSum()
    if self.item_list then
        local count = -1
        for i,v in ipairs(self.item_list) do
            if v.data.is_open == true then
                count = count + 1
            end
        end
        return count
    end
end

function CallRotateMenu:checkCurMaxIndex()
    if self.item_list then
        local index = 1
        for i,v in ipairs(self.item_list) do
            if v.data.is_open == true then
                index = index + 1
            end
        end
        return index
    end
end

function CallRotateMenu:checkItem(idx)
    if self.item_list then
        local cur_index = idx + 1
        if cur_index > tableLen(self.item_list) and self:checkCurMaxIndex() >= (tableLen(self.item_list) - 1)  then --如果当前索引大于最大值，默认最大值
            cur_index = tableLen(self.item_list)
        else
            if cur_index > self:checkCurMaxIndex() then
                cur_index = self:checkCurMaxIndex()
            end
        end 
        local item = self.item_list[cur_index]
        if item and item.data then
            return  item.data.is_open,item.data.open_lev
        else
        end
    end
end
function CallRotateMenu:setBlack(idx)
    if self.item_list then
        local cur_index = idx + 1
        for i,item in ipairs(self.item_list) do
            if item.data.id == cur_index then
                item:selected(true)
            else
                item:selected(false)
            end
        end
    end
end
--回调函数
function CallRotateMenu:actionEndCallBack(dx)
    local cur_index = dx + 1
    self.cur_last_index = dx
    self:setBlack(dx)
--    PartnercallController:getInstance():getModel():setCurCardIndex(cur_index)
--    GlobalEvent:getInstance():Fire(PartnercallEvent.UPDATE_PARTNER_LIST,cur_index)
end


--主要是播放调用后需要进行的动态效果

function CallRotateMenu:playItemAction(bool)
    if self.item_list then
        local menuSize = self:getContentSize()
        local  animationDuration= 0.1
        local count = 0
        self.is_all_action = false
        if bool == true then
            self.is_not_can_touch = true
            for i, item in ipairs(self.item_list) do
                local moveTo = cc.MoveTo:create(animationDuration, cc.p(menuSize.width / 2, menuSize.height / 2))
                item:runAction(cc.Sequence:create(moveTo,cc.CallFunc:create(function()
                    count = count + 1
                    if count >= tableLen(self.item_list) then
                        GlobalEvent:getInstance():Fire(PartnercallEvent.UPDATE_CARD_ACTION)
                    end
                end)))
            end 
        else
            for i, item in ipairs(self.item_list) do
                local moveTo = cc.MoveTo:create(animationDuration, item.back_pos)
                item:runAction(cc.Sequence:create(moveTo,cc.CallFunc:create(function()
                    count = count + 1
                    if count >= tableLen(self.item_list) then
                        self.is_not_can_touch  = false
                    end
                end))) 
            end 
        end
    end
end

-- 销毁
function CallRotateMenu:DeleteMe()
    --self:cleanItems()
    self:removeAllChildren()
    self:removeFromParent()
end