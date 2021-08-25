function [Sims,Air,Materials,Objects,People,Contacts,CloseTimeMat,CloseTransferMat,RVARorder,error] = readinputs(infilename,read_RandomVars)
    
    error = exist(infilename,'file');
    if error == 0
        Sims = [];
        Air = [];
        Materials = [];
        Objects = [];
        People = [];
        Contacts = [];
        CloseTimeMat = [];
        CloseTransferMat = [];
        RVARorder = [];
        return
    end
    
    Sims = readtable(infilename,'Sheet', 'Sims','Range','B:B','ReadVariableNames',0);
    Air = readtable(infilename,'Sheet', 'Air','Range','B:B','ReadVariableNames',0);
    Materials    = readtable(infilename,'Sheet', 'Materials','ReadVariableNames',1);
    Objects      = readtable(infilename,'Sheet', 'Objects','ReadVariableNames',1);
    People = readtable(infilename,'Sheet', 'People','ReadVariableNames',1);
    Contacts = readtable(infilename,'Sheet', 'Contacts','ReadVariableNames',1);
    CloseTimeMat = readtable(infilename,'Sheet', 'CloseTime','ReadVariableNames',1);
    CloseTransferMat = readtable(infilename,'Sheet', 'CloseTransfer','ReadVariableNames',1);
    RVARorder = [];
    if read_RandomVars
        RVARorder = readtable(infilename,'Sheet', 'RandomVars','Range','A:A');
    end

end
