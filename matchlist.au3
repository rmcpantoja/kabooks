#include <array.au3>
;#include <dataset.au3>
#INCLUDE <FILE.AU3>
_dataset_matchList(@ScriptDir &"\compared_transcripts.txt")
if @error then
msgbox(16, "An error has occurred", "Code: " &@error)
Else
MsgBox(0, "Success", "LJSpeech transcription created!")
EndIf
func _dataset_matchList($sListPath = @ScriptDir &"\list.txt")
;declare:
local $aList, $aSplit, $hFile
if not FileExists($sListPath) then Return SetError(1, 0, "")
;Open list:
$aList = FileReadToArray($sListPath)
if @error then return SetError(2, 0, "")
;Geting number of lines, although it can also be done with uBound.
$iLines = @extended
$hFile = FileOpen(StringTrimRight($sListPath, 4) &"_converted.txt", $FO_APPEND)
If $hFile = -1 Then return SetError(3, 0, "")
for $I = 0 to $iLines -1
;split columns:
$aSplit = StringSplit($aList[$I], "|")
; We only need 1st and 3rd columns, so we do the following:
FileWriteLine($hFile, $aSplit[1] &"|" &$aSplit[3])
Next
FileClose($hFile)
return 1
EndFunc