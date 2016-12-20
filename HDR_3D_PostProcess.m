clear all;
close all;

f_patha = 'T:\Radonc_Shared\shared\Physics\Users\Bredfeldt\QA_RT\BlackCap\';
[file_list, f_path] = uigetfile('*.csv','',f_patha,'MultiSelect','on');

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

%search for matching files
%loop through all the files that were selected
nlist = cell(num_files,3);
for m = 1:num_files
    if num_files > 1
        f_file = file_list{m}; %convert from cell to string
    else
        f_file = file_list;
    end
    [~,fn,ext] = fileparts(f_file); %remove extension from filename
    
    nlist(m,:) = strsplit(fn,'_');
end

for m = 1:num_files
    for n = 1:num_files
        c(m,n) = strcmp(nlist(m,2),nlist(n,2));
    end
end

%for each match, process all files
for m = 1:num_files
    for n = 1:num_files
        if c(m,n) && m>n
            [~,~,xa] = xlsread([f_path file_list{m}]);
            [~,~,xb] = xlsread([f_path file_list{n}]);
            %find first nan
            for i = 1:length(xa)
                if isnan(xa{i,1})
                    break;
                end
            end
            %tandem
            %compare 1D positions
            a = cell2mat(xa(3:i-1,2:4));
            b = cell2mat(xb(3:i-1,2:4));
            d1 = a - b;
            md1t(m,n,:) = mean(d1);
            %compare 3D positions
            d3 = sqrt(d1(:,1).^2 + d1(:,2).^2 + d1(:,3).^2);
            md3t(m,n) = mean(d3);
            
            %ring
            %compare 1D positions
            a = cell2mat(xa(i+3:end,2:4));
            b = cell2mat(xb(i+3:end,2:4));
            d1 = a - b;
            md1r(m,n,:) = mean(d1);
            %compare 3D positions
            d3 = sqrt(d1(:,1).^2 + d1(:,2).^2 + d1(:,3).^2);
            md3r(m,n) = mean(d3);
            
            
        end
    end
end
%%
%plot the results
i1 = 1; i2 = 1; i3 = 1;
for m = 1:num_files
    for n = 1:num_files
        if mod(m,3) == 2 && mod(n,3) == 1 && m>n && m<n+3
            T(1,i1) = md3t(m,n);
            R(1,i1) = md3r(m,n);
            T1(1,i1,:) = md1t(m,n,:);
            R1(1,i1,:) = md1r(m,n,:);
            i1 = i1 + 1;
        end

        if mod(m,3) == 0 && mod(n,3) == 1 && m>n && m<n+3
            T(2,i2) = md3t(m,n);
            R(2,i2) = md3r(m,n);
            T1(2,i2,:) = md1t(m,n,:);
            R1(2,i2,:) = md1r(m,n,:);
            i2 = i2 + 1;
        end              

    end
end

%%
figure(1); clf;
boxplot(T');
ylabel('Average 3D Position Error (mm)');
set(gca,'XTickLabel',{'CT to MR1','CT to MR2'});
title('Tandem');
ylim([0 5]);

figure(2); clf;
boxplot(R');
ylabel('Average 3D Position Error (mm)');
set(gca,'XTickLabel',{'CT to MR1','CT to MR2'});
title('Ring');
ylim([0 5]);

figure(3); clf;
plot(T','*'); 
%ax = gca;
%ax.ColorOrderIndex = 1;
ylabel('Average 3D Position Error (mm)');
title('Tandem: Errors for each model');
legend('CT to MR1','CT to MR2');
set(gca,'XTickLabel',{'30R2T','30R4T','30R6T','45R2T','45R4T','45R6T','60R2T','60R4T','60R6T'});

figure(33);
plot(R','o');
ylabel('Average 3D Position Error (mm)');
title('Ring: Errors for each model');
legend('CT to MR1','CT to MR2');
set(gca,'XTickLabel',{'30R2T','30R4T','30R6T','45R2T','45R4T','45R6T','60R2T','60R4T','60R6T'});
%%
figure(4);
xt = T1(:,:,1); xt = xt(:);
yt = T1(:,:,2); yt = yt(:);
zt = T1(:,:,3); zt = zt(:);
td = [xt,yt,zt];
boxplot(td);
ylim([-3 3]);
ylabel('3D Position Error (mm)');
set(gca,'XTickLabel',{'X','Y','Z'});
title('Tandem: single dimension error distribution');

figure(5);
xr = R1(:,:,1); xr = xr(:);
yr = R1(:,:,2); yr = yr(:);
zr = R1(:,:,3); zr = zr(:);
rd = [xr,yr,zr];
boxplot(rd);
ylim([-3 3]);
ylabel('3D Position Error (mm)');
set(gca,'XTickLabel',{'X','Y','Z'});
title('Ring: single dimension error distribution');
