--
-- Author: Your Name
-- Date: 2016- 03- 20 11 :12 :54
--

--[[成就系统里面电视显示的列表项]]
--[[参数 ： 父列表,文字,项宽度]]
local ListViewItem = class("ListViewItem",function(listView,Str,width)
	local item = listView:newItem()
	item:addContent(cc.ui.UILabel.new({
	    font = "fonts/gang.ttf",
	    text = Str,
	    size = 35,
	    color = cc.c3b(0, 240, 122),
	}))
	item:setItemSize(width, 50)
    listView:addItem(item)
    return item
end)

return ListViewItem