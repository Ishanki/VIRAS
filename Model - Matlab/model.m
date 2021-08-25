function [dVdt] = model(t,V0,NoInd,psi,I,Rcontto,Rcontfrom,Rinact,Rclean,Raerogen,Rsmall,Rlarge,Rref,Rinh)
    % Initial values
    V0air = V0(size(I(t),1)+1,1);
    V0    = V0(1:size(I(t),1));

    % Model - surfaces,hands,mucosas
    dVshmdt_plus = Rcontto(V0,I(t)) + Rsmall(V0air) + Rlarge(I(t).*Raerogen);
    dVshmdt_minus = Rcontfrom(V0,I(t)) + Raerogen + Rinact(1:end-1).*V0 + Rclean(t,V0);
    dVshmdt = (dVshmdt_plus - dVshmdt_minus).*I(t).*(1-psi);
    
    % Model - air
    dVairdt_plus = ones(size(V0))'*(I(t).*Raerogen);
    dVairdt_minus = ones(size(V0))'*Rsmall(V0air) + Rref(V0air) + Rinact(end).*V0air;
    dVairdt = dVairdt_plus - dVairdt_minus;
    
    % Model - accumulated mechanisms
    dVshmdt_fomites_plus  = Rcontto(V0,I(t)).*I(t).*(1-psi);
    dVshmdt_closecon_plus = (Rlarge(I(t).*Raerogen)).*I(t).*(1-psi);
    dVshmdt_aerosol_plus  = (Rinh(V0air) + Rsmall(V0air)).*I(t).*(1-psi);

    % Model - infection risk
    dVshmdt_acc = dVshmdt_fomites_plus + dVshmdt_closecon_plus + dVshmdt_aerosol_plus; %viral exposure
    
    % Output vector
    dVdt = [dVshmdt;dVairdt;dVshmdt_fomites_plus(end-NoInd+1:end,1);dVshmdt_closecon_plus(end-NoInd+1:end,1);dVshmdt_aerosol_plus(end-NoInd+1:end,1);dVshmdt_acc(end-NoInd+1:end,1)];
end