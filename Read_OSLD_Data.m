function [OSLD_Notes, OSLD_Mean, OSLD_Std, OSLD_Dose] = Read_OSLD_Data(fn)

    %This function reads the OSLD spreadsheet format as of 10/23/14
    
    OSLD_Num_Col   = 1;
    OSLD_Mean_Col  = 4;
    OSLD_Std_Col   = 5;    
    OSLD_Dose_Col  = 7;
    OSLD_Notes_Col = 3;
    OSLD_Val_Row =  [1; 4; 7; 10; 13; 16];
    OSLD_Notes_Row = [3; 6; 9; 12; 15; 18];
    
    [num,txt] = xlsread(fn,1,'B15:L33');
    
    %read all OSLD data
    for i = 1:6
        OSLD_Num{i} = txt(OSLD_Val_Row(i), OSLD_Num_Col);
        if isempty(char(OSLD_Num{i}))
            continue;
        end        
        disp(['Importing OSLD#: ' num2str(i)]);
        OSLD_Mean(i) = num(OSLD_Val_Row(i), OSLD_Mean_Col);
        OSLD_Std(i) = num(OSLD_Val_Row(i), OSLD_Std_Col);
        OSLD_Dose(i) = num(OSLD_Val_Row(i), OSLD_Dose_Col);
        OSLD_Notes{i} = txt(OSLD_Notes_Row(i), OSLD_Notes_Col);
    end
    
    
end