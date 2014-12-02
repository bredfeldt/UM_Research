clear all;
close all;
clc;

load('OSLD_Accum.mat');

%DIMENSIONAL Organization:
%Patients, Trials, Files, Positions

%File Order:
%IMRT MASK
%IMRT NO MASK
%VMATSS MASK
%VMATSS NO MASK
%VMAT MASK
%VMAT NO MASK

%Every other file is a mask file

%Average across trials for each position, only mask:
mT = squeeze(mean(squeeze(dose(1,:,1:2:end,:)))).*35/100;
sT = squeeze(std(squeeze(dose(1,:,1:2:end,:)))).*35/100;

difIMRT = mT(3,:) - mT(1,:);
errIMRT = sqrt(sT(3,:).^2 + sT(1,:).^2);

difVMATSS = mT(3,:) - mT(2,:);
errVMATSS = sqrt(sT(3,:).^2 + sT(2,:).^2);

figure(1);
plot(difIMRT,'*'); hold all;
plot(errIMRT,'*');
legend('VMAT - IMRT','Error');
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
title('MASK');
ylim([-5 10]);

figure(2);
plot(difVMATSS,'*'); hold all;
plot(errVMATSS,'*');
legend('VMAT - VMATSS','Error');
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
title('MASK');
ylim([0 25]);


%Average across trials for each position, only no mask:
mT = squeeze(mean(squeeze(dose(1,:,2:2:end,:)))).*35/100;
sT = squeeze(std(squeeze(dose(1,:,2:2:end,:)))).*35/100;

difIMRT = mT(3,:) - mT(1,:);
errIMRT = sqrt(sT(3,:).^2 + sT(1,:).^2);

difVMATSS = mT(3,:) - mT(2,:);
errVMATSS = sqrt(sT(3,:).^2 + sT(2,:).^2);

figure(3);
plot(difIMRT,'*'); hold all;
plot(errIMRT,'*');
legend('VMAT - IMRT','Error');
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
title('NO MASK');
ylim([-5 10]);

figure(4);
plot(difVMATSS,'*'); hold all;
plot(errVMATSS,'*');
legend('VMAT - VMATSS','Error');
xlabel('Position');
ylabel('Measured Skin Dose (Gy)');
set(gca,'XTick',1:4,'XTickLabel',['R Inf';'L Inf';'R Sup';'L Sup']);
xlim([0.5 4.5]);
title('NO MASK');
ylim([0 25]);