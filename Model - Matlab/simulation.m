function [T,Y] = simulation(p)
    
    % Indicator showing the presence of objects and individuals in the setting
    Ind = @(t) Presence(t, p.NoObj, p.tin, p.tdur, p.epsilon);
    
    % Indicator for mucous membranes of infected individuals
    psi = [zeros(p.NoObj+p.NoInd,1);p.Inf];
    
    % Transfer rate to a surface via contact route
    Rcontto = @(V,Ind) p.FomitPath.*ContactToRate(V,Ind,p.NoObj,p.NoInd,p.Aobj,p.Ah,p.Am,p.Acon,p.Amh,p.Rhs,p.Rsh,p.Rhm,p.Rmh,p.fobj,p.fmh);

    % Transfer rate from a surface via contact route
    Rcontfrom = @(V,Ind) p.FomitPath.*ContactFromRate(V,Ind,p.NoObj,p.NoInd,p.Aobj,p.Ah,p.Am,p.Acon,p.Amh,p.Rhs,p.Rsh,p.Rhm,p.Rmh,p.fobj,p.fmh);
    
    % Rate of aerosol generation in the form of small droplets
    Raerosol = p.AerosPath.*AerosolGenRate(p.NoObj, p.NoInd, p.Rshed, p.Ldropl);
    
    % Rate of inhalation of small droplets
    Rinh = @(V) p.AerosPath.*InhalationRate(V,p.NoObj,p.NoInd,p.Rinh,p.Vair);
    
    % Deposition rate for small droplets
    Rsmall = @(V) p.AerosPath.*SmallDropletsRate(V, [p.Rdep;p.Rdeph;p.Rdepm], [p.Aobj;p.Ah;p.Am], p.Vair);
    
    % Deposition rate for large droplets
    Rlarge = @(V) p.ClosePath.*LargeDropletsRate(V, p.NoObj, p.NoInd, p.CloseTransfer, p.CloseTime, p.Ldropl);
    
    % Rate of ventilation
    Rref = @(V) AirRefreshRate(V, p.Rref, p.Vair);
    
    % Natural inactivation rate
    Rinact = p.InactPath.*log(2)*1./[p.taus; p.tauh; p.taum; p.taua];

    % Artificial cleaning
    Rclean = @(t,V) CleanRate(t, V, p.NoObj, p.NoInd, p.tsim, p.Tc, p.Tch, p.LRV, p.LRVh, p.Ceff, p.Ceffh, p.epsilon);
    
    %% Solving the ODE system
    opts = odeset('MaxStep', p.epsilon/4);

    [T,Y] = ode15s(@(t,V) model(t,V,p.NoInd,psi,Ind,Rcontto,Rcontfrom,Rinact,Rclean,Raerosol,Rsmall,Rlarge,Rref,Rinh), [p.tini p.tini+p.tsim], p.V0', opts);
    
    % Risk estimation
    pI = risk(Y(:,p.NoObj+2*p.NoInd+1+3*p.NoInd+1:p.NoObj+1+6*p.NoInd),p.k);

    Y = [Y,pI];

end