package.path = package.path .. ";./?/init.lua;./?/?.lua;./?.lua"

require("tweaks")
json = require("json")
require("Preset")
require("NoteChart")
require("Storyboard")
require("TaikoManiaProcessor")

require("Replay")

rate = 1

presetName = "2"
keys = true
taikoLayout = "kDKd"
-- taikoLayout = "DdkK"

alternationMaxDelta = 60000/157/2 * rate
maniaHoldDelta = 100

require("beatmap")

storyboard = beatmap:gsub("%s*%[.+%]%s*.osu", ".osb")

tmp = TaikoManiaProcessor:new()
tmp.doubles = true
tmp.layout = taikoLayout
tmp.alternationMaxDelta = alternationMaxDelta

if replay then
	nc = Replay:new()
	nc.layout = taikoLayout
	nc.maniaHoldDelta = maniaHoldDelta
	nc:parse(replay)
else
	nc = NoteChart:new()
	nc:parse(beatmap)
end

sb = Storyboard:new()

jsonExport = {}
require("sprites")
for _, note in ipairs(nc.noteData) do
	insertNote(note, note.columnIndex, nc.columnCount)
	table.insert(jsonExport, {note.startTime, note.columnIndex})
end
if keys then
	insertKeys(nc.columnCount)
end
io.open("result.json", "w"):write(json.encode(jsonExport))

sb:export(storyboard)

print("complete")
love.event.quit()