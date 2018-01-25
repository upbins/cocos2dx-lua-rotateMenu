# cocos2dx-lua-rotateMenu
基于Cocos2dx+lua实现的伪立体菜单栏

上面代码是基本实现。不同环境可能有不同问题。

调用方法：
    self.call_rotate_menu = CallRotateMenu.new(list)
    self.call_rotate_menu:setAnchorPoint(0.5,0.5)
    self.call_rotate_menu:setPosition(self.size.width/2 + 30,425)
    self.main_panel:add(self.call_rotate_menu)
    