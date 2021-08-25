function r = AerosolGenRate(Ns,Np,Ra,Ldropl)
    r = zeros(Ns+2*Np,1);
    r(Ns+Np+1:Ns+2*Np,1) = (1-Ldropl).*Ra;
end