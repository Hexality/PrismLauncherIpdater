<h1 align="center">PrismUpdater</h2>
<p align="center">A Windows-only updater for PrismLauncher entirely made using Powershell Winforms.</p>

<p align="center"><img src="https://user-images.githubusercontent.com/17398632/209416690-9f2ec2d0-e894-46ef-b987-4849e186cde0.png"></p>

In case you want to use the updater, just the the updater (exe) by clicking [here](https://github.com/Hexality/PrismLauncherUpdater/releases/latest/download/Updater.exe) and put it inside your launcher folder.
- If you installed the launcher using the installer, the folder can be found at `%localappdata%/PrismLauncher`
- If you use it portably, just put the updater in the folder and run it.
- > it's recommended for you to create a shortcut linking directly to the updater, this way whenever the launcher receives a update, it will show you a window telling you to update.


In case you want to (re)install the launcher, just put the updater inside a empty folder and run it, it will automatically set the folder as your launcher folder and `create shortcuts to the updater on your desktop/start menu`*.
> *Automatic creation of the shortcuts only works with the exe version of the updater.
- > There's no way to disable the shortcut creation on the exe version due to the way I designed the launcher, unless you remove the creation command yourself.

<h2 align="center">Windows may give you false-positives on the exe version due to the fact that its not signed, just ignore those.</h2>
<p>If you're not that confident with the exe version, just use the ps1 version available <a href="https://github.com/Hexality/PrismLauncherUpdater/releases/latest/download/Updater.ps1">[here]</a>.</p>

>> In order to use the ps1 version, create a shortcut to the updater set like this:
>>> Target: `powershell -executionpolicy bypass -c ".(Join-Path ((Get-Location).Path) Updater.ps1)"`
>>> Start in: `"path to the folder containing the ps1"`
>>> Example
>>>> ![image](https://user-images.githubusercontent.com/17398632/209416605-c0d1c645-fa57-4491-bde7-f07cce180113.png)
