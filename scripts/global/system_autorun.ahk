﻿; ==========================================================
; system_autorun.ahk
;
; 文档作者: 烈焰
; 修改时间: 2016-05-05 23:49:59
; 手工添加要随ahk一起启动的程序
; ==========================================================

;***** 执行系统自动启动 *****
system_autorun()


; ----------------------------------------------------------
; 系统自动启动项
; ----------------------------------------------------------
system_autorun()
{
    ; 系统初始化
    Sys.init()
    Config.init()
    ; 用户运行
    用户_autorun()
}

; ----------------------------------------------------------
; 用户_autorun()
; ----------------------------------------------------------
用户_autorun()
{
    if(A_UserName == "uu")
    {
        用户uu_autorun()
    }
    else if(A_UserName == "tom")
    {
        用户tom_autorun()
    }
}

; ----------------------------------------------------------
; 用户uu_autorun()
; ----------------------------------------------------------
用户uu_autorun()
{
    记录并循环备份日志(A_UserName . "开机日志", "开机时间", 5)
    show_msg("欢迎回来, 用户" . A_UserName)
    ; ----------------------------------------------------------
    周末早上自动关机()
    sleep 5000
    ;--- 周六日开机不启动mt4
    if(Sys.week()<6){
        ;--- 开机启动mt4
        批量启动程序([["MT4", "C:\Program Files (x86)\MetaTrader 4 at FOREX.com\terminal.exe"]])
        sleep 5000
        ;--- 将mt4最小化
        WinWait, ahk_class MetaQuotes::MetaTrader::4.00, , 60
        if ErrorLevel
        {
            show_msg("等待MT4打开, 超时")
        }
        else
            WinMinimize, ahk_class MetaQuotes::MetaTrader::4.00
        sleep 5000
        ;--- 清理多余进程
        批量关闭进程(["iexplore.exe"])
        sleep 2000
        ;----------定时重复运行 针对路由重启自动打开ie的问题------------
        SetTimer, 用户uu_定时重复执行程序, 1800000
        return
        用户uu_定时重复执行程序:
            批量关闭进程(["iexplore.exe"])
            记录并循环备份日志(A_UserName . "定时执行任务", "执行时间", 5, false)
        return
    }
    else{
        show_msg("周末假期, 金融市场休市, MT4不需启动!")
    }

    ;----------定时重复运行------------
}

; ----------------------------------------------------------
; 用户tom_autorun()
; ----------------------------------------------------------
用户tom_autorun()
{
    记录并循环备份日志(A_UserName . "开机日志", "开机时间", 5)
    show_msg("欢迎回来, 管理员" . A_UserName)
    ; ----------------------------------------------------------
    ;批量启动程序([["音速启动", "d:\home\lieyan\d - softwares\green_software\音速启动(VStart)V5\VStart.exe"]
;                , ["护眼flux", "C:\Users\tom\AppData\Local\FluxSoftware\Flux\flux.exe", "", [["min", "ahk_class ytWindow"]]]
;                , ["罗技setpoint", "C:\Program Files\Logitech\SetPointP\SetPoint.exe"]
;                , ["蓝灯lantern", "D:\home\lieyan\d - softwares\green_software\网络工具\蓝灯翻墙lantern\lantern.exe", ""
;                    , [["kill", "ahk_class Chrome_WidgetWin_1", "Lantern - 360极速浏览器"]]]])
    批量启动程序(CsvFile.readCsvToList(Config.upath("autorunsFile"), [",", "|||", "||"]))
    ;--- 如果没有打开浏览器, 则将蓝灯打开的浏览器关闭
    ;--- 将mt4最小化
    sleep 5000
    ;--- 周六日开机不启动mt4
    if(Sys.week()<6){
        ;--- 开机启动mt4
        批量启动程序([["MT4", "C:\Program Files (x86)\MetaTrader 4 at FOREX.com\terminal.exe", ""
                        , [["min", "ahk_class MetaQuotes::MetaTrader::4.00"]]]])
    }
    else{
        show_msg("周末假期, 金融市场休市, MT4不需启动!")
    }
    ;----------定时重复自动运行------------
;    #Persistent
;    #SingleInstance off
;    SetTimer, 用户tom_定时重复执行程序, 5000
;    return
;    用户tom_定时重复执行程序:
;        show_msg(Sys.now())
;        记录并循环备份日志(A_UserName . "用户tom_定时重复执行程序", "执行时间", 5)
;    return
    ;----------定时重复自动运行------------
}

; ----------------------------------------------------------
; 周末早上自动关机()
; ----------------------------------------------------------
周末早上自动关机()
{
    FormatTime, _minutes,, m
    FormatTime, _hour,, H
    _week := Sys.week()
    ; 暂时设定>0早上都关机, >5才是除周末都开机
    if((_week > 0) && (_hour>=6 && _hour<=8))
    {
        show_splash("", "周六周日非交易日, 不需要自动启动!")
        记录并循环备份日志(A_UserName . "关机日志", "周末自动关机时间", 5)
        run % "C:\Windows\System32\shutdown.exe /s /t 10"
    }
}












