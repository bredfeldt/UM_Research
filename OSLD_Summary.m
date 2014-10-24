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
    %name_list{j} = strrep(name,'_','\_');
    name = strrep(name,'_MASK',' Meas');
    name = strrep(name,'_NOMASK',' Meas');
    name_list{j} = name;
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
        plot(dose*35/100,'*');
        hold all;
    else
        figure(2);
        plot(dose*35/100,'*');
        hold all;
    end
    j = j+1;
end

%%
%Get estimated dose data from spreadsheet
calc_fn = 'D:\jbredfel\Box Sync\UM Medical Physics\VMAT Surface Dose\20141022\EclipseEstimates\Eclipse Calced Dose.xlsx';
T = readtable(calc_fn);
dose_VMAT = table2array(T(1,2:end))';
dose_VMATSS = table2array(T(2,2:end))';
dose_IMRT = table2array(T(3,2:end))';

figure(1);
oco=get(gca,'ColorOrder');
nco = circshift(oco,3);
set(gca,'ColorOrder',nco);
plot([dose_IMRT, dose_VMATSS, dose_VMAT],'o');

figure(2);
oco=get(gca,'ColorOrder');
nco = circshift(oco,3);
set(gca,'ColorOrder',nco);
plot([dose_IMRT, dose_VMATSS, dose_VMAT],'o');

%%
figure(1);
legend([name_list(1:2:end), 'IMRT Calc', 'VMATSS Calc', 'VMAT Calc']);
title('MASK');
ylim([15 65]);
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
set(gcf,'Position',[680 580 560 500]);
figure(2);
legend([name_list(2:2:end), 'IMRT Calc', 'VMATSS Calc', 'VMAT Calc']);
title('NO MASK');
ylim([15 65]);
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
set(gcf,'Position',[680 580 560 500]);