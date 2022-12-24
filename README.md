# This is a Windows-only updater for PrismLauncher made entirely with WinForms and PowerShell.

In case you want to use the updater, just the the updater (exe) by clicking [here](https://github.com/Hexality/PrismLauncherUpdater/releases/latest/download/Updater.exe) and put it inside your launcher folder.
> If you installed the launcher using the installer, the folder can be found at `%localappdata%/PrismLauncher`
> If you use it portably, just put the updater in the folder and run it.
>> It's recommended for you to create a shortcut linking directly to the updater, this way whenever the launcher receives a update, it will show you a window telling you to update.

- In case you want to (re)install the launcher, just put the updater inside a empty folder and run it, it will automatically set the folder as your launcher folder and create shortcuts to the updater on your desktop/start menu.
> There's no way to disable the shortcut creation due to the way I designed the launcher, unless you remove the creation command yourself.

### Windows may give you false-positives on the exe version due to the fact that its not signed, just ignore those.
> If you're not that confident on the exe version, just use the ps1 version available [here](https://github.com/Hexality/PrismLauncherUpdater/releases/latest/download/Updater.ps1).
>> In order to use the ps1 version, create a shortcut to the updater set like this:
>>> Target: `powershell -executionpolicy bypass -c ".(Join-Path ((Get-Location).Path) Updater.ps1)"`
>>> Start in: `"path to the folder containing the ps1"`
>>> Example
>>>> ![image](https://user-images.githubusercontent.com/17398632/209416605-c0d1c645-fa57-4491-bde7-f07cce180113.png)
