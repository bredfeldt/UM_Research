function D = CalcDoseEstF()
% CalcDoseEst.m
%Read the calculated doses out of the dicom dose file exported from
%Ecplise.

%Registration is the trickiest part of this.
%We need to make sure we center each dose estimate on the proper location.


%Export instructions:
%Make a reference point called ORIGIN and put it at the user origin
%File Export, Wizard, Plan
%Include structure set
%Total plan dose
%Absolute values [Gy]
%DICOM Media File Export Filter
%Change the save location for all of the objects
%\\Client\D$\jbredfel\Box Sync\UM Medical Physics\VMAT Surface Dose\20141201_CalcData\Patient1\VMAT\

%Dose grid setup instructions:
%Dose grid can be setup however is necessary

%Use some of the MPPG functions for reading the dicom files
addpath('D:\jbredfel\Github\MPPG');

%Loop through all the plans
topdir = 'D:\jbredfel\Box Sync\UM Medical Physics\VMAT Surface Dose\CalcData\Patient1\';

D = zeros(3,4);

for k = 1:3
    if k == 1
        curdir = [topdir 'IMRT\'];
    elseif k == 2
        curdir = [topdir 'VMATSS\'];
    else
        curdir = [topdir 'VMAT\'];
    end

    calc_dose_path = curdir;
    calc_dose_file = 'RD.$RANDOHNSKIN.Dose_PLAN.dcm';

    DoseData = dicomProcessor(calc_dose_path, calc_dose_file);
    [x, y, z, dose] = dicomDoseTOmat([calc_dose_path calc_dose_file], DoseData.ORIGIN);

    DoseData.STATUS
    DPTS = [-7.87, 0.31, -15.76;... %R1
           4.25, -0.47, -15.76;...  %L2
           -5.32, -0.11, -13.66;...  %R3
           4.04, 0.58, -10.96];     %L4

    for i = 1:4
        D(k,i) = interp3(x,y,z,dose,DPTS(i,1),DPTS(i,2),DPTS(i,3),'cubic');
    end
end
%%

end