function r = CleanRate(t, V, NoObj, NoInd, tsim, Tc, Tch, LRV, LRVh, Ceff, Ceffh, epsilon)   

    % Disinfection settings
    CT = (tsim+1)+zeros(NoObj+NoInd,max([size(Tc,2),size(Tch,2)]));
    CT(1:NoObj,1:size(Tc,2)) = Tc;
    CT(NoObj+1:NoObj+NoInd,1:size(Tch,2)) = Tch;
    CT(isnan(CT)) = (tsim+1);
    
    % Log reduction values for cleaning/hand washing:
    LRVeff = [Ceff.*LRV;Ceffh.*LRVh];

    % global epsilon
    %r = 2*log(10)*V*delta_triang(t-24/2, epsilon);
    %r(Ns+Np+1:Ns+2*Np) = zeros(Np,1);

    r = zeros(NoObj+2*NoInd,1);
    for k = 1:NoObj+NoInd
        for m = 1:size(CT,2)
            r(k) = r(k) + LRVeff(k)*log(10)*V(k)*delta_triang(t-CT(k,m), epsilon);
        end
    end
        
end