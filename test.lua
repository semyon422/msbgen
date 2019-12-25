package.path = package.path .. ";./?/init.lua;./?/?.lua;./?.lua"

require("tweaks")
json = require("json")
require("Preset")
require("NoteChart")
require("Storyboard")
require("TaikoManiaProcessor")
-- beatmap = "D:/games/osu!/Songs/490335 Camellia - PLANET__SHAPER/Camellia - PLANETSHAPER (Fantazy) [Crazy Oni].osu"
-- replay = 


osr = "replays/semyon422 - JOYRYDE - FUEL TANK [taiko test] (2018-10-09) Taiko.osr"
node = "node.exe"
js = [[const osuReplayParser = require('osureplayparser'); const replayPath = '%s'; const replay = osuReplayParser.parseReplay(replayPath); console.log(JSON.stringify(replay));]]
command = "\"\"" .. node .. "\"" .. " -e \"" .. js:format(osr) .. "\"\""
out = io.open("out.json", "w")
out:write(io.popen(command):read("*all"))
out:close()