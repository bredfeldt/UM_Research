clear all;
close all;

%This script computes the average HU for the bladder structure in a CT
%image set.
%The structure set and the image set must be exported.
%There must be a structure named BLADDER in the structure set.

%to deploy this as an exe
%mcc -m ComputeBladderHU.m -R '-startmsg,"Starting_ComputeBladderHU.exe"'

[file_name, f_path] = uigetfile('*.dcm','MultiSelect','off');
%dcm_id = '15537607';
%ss_fn = 'D:\jbredfel\Temp\Kloos\RS.15537607.dcm';
ss_fn = [f_path file_name];
dcm_temp = strsplit(file_name,'.');
dcm_id = dcm_temp{2};
ss = dicominfo(ss_fn);

ss_names = ss.StructureSetROISequence;
num_structs = length(fieldnames(ss_names));

%find the ID of the BLADDER contour
for i = 1:num_structs
    it_fn = fieldnames(ss_names);
    ss_it = ss_names.(it_fn{i});
    if strcmp(ss_it.ROIName,'BLADDER');
        found = i;
        break;
    else
        found = 0;
    end
end
if found == 0
    disp('Could not find BLADDER');
    return;
end

%get information about image set
images_ss = ss.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence;
images_fn = fieldnames(images_ss);
num_images_ss = length(images_fn);
%create an image set to place bladder mask in
im = zeros();


%get the bladder structure
it_fn = fieldnames(ss.ROIContourSequence);
blad_struct = ss.ROIContourSequence.(it_fn{found});
blad_ss = blad_struct.ContourSequence;
blad_ss_fn = fieldnames(blad_ss);
num_sections_blad = length(blad_ss_fn);

%get position of sections in volume
first_blad = blad_ss.(blad_ss_fn{1}).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
last_blad = blad_ss.(blad_ss_fn{num_sections_blad}).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
first_blad_num = 0;
last_blad_num = 0;
for i = 1:num_images_ss
    im_id = images_ss.(images_fn{i}).ReferencedSOPInstanceUID;
    if strcmp(first_blad,im_id)
        first_blad_num = i;
    end
    if strcmp(last_blad,im_id)
        last_blad_num = i;
    end
end

if first_blad_num > last_blad_num
    blad_list = first_blad_num:-1:last_blad_num-1;
else
    blad_list = first_blad_num:last_blad_num;
end

for i = 1:num_sections_blad
    %open image
    im_fn = ['D:\jbredfel\Temp\Kloos\CT.' dcm_id '.' num2str(blad_list(i)) '.dcm'];
    img_info = dicominfo(im_fn);
    img = dicomread(im_fn);
    %create mask image
    x = blad_ss.(blad_ss_fn{i}).ContourData(1:3:end)/img_info.PixelSpacing(1);
    y = blad_ss.(blad_ss_fn{i}).ContourData(2:3:end)/img_info.PixelSpacing(2);
    x = (x - img_info.ImagePositionPatient(1)/img_info.PixelSpacing(1));
    y = (y - img_info.ImagePositionPatient(2)/img_info.PixelSpacing(2));
    %x = x;
    %y = y;
    %calc average HU in mask region
    w = double(img_info.Width);
    h = double(img_info.Height);
    msk = poly2mask(x,y,w,h);
    blad_pixels = find(msk);
    if length(blad_pixels > 2)
        if i == 1
            mean_blad = mean(img(blad_pixels));
        else
            mean_blad = (mean_blad + mean(img(blad_pixels)))/2;
        end
    end
    
    %figure(1);
    %imagesc(img); hold all;
    %plot(x,y,'r');
    %pause;
end
disp(['Mean bladder HU: ' num2str(mean_blad)]);
%write out data
fid = fopen([f_path 'mean_bladder_HU.txt'],'w+');
fprintf(fid,'Mean\r\n');
fprintf(fid,'%0.3f',mean_blad);
fclose(fid);





