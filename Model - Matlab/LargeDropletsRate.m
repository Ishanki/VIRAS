function r = LargeDropletsRate(Rexhale, Ns, Np, CloseRate, CloseTime, Ldropl)
    MatExhale = Rexhale(end-Np+1:end,1)./(1-Ldropl); % Rexhale argument refers to small droplets (AerosolGenRate)
    PrcLarge = Ldropl'.*ones(Ns+2*Np,Np);
    r = (PrcLarge.*CloseRate.*CloseTime)*MatExhale;
end