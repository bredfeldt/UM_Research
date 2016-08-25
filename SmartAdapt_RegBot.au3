#include <MsgBoxConstants.au3>

;************************************************************
;**********MAKE SURE THESE ARE CORRECT***********************
;Constants to be set for each patient. Make sure these are right!
$ffx = 15;first fraction
$lfx = 35;last fraction
$ctn = 1;how many images precede the planning CT image
Global $skipfx[4] = [19, 24, 29, 34] ;which fractions to skip, can only skip 4
;************************************************************
;************************************************************






;Constants set for all patients, may be screen resolution dependent
;posterior
Global $PstX = 900
Global $PstY = 374
;anterior
Global $AstX = 1470
Global $AstY = 374
;left
Global $LstX = 900
Global $LstY = 906
;right
Global $RstX = 1470
Global $RstY = 906

;****************************************************************
;Main Loop
For $fxn = $ffx To $lfx Step 1
   ;click on image
   MouseClick("left", 879, 176, 2)
   ;wait for image to open
   Sleep(8000)

   If $fxn==$skipfx[0] Or $fxn==$skipfx[1] Or $fxn==$skipfx[2] Or $fxn==$skipfx[3] Then
	  ContinueLoop
   EndIf
   RunReg($fxn,$ctn)

Next
;once all fractions are done, then copy all structures
;slide slider all the way over
MouseClickDrag("left", 760, 130, 0, 130)
MouseClickDrag("left", 500, 130, 0, 130)
MouseClickDrag("left", 250, 130, 0, 130)
CopyStructureSet($ffx,$lfx)



;**************************************
;*Functions*
;**************************************

;************************************
Func RunReg($fxnum,$ctn)

   ;click auto match
   MouseClick("left", 616, 85, 1)
   Sleep(1000)

   ;enter name of registration
   $wndNm = "New Rigid Registration - \\Remote"
   WinActivate($wndNm)
   Send("+{END}")

   ;MouseClick("left", 909, 419, 2)
   $s = StringFormat("CT CBCT FX%d",$fxnum)
   Send($s)
   Sleep(1000)

   ;select CT
   Send("{TAB}")
   Send("{TAB}")
   for $i = 1 to $ctn step 1
	  Send("{DOWN}")
   next

   ;send the enter key
   Send("{Enter}")
   Sleep(1000)

   if WinExists("Operation Failed - \\Remote") Then
	  MsgBox($MB_SYSTEMMODAL, "", "Error, probably need to activate the course.")
	  Exit
   EndIf

   ;wait for CT to load
   Sleep(8000)

   ;move ROI edges
   MoveRoiEdge("A")
   MoveRoiEdge("P")
   MoveRoiEdge("L")
   MoveRoiEdge("R")

   ;check to make sure the ROI edges are where we want them
   if CheckRoiEdge == 1 Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "ROI box wrong.")
	  Return 1
   EndIf

   ;run the rigid registration
   $wndNm = "Auto Matching - \\Remote"
   WinActivate($wndNm)
   Send("{Enter}")
   Sleep(10000)

   ;close the rigid window
   WinActivate($wndNm)
   For $tn = 1 To 11 Step 1
	  Send("{TAB}")
	  Sleep(100)
   Next
   Sleep(1000)
   Send("{Enter}")
   Sleep(2000)

   ;open the deformable window
   MouseClick("left", 685, 85, 1)
   Sleep(2000)

   ;move ROI edges
   MoveRoiEdge("A")
   MoveRoiEdge("P")
   MoveRoiEdge("L")
   MoveRoiEdge("R")

   ;check to make sure the ROI edges are where we want them
   if CheckRoiEdge == 1 Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "ROI box wrong.")
	  Return 1
   EndIf

   ;run the deformables registration
   $wndNm = "Deformable Registration - \\Remote"
   WinActivate($wndNm)
   Send("{Enter}")
   WaitDeformable()

   Sleep(1000)
   ;click save
   MouseClick("left",34,85)
   WaitSave()

EndFunc

;************************************
;Function to find and move the ROI edge
Func MoveRoiEdge($s)
   If StringCompare("P",$s)==0 Then
	  ;posterior
	  $stX = $PstX
	  $stY = $PstY
	  $step = 1
   EndIf

   If StringCompare("A",$s)==0 Then
	  ;anterior
	  $stX = $AstX
	  $stY = $AstY
	  $step = -1
   EndIf
   If StringCompare("R",$s)==0 Then
	  ;left
	  $stX = $LstX
	  $stY = $LstY
	  $step = 1
   EndIf
   If StringCompare("L",$s)==0 Then
	  ;right
	  $stX = $RstX
	  $stY = $RstY
	  $step = -1
   EndIf

   ;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $stX)
   ;MouseMove($stX,$stY)

   ;find the red box
   $offset = 0
   For $i = 1 To 500 Step 1
	  $offset = $offset + $step
	  $iColor1 = PixelGetColor($offset + $stX, $stY-1)
	  $iColor2 = PixelGetColor($offset + $stX, $stY)
	  $iColor3 = PixelGetColor($offset + $stX, $stY+1)
	  If $iColor1==16711680 or $iColor2==16711680 Or $iColor3==16711680 Then
		 ;make sure 9 pixels over there's another red pixel
		 $iColor1 = PixelGetColor(9*$step + $offset + $stX, $stY-1)
		 $iColor2 = PixelGetColor(9*$step + $offset + $stX, $stY)
		 $iColor3 = PixelGetColor(9*$step + $offset + $stX, $stY+1)
		 If $iColor1==16711680 Or $iColor2==16711680 Or $iColor3==16711680 Then
			;we found the box!
			MouseMove(3*$step + $offset + $stX, $stY)
			;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
			ExitLoop
		 EndIf
	  EndIf
	  ;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
   Next
   Sleep(100)
   MouseDown("left")
   MouseMove($stX, $stY)
   MouseUp("left")
   ;MouseClickDrag("left", 1113, 904, 920, 904)

EndFunc

;************************************
func CheckROIEdge()
;~    ;check to make sure the edges of the ROI boxes ended up where we expect
;~    $iColorA = PixelGetColor($AstX, $AstY+100)
;~    $iColorP = PixelGetColor($PstX, $PstY+100)
;~    $iColorR = PixelGetColor($RstX, $RstY+100)
;~    $iColorL = PixelGetColor($LstX, $LstY+100)
;~    if $iColorA==16711680 And $iColorP==16711680 And $iColorR==16711680 And $iColorL==16711680 Then
;~ 	  Return 0
;~    Else
;~ 	  Return 1
;~    EndIf

   $aCoord = PixelSearch($AstX-10,$AstY+100,$AstX+10,$AstY+101,0xFF0000)
   if @error Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "Missing1!")
	  Return 1
   EndIf

   $aCoord = PixelSearch($PstX-10,$PstY+100,$PstX+10,$PstY+101,0xFF0000)
   if @error Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "Missing2!")
	  Return 1
   EndIf

   $aCoord = PixelSearch($RstX-10,$RstY+100,$RstX+10,$RstY+101,0xFF0000)
   if @error Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "Missing3!")
	  Return 1
   EndIf

   $aCoord = PixelSearch($LstX-10,$LstY+100,$LstX+10,$LstY+101,0xFF0000)
   if @error Then
	  ;MsgBox($MB_SYSTEMMODAL, "", "Missing4!")
	  Return 1
   EndIf

EndFunc

;************************************
Func CopyStructureSet($ffx,$lfx)
   ;******
   $ypx_per_fx = 16 ;change in y position per fraction
   $ypx_st_fx = 250 ;starting y position for fraction 1
   $xpx = 420 ;xposition we want to click on

   for $fxn = $ffx to $lfx step 1

	  ;calculate the yposition of the current squiggly line
	  $ypx_cur_fx = $ypx_st_fx + ($fxn-1)*$ypx_per_fx

	  ;double click the squiggly line
	  MouseClick("left", $xpx, $ypx_cur_fx, 2)
	  Sleep(2000)

	  ;wait a while for the image to open, maybe could check for a pixel color change (the pixel in the middle of the X:...)
	  $to = 0
	  for $i = 1 to 30 step 1
		 ;check if pixel is red
		 $iColor = PixelGetColor(986, 599)
		 if $iColor == 16646144 Then
			;MsgBox($MB_SYSTEMMODAL, "", "Image open.")
			ExitLoop
		 EndIf
		 ;wait 1 second per loop
		 Sleep(1000)
		 $to = $to+1
	  Next

	  ;if previous loop timed out, then something is wrong, stop and alert user
	  if $to == 30 Then
		 MsgBox($MB_SYSTEMMODAL, "", "Image did not open in time. Quiting script.")
		 ExitLoop
	  EndIf

	  ;check to make sure a deformable alignment has been selected
	  $aCoord = PixelSearch(180,158,186,164,0x393939,10)
	  if @error Then
		 MsgBox($MB_SYSTEMMODAL, "", "Deformable alignment not selected. Check to make sure no inconsistensies in alignment list.")
		 Return 1
	  EndIf

	  ;mouse over ct image box
	  MouseMove(145, 200)
	  Sleep(1000)

	  ;right click on structure set
	  MouseClick("right", 150, 260, 1)
	  Sleep(500)

	  ;left click on "copy structure to registered image"
	  MouseClick("left", 280, 475, 1)
	  Sleep(1000)

	  ;check if the window pops up that indicates the structure set has already been copied
	  ;if it's already been copied then click cancel and go to next registration
	  if WinExists("Create Structure - \\Remote") Then
		 ;press enter to cancel window
		 Send("{ENTER}")
		 Sleep(1000)
		 ;skip to next fraction
		 ContinueLoop
	  EndIf
	  Sleep(2000)


	  ;if it has not been copied, then wait for the copy window to close
	  for $i = 1 to 30 step 1
		 Sleep(1000)
		 ;check if propagate structures window is gone
		 if WinExists("Propagate Structures - \\Remote")==0 Then
			;once it's gone, then exit this loop and start next fraction
			ExitLoop
		 EndIf
	  Next

	  ;error check here if previous loop timed out, then something's wrong, likely course is complete

	  ;click save
	  MouseClick("left",34,85)
	  WaitSave()

   Next
EndFunc


;************************************
Func WaitDeformable()
for $i = 1 to 300 step 1
   ;wait for 1 second
   Sleep(1000)
   ;if window disappears, then quit waiting
   if WinExists("Deformable Registration - \\Remote")==0 Then
	  ExitLoop
   EndIf
Next
EndFunc

;************************************
Func WaitSave()
   for $i = 1 to 60 step 1
	  Sleep(1000)
	  ;check if propagate structures window is gone
	  if WinExists("Saving to database - \\Remote")==0 Then
		 ;once it's gone, then exit this loop and start next fraction
		 ExitLoop
	  EndIf
   Next
EndFunc
