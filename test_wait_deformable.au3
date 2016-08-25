;create window name based on fraction number, this is important that the fx number matches the CBCT Number
for $i = 1 to 300 step 1
   ;wait for 1 second
   Sleep(1000)
   ;if window disappears, then quit waiting
   if WinExists("Deformable Registration - \\Remote")==0 Then
	  ExitLoop
   EndIf
Next

MouseClickDrag("left", 760, 130, 0, 130)
MouseClickDrag("left", 500, 130, 0, 130)
MouseClickDrag("left", 250, 130, 0, 130)