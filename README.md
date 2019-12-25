# msbgen
Mania storyboard generator  

This is not a cheat program. It just reads some text files and creates others without changing anything in the game code or game files. But this program can be used to violate the rules of the game. Please do not use it to play ranked or loved beatmaps.  
I created this program to show that cheating in the game can go unnoticed. This program is not perfect and has several disadvantages, but it is easy to modify.  
Please do not pay attention to the quality of the code, this is just a prototype that I am not going to modify.  
Forgive me for posting this publicly.  

How to use:  

1. creating storyboard for a mania map  
* edit beatmap.lua  
* write:  
```
beatmap = "path/to/map.osu"
```
* copy _storyboard folder to beatmap's folder  
* run start.bat  

2. creating storyboard for a taiko map  
2.1. using only a map  
* same as mania  
* sometimes work incorrectly  
2.2. using replay (autoplay or player doesn't matter)  
* same as mania but add this to beatmap.lua:  
```
replay = "path/to/replay.osr"
```

3. creating storyboard for a std map converted to mania  
* same as taiko 2.2.  

4. editing skin or taiko layout  
* edit main.lua  
* lookup for:  
```
presetName = "2"
keys = true
taikoLayout = "kDKd"
```
* edit these lines to:  
* * change a skin  
* * draw keys  
* * change taiko layout - KD is major keys, kd is minor, e.g. "kdDK", "KdDk", "dDKk"  
* you can create your own skin and add it to presets folder  

