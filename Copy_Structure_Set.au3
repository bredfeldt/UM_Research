#include <MsgBoxConstants.au3>
;copy structure set onto registered image

$ffx = 15;first fraction
$lfx = 35;last fraction


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
   for $i = 1 to 30 step 1
	  Sleep(1000)
	  ;check if propagate structures window is gone
	  if WinExists("Saving to database - \\Remote")==0 Then
		 ;once it's gone, then exit this loop and start next fraction
		 ExitLoop
	  EndIf
   Next

Next