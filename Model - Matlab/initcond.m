function params = initcond(params)

% Initial conditions
V0_obj = params.V0_obj;

% Mucous membrane Version 1
%V0_mucos = 5.*params.k.*params.Inf;

% Mucous membrane Version 2
V0_mucosa = params.V0m.*params.Inf;

% % Hands Version 1
% V0_hands = 961500*params.Inf;

% % Hands Version 2
% V0_hands = zeros(params.NoInd,1);

% Hands Version 3
tofomites = sum(params.Rhs.*params.Acon.*params.fobj,1)'./params.Ah;
fromfomites = sum(params.Rsh.*params.Acon.*params.fobj.*V0_obj./params.Aobj,1)';
tomucosa = params.Rhm.*params.fmh.*params.Amh./params.Ah;
frommucosa = params.Rmh.*params.fmh.*params.Amh.*V0_mucosa./params.Am;
closecon = sum(eye(params.NoInd).*params.CloseTime(params.NoObj+1:params.NoObj+params.NoInd,:).*params.CloseTransfer(params.NoObj+1:params.NoObj+params.NoInd,:).*params.Ldropl.*params.Rshed,2);
aerosol = 0;
inact = log(2)./params.tauh;

% V0_hands = params.Inf.* (1*frommucosa + params.FomitPath*fromfomites + params.ClosePath*closecon + params.AerosPath*aerosol) ...
% ./ (1*tomucosa + params.FomitPath*tofomites + params.InactPath*inact );

% Individuals do not interact with anything apart from their own hands before entering the setting
V0_hands = params.Inf.* (1*frommucosa + params.ClosePath*closecon) ...
			./ (1*tomucosa + params.InactPath*inact );	

% Initial conditions (shm,air,acc_fomites,acc_closecon,acc_aerosol,acc_total,risk)
V0_air = params.V0_air;
params.V0 = [V0_obj;V0_hands;V0_mucosa;V0_air;V0_mucosa;V0_mucosa;V0_mucosa;V0_mucosa]';

end