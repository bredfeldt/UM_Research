#include <MsgBoxConstants.au3>
$aCoord = PixelSearch(900-10,374,900+10,375,0xFF0000)
if @error Then
   MsgBox($MB_SYSTEMMODAL, "", "Missing1!")
EndIf
;SetError(0)

$aCoord = PixelSearch(1470-10,374,1470+10,375,0xFF0000)
if @error Then
   MsgBox($MB_SYSTEMMODAL, "", "Missing2!")
EndIf
