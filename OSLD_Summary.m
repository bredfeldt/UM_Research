clear all;
close all;
clc;

dir1 = 'D:\jbredfel\Box Sync\UM Medical Physics\VMAT Surface Dose\20141022\';

%Read the Excel files
list1 = dir(dir1);
j = 1;
for i = 3:length(list1)
    
    fns = list1(i).name;
    fn = fullfile(dir1,fns); 
    [~,name,ext] = fileparts(fn);
    name_list{j} = strrep(name,'_','\_');
    if exist(fn) == 7
        continue; %listing is a folder
    end
    %check if the file is an xls file
    [status,sheets,xlFormat] = xlsfinfo(fn);
    if isempty(regexp(status,'Microsoft Excel Spreadsheet'))
        continue; %listing isn't an excel spreadsheet
    end
    
    disp(['Reading file: ' fn]);
    [notes, mean, std, dose] = Read_OSLD_Data(fn);
    
    if mod(j,2) == 1
        figure(1);
        plot(dose,'*');
        hold all;
    else
        figure(2);
        plot(dose,'*');
        hold all;
    end
    j = j+1;
end
figure(1);
legend(name_list(1:2:end));
title('MASK');
ylim([70 150]);
xlabel('Position');
ylabel('Measured Skin Dose (cGy)');
figure(2);
legend(name_list(2:2:end));
title('NO MASK');
ylim([70 150]);
xlabel('Position');
ylabel('Measured Skin Dose (cGy)');