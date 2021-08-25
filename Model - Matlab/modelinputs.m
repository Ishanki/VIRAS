function [params] = modelinputs(Sims,Air,Materials,Objects,People,Contacts,CloseTimeMat,CloseTransferMat)
    
    % People
    params.NoInd = size(People,1);
    params.IDInd = table2array(People(:,1));
    params.tin   = table2array(People(:,2));
    params.tdur  = table2array(People(:,3));
    params.LRVh  = table2array(People(:,4));
    params.LRVm  = table2array(People(:,5));
    params.Rhm   = table2array(People(:,6));
    params.Rmh   = table2array(People(:,7));
    params.tauh  = table2array(People(:,8));
    params.taum  = table2array(People(:,9));
    params.Amh   = table2array(People(:,10));
    params.fmh   = table2array(People(:,11));
    params.Ah    = table2array(People(:,12));
    params.Am    = table2array(People(:,13));
    params.k     = table2array(People(:,14));
    params.Rshed = table2array(People(:,15));
    params.Rinh  = table2array(People(:,16))*1e6;
    params.Ldropl= table2array(People(:,17));
    params.Rdeph = table2array(People(:,18));
    params.Rdepm = table2array(People(:,19));
    params.V0m   = table2array(People(:,20));
    params.Inf   = table2array(People(:,21));
    params.Ceffh = table2array(People(:,22));
    params.Tch   = table2array(People(:,23:end));
        
    % Materials
    params.NoMat = size(Materials,1);
    params.mat   = table2array(Materials(:,2));
    params.tau   = table2array(Materials(:,5));
    
    % Objects
    params.NoObj = size(Objects,1);
    params.Obj   = table2array(Objects(:,2));
    params.Aobj  = table2array(Objects(:,3));
    params.Acon  = table2array(Objects(:,4));
%     params.fobj  = table2array(params.Objects(:,5));
    params.ObjMat = zeros(params.NoObj,1);
    for i = 1:params.NoObj
        matsearch = strfind(params.mat,table2array(Objects(i,5)));
        for j=1:size(matsearch,1)
            if matsearch{j,1}==1
                params.ObjMat(i,1) = j;
            end
        end
        params.LRV(i,1)  = table2array(Materials(params.ObjMat(i,1),6));
        params.taus(i,1) = table2array(Materials(params.ObjMat(i,1),5));
        params.Rhs(i,1)  = table2array(Materials(params.ObjMat(i,1),4));
        params.Rsh(i,1)  = table2array(Materials(params.ObjMat(i,1),3));
    end
%     params.Nc   = sum(~isnan(table2array(params.Objects(:,9:end))),2);
    params.V0_obj = table2array(Objects(:,6));
    params.Rdep = table2array(Objects(:,7));
    params.Ceff = table2array(Objects(:,8));
    params.Tc   = table2array(Objects(:,9:end));

    % Air
    params.Vair = table2array(Air(1,1))*1e6;
    params.V0_air = table2array(Air(2,1));
    params.taua = table2array(Air(3,1));
    params.Rref = table2array(Air(4,1))*1e6;
    
    % Contacts
    params.fobj  = table2array(Contacts(:,1:end));
    
    % Close time
    params.CloseTime  = table2array(CloseTimeMat(:,1:end));
    
    % Close transfer rate
    params.CloseTransfer  = table2array(CloseTransferMat(:,1:end));
    
    % Simulations
    params.tini = table2array(Sims(1,1));
    params.tsim = table2array(Sims(2,1));
    params.epsilon = table2array(Sims(3,1));
    params.FigPop = table2array(Sims(4,1));
    params.FomitPath = table2array(Sims(5,1));
    params.AerosPath = table2array(Sims(6,1));
    params.ClosePath = table2array(Sims(7,1));
    params.InactPath = table2array(Sims(8,1));
    

end
