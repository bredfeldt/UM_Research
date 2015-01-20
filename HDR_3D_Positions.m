clear all;
close all;

% This Matlab script extracts 3D positions of the HDR sources from a 
% dicom plan file. The inputs are a list of user selected dicom plan 
% files. The output is a list of *.csv file listing the source 
% positions for all sources in each plan file.

%to deploy this as an exe
%mcc -m HDR_3D_Positions.m -R '-startmsg,"Starting_HDR_3D_Positions.exe"'

%user input, file must be an HDR plan
%f_path = 'S:\RadOnc\Prisciandaro\Temp\';
%f_file = 'RP.1.2.246.352.71.5.824327626427.244627.20140529135747.dcm';
[file_list, f_path] = uigetfile('*.dcm','MultiSelect','on');


if iscell(file_list)
    mult = 1;
    num_files = length(file_list);
else
    if file_list == 0
        disp('No file was selected.');
        return;
    else
        num_files = 1;
    end
end

%loop through all the files that were selected
for m = 1:num_files
    if num_files > 1
        f_file = file_list{m}; %convert from cell to string
    else
        f_file = file_list;
    end
    [~,fn,ext] = fileparts(f_file); %remove extension from filename

    disp(['Reading ' f_file]);
    dcm_meta = dicominfo([f_path f_file]); %get the dicom meta data

    ch_seq = dcm_meta.ApplicationSetupSequence.Item_1.ChannelSequence; %Copy channel sequence struct
    ch_fn = fieldnames(ch_seq); %channel field names

    fp = fopen([f_path 'Pos3D_' fn '.csv'],'w');
    %loop through channel field names
    for i = 1:length(ch_fn)
        cfn = ch_fn(i); %current field name
        ccs = ch_seq.(cfn{1}); %current channel sequence
        %write the applicator ID
        fprintf(fp,'%s\r\n',ccs.SourceApplicatorID);
        %write out heading for 3D positions
        fprintf(fp,'%s,%s,%s,%s\r\n','Index','X (mm)','Y (mm)','Z (mm)');

        %get the number of control points in the current channel sequence
        cps_fn = fieldnames(ccs.BrachyControlPointSequence);
        idx = 1;
        for k = 1:2:length(cps_fn)
            ccp_fn = cps_fn(k); %current field name
            ccp = ccs.BrachyControlPointSequence.(ccp_fn{1}); %current control point data
            ccp_3D = ccp.ControlPoint3DPosition; %copy the 3D position data
            fprintf(fp,'%i,%04f,%04f,%04f\r\n',idx,ccp_3D(1),ccp_3D(2),ccp_3D(3));
            idx = idx + 1;
        end

        fprintf(fp,'\r\n');
    end
    fclose(fp);
    disp(['Finished file ' num2str(m) ' of ' num2str(num_files)]);
end
pause(1);