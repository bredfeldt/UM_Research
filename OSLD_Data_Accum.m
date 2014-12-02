clear all;
close all;
clc;

dir1 = 'D:\jbredfel\Box Sync\UM Medical Physics\VMAT Surface Dose\MeasData\';

listA = dir(dir1);
numPat = length(listA)-2;
for k = 1:numPat
    %Patient folder
    tempDir = ['Patient' num2str(k) '\'];
    dir2 = [dir1 tempDir];    
    listB = dir(dir2);
    numTri = length(listB)-2;
    for j = 1:numTri
        %Trials folder
        dir3 = [dir2 'Trial' num2str(j) '\'];
        listC = dir(dir3);
        numFil = length(listC)-2;        
        if j == 1 && k == 1
            dose = zeros(numPat,numTri,numFil,4);
            file_name = cell(numPat,numTri,numFil);          
        end
        for i = 1:numFil
            %Data folder
            fns = listC(i+2).name;
            fn = fullfile(dir3,fns);
            [~,sname,ext] = fileparts(fn);
            disp(['Reading file: ' fn]);
            [notes, mean, std, dose(k,j,i,:)] = Read_OSLD_Data(fn);
            file_name{k,j,i} = sname;
        end
    end    
end
save('OSLD_Accum.mat','dose','file_name');
