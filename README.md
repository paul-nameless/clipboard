#  Clipboard

Clipboard manager for macOS. It saves clipboard history and when you need to paste element which you copied long time ago, just press Commnad+Shift+V to active window and select element in history or multiple of them and paste by just pressing Return. 

## Install

Just go to releases tab (https://github.com/paul-nameless/clipboard/releases) and download latest build or build it yourself in xcode, it is very easy.

## Shortcuts

Here are usefull shortcuts to know: 

* Command+Shift+V - show/hide clipboard history window
* Return - paste selected test in the row. If multiple rows selected will paste them separated with one space " "
* Option+Return - if multiple rows selected will join them and paste separated with no space
* Cmd+Return - if multiple rows selected will join them and paste separated with new line character "\n"
* Delete - delete selected text. If multiple selected will delete them all
* Option + arrow down - go to the last row
* Option + arrow up - go to the first row

## Build

You need to install Xcode firstly.

```
git clone https://github.com/paul-nameless/clipboard.git
cd clipboard
xcodebuild -project ClipHistory.xcodeproj -alltargets -configuration Release
```
