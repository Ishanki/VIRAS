function [T,Y,p,runtime] = InfectionRisk_main(varargin)
    if exist('varargin','var')
        if size(char(varargin))>0
          dir=char(varargin(1));
          runsimch=char(varargin(2));
        else
          dir='';
          runsimch=0;
        end
    end

    %% Initialise
    disp('Estimation of Infection Risk')
    runsim = 'Y';
    simcount = 0;
    runtime = [];
    while strcmp(runsim,'Y') || strcmp(runsim,'y')
        %% New simulation setup
        T = [];
        Y = [];
        pI= [];
        p = [];
        simcount = simcount+1;
        runtime = [runtime,zeros(4,1)];
        
        % Load spreadsheet'
        disp('Reading inputs');
        if ~exist(dir)
          dir =input('Filepath of input spreadsheet (press nothing for current directory, follow a folder name with /): ','s');
        end
        dir = [dir,''];
        infilename = [dir,'Inputs.xlsx'];
        disp(['Reading inputs from ',infilename]);
        tic;
        [D1,D2,D3,D4,D5,D6,D7,D8,~,err] = readinputs(infilename,0);
        if err == 2
           disp('Inputs loaded') 
        else
           disp('Error: inputs not found')
           break
        end
        
        % Assign model parameters
        p = modelinputs(D1,D2,D3,D4,D5,D6,D7,D8);
        if size(p.fobj) ~= [p.NoObj,p.NoInd]
            disp('Error in Contacts size')
            break
        end
        if size(p.CloseTime) ~= [p.NoObj+2*p.NoInd,p.NoInd]
            disp('Error in CloseTime size')
            break
        end
        if size(p.CloseTransfer) ~= [p.NoObj+2*p.NoInd,p.NoInd]
            disp('Error in CloseTransfer size')
            break
        end
        
        % Define initial conditions
        p = initcond(p);
        % Optional computation of lumped parameters
%         p = testlumped(p);
        runtime(1,simcount) = toc;
        %% Execute simulations
        disp('Running simulations. Please wait...')
        [T,Y] = simulation(p);
        disp('Simulations finished');
        runtime(2,simcount) = toc;
        %% Save outputs
        saveoutputs(T,Y,p,dir);
        disp(['Results saved in ',dir]);
        runtime(3,simcount) = toc;
        %% Plot figures
        if p.FigPop==1
          simplot(T,Y,p,dir);
        end
        runtime(4,simcount) = toc;
        %% Exit simulations
        disp(['Elapsed time: ',num2str(runtime(4,simcount)),'s']);
        if runsimch==0
          runsim = input('Run next simulation? [Y/N]:','s');
        else
          runsim=varargin(2);
        end
        if strcmp(runsim,'Y') || strcmp(runsim,'y')
          disp('Results in the same directory will be overwritten')
        else
          runsim = 'N';
        end
    end
    disp('Application exited');
end
