' ============================================
' 静心自律 - Windows开机自启动脚本
' 将此文件的快捷方式放入启动文件夹即可
' ============================================
' 
' 手动设置方法：
' 1. Win+R 输入 shell:startup 打开启动文件夹
' 2. 将此脚本的快捷方式复制到该文件夹
' 3. 或者运行 setup_startup.bat 自动配置
'
' 注意：此脚本会静默打开程序页面，不会显示命令行窗口

Set WshShell = CreateObject("WScript.Shell")

' 获取脚本所在目录
scriptPath = WScript.ScriptFullName
scriptDir = Left(scriptPath, InStrRev(scriptPath, "\"))

' 构建HTML文件路径
htmlPath = scriptDir & "index.html"

' 使用默认浏览器打开
WshShell.Run """" & htmlPath & """", 1, False

Set WshShell = Nothing
