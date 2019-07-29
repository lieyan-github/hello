; ==========================================================
;
; lib_搜索
;
; 作者: 烈焰
;
; 修改时间: 2018-03-10 05:02:30
;
; ==========================================================

; 清洗搜索关键字, 返回字符串
cleanSearchKey(_searchKey, _RegEx:="[,\n\r]", _replace:=""){
    return RegExReplace(trim(_searchKey, " `t"), _RegEx, _replace)
}

; ----------------------------------------------------------
; [快捷搜索]搜索选中内容_new
; ----------------------------------------------------------
简单搜索(_searchKey, _searcher, _replaceSearchStr:= "%s")
{
    _搜索器:= StrReplace(_searcher["cmd"], _replaceSearchStr, _searchKey)
    run %_搜索器%
}
; ----------------------------------------------------------
; [快捷搜索]搜索选中内容_new
; 参数: _searchKey
; 参数: _searcher  {name:.., cmd:.., tag:[..]}
; 无搜索关键字, 则直接打开everything
; ----------------------------------------------------------
简单搜索_tag_history(_searchKey, _searcherTag, _searcher)
{
    if(_searcherTag=="run"){
        ; 仅仅是打开软件的指令类型, 则只打开软件, 不记入历史记录
        run % _searcher["cmd"]
        return
    }
    搜索关键字           := cleanSearchKey(_searchKey)
    _replaceSearchStr   := "%s"
    ; ---------------------------------
    ; 如果获取的是路径, 则搜文件名
    if(InStr(搜索关键字, "\")>0){
        _tmplist := StrSplit(搜索关键字, "\")
        搜索关键字 := trim(_tmplist.pop(), " `t")
        _tmplist := ""
    }
    ; ---------------------------------
    ; 如果没有指定搜索内容, 则仅仅启动默认搜索器
    if(搜索关键字 == ""){
        show_msg("搜索关键字空白, 无效搜索!")
        return
    }
    ; 执行单次搜索任务
    简单搜索(搜索关键字, _searcher)
    ; 写入搜索历史文件
    ; CsvFile.append(Config.upath("searchHistoryFile"), _searcherTag, 搜索关键字, Sys.now())
    ;--- end
}

; ----------------------------------------------------------
; search_menu
; 主菜单
; ----------------------------------------------------------
search_menu()
{
    _searchKey := trim(Clipboarder.get("copy"), " `t")
    ; ----------------------------------------------------------
    ; 加载数据文件, 生成相应数组
    ; ----------------------------------------------------------
    _searchersJson  := JsonFile.read(Config.path("searchersFile"))
    _searchers      := _searchersJson["searchers"]
    _localSearcher  := _searchersJson["localSearcher"]

    ; ---------------------------------------
    ; 1. 收集所有tags到数组 arrayCollect
    ; ---------------------------------------
    ; 2. 制作关系数组, 标签-搜索器 关系数组
    ;    arrayAssociate
    ; [{"tag": [搜索器]}, {"tag": [搜索器]}]
    ; ---------------------------------------
    _tagToSearchers := arrayAssociate(arrayCollect(_searchers, "tag")
                                    , _searchers
                                    , "tag"
                                    , "_self")
    ; ----------------------------------------------------------
    ; 菜单部分
    ; ----------------------------------------------------------
    Gui +OwnDialogs
    ; [菜单] 提示搜索内容
    Menu, SearchMenu, Add, % "当前搜索关键字: ", lab_SearchMenu_End
    Menu, SearchMenu, disable, % "当前搜索关键字: "
    Menu, SearchMenu, Add
    if(_searchKey == "") {
        Menu, SearchMenu, Add, ***无搜索内容***, lab_SearchMenu_End
        Menu, SearchMenu, disable, ***无搜索内容***
        Menu, SearchMenu, Add
    }
    else {
        Menu, SearchMenu, Add, % strLimitLen(_searchKey, 1, 50, "..."), lab_SearchMenu_End
        Menu, SearchMenu, disable, % strLimitLen(_searchKey, 1, 50, "...")
        Menu, SearchMenu, Add
    }
    ; [菜单] tag分类搜索
    for k,v in _tagToSearchers {
        Menu, SearchMenu
            , Add
            , % "&" . A_Index . ". " . k
            , lab_SearchMenu_tagsMenuSelected
    }
    ; 提示信息
    Menu, SearchMenu, Add, [按住Shift显示序号 | 按住Ctrl显示项目], lab_SearchMenu_End
    Menu, SearchMenu, disable, [按住Shift显示序号 | 按住Ctrl显示项目]
    Menu, SearchMenu, Add
    Menu, SearchMenu, Add, &h. 查看搜索历史, lab_SearchMenu_History
    Menu, SearchMenu, Add
    Menu, SearchMenu, Add, &q. 打开搜索器, lab_SearchMenu_Run
    Menu, SearchMenu, Add
    Menu, SearchMenu, Add, &e. 编辑搜索列表, lab_SearchMenu_Edit
    Menu, SearchMenu, Add

    ; 显示菜单
    Menu, SearchMenu, Show, %A_CaretX%, %A_CaretY%
    ;<……>此时转入选择的标签运行，结束后返回
    Menu, SearchMenu, DeleteAll
    return          ;菜单结束, 不再往下执行

    ; ==========================================================
    ; 菜单执行部分
    ; ==========================================================
    lab_SearchMenu_tagsMenuSelected:
        If GetKeyState("Shift")         ;[按住 Shift 删除选中条目]
        {
            msgbox % A_ThisMenuItemPos
            Return
        }
        If GetKeyState("Ctrl")          ;[按住 Ctrl 自动置顶并粘贴]
        {
            ; 最后使用过的排最前面
            msgbox % A_ThisMenuItem
            Return
        }
        ; 显示选项内容
        _select_tag:= StrSplit(A_ThisMenuItem, ".", " `t")[2]
        ; 执行批量搜索
        ;搜索_tag(_searchKey, _select_tag, _tagToSearchers[_tagIndex][2])
        for _index, _searcher in _tagToSearchers[_select_tag] {
            简单搜索_tag_history(_searchKey, _select_tag, _searcher)
            sleep 200
        }
    return

    lab_SearchMenu_MenuSelected:
        If GetKeyState("Shift")         ;[按住 Shift 删除选中条目]
        {
            msgbox % A_ThisMenuItem
            Return
        }
        If GetKeyState("Ctrl")          ;[按住 Ctrl 自动置顶并粘贴]
        {
            ; 最后使用过的排最前面
            msgbox % A_ThisMenuItemPos
            Return
        }
        ;[普通粘贴]
        write(Clipboarder.item(A_ThisMenuItemPos))
    Return
    ; ----------------------------------------------------------
    lab_SearchMenu_Clipboard:
        write(Clipboard)
    return
    ; ----------------------------------------------------------
    lab_SearchMenu_History:
        run % Config.upath("searchHistoryFile")
    return
    ; ----------------------------------------------------------
    lab_SearchMenu_Run:
        run % _localSearcher["cmd"]
    return
    ; ----------------------------------------------------------
    lab_SearchMenu_Edit:
        run % Config.path("searchersFile")
    return
    ; ----------------------------------------------------------
    lab_SearchMenu_End:
        Gui, Destroy
    return
}
