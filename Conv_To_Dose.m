function D = Conv_To_Dose(rdg,rate)

    if rate == 0 %low dose rate
        P1 = 0;
        P2 = 0.00009943;
        P3 = -0.02665;
    else %high dose rate
        P1 = -0.0000000005499;
        P2 = 0.001567;
        P3 = -0.503;
    end
    
    D = P1.*rdg.^2 + P2.*rdg + P3;
end