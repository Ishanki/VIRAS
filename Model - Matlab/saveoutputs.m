function [] = saveoutputs(T,Y,inputs,dir)
    varnames = cell(1,1+inputs.NoObj+2*inputs.NoInd+1+5*inputs.NoInd);
    varnames(1,1:inputs.NoObj+1) = [{'Time'},inputs.Obj'];
    for i = 1:inputs.NoInd
        varnames{1,1+inputs.NoObj+i} = ['Hand_',num2str(i)];
        varnames{1,1+inputs.NoObj+inputs.NoInd+i} = ['Mucosa_',num2str(i)];
        varnames{1,1+inputs.NoObj+2*inputs.NoInd+1+i}=['Viral Exposure_Fomites_',num2str(i)];
        varnames{1,1+inputs.NoObj+2*inputs.NoInd+1+inputs.NoInd+i}=['Viral Exposure_CloseContact_',num2str(i)];
        varnames{1,1+inputs.NoObj+2*inputs.NoInd+1+2*inputs.NoInd+i}=['Viral Exposure_Aerosol_',num2str(i)];
        varnames{1,1+inputs.NoObj+2*inputs.NoInd+1+3*inputs.NoInd+i}=['Viral Exposure_Total_',num2str(i)];
        varnames{1,1+inputs.NoObj+2*inputs.NoInd+1+4*inputs.NoInd+i} = ['Risk_',num2str(i)];
    end
    varnames{1,1+inputs.NoObj+2*inputs.NoInd+1} = 'Air';

    OutTable = array2table([T,Y],'VariableNames',varnames);
    writetable(OutTable, [dir,'Outputs.csv']);
    outputs = [T,Y];
    save([dir,'simulation.mat'], 'outputs','inputs')
end