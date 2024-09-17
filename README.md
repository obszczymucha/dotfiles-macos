# MacOS dotfiles


## Setting keybindings for System Settings

1. Backup.
```bash
cp ~/Library/Preferences/com.apple.systempreferences.plist ~/Library/Preferences/com.apple.systempreferences.plist.backup
```

2. Convert to XML.
```bash
plutil -convert xml1 ~/Library/Preferences/com.apple.systempreferences.plist
```

3. Edit the file.
Example:  
```xml
<key>NSUserKeyEquivalents</key>
<dict>
  <key>Hide System Settings</key>
  <string>~^$\\Uf70b</string>
  <key>Quit System Settings</key>
  <string>@$c</string>
</dict>
```

4. Convert to binary.
```bash
plutil -convert binary1 ~/Library/Preferences/com.apple.systempreferences.plist
```

5. Restart the app.
```bash
killall "System Settings"
```
6. Open System Settings and verify the new keyindings are there.


## Reading All Applications keybindings

```bash
defaults read -g NSUserKeyEquivalents
```


## Reading specific app keyindings

```bash
defaults read -app "Microsoft Outlook" NSUserKeyEquivalents
```


## Missing keybindings

**Finder** is a system app and stores the settings somewhere else.
Tried `com.apple.finder.plist`, but no joy. Had to add manually.

