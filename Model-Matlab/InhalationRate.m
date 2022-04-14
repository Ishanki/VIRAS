function r = InhalationRate(V, Ns, Np, Rinh,Vair)
    Rinhmat = zeros(Ns+2*Np,1);
    Rinhmat(end-Np+1:end,1) = Rinh;
    r = Rinhmat*V/Vair;
end