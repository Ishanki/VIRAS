close all
clear all

%% Load the Input file. Change the path to either './Short_contact_2pers/' or './Long_contact_2pers/'
% APath = './Case_Study-Par_sweeps/Short_contact_2pers/';
APath = './Case_Study-Par_sweeps/Long_contact_2pers/';
p = LoadParams(APath);

%% Run the simulations

%% 1. The parametric sweep over the number of cleaning/hand washing events
% and ___person-to-person___ close contact duration. This mimics different
% levels of social distancing WITHOUT altering the amount of large droplets
% landing on fomites
NCleanMax = 8; % max number of cleaning/hand washing evends
NCleans = 0:NCleanMax; % array of different numbers of cleaning events

% Save a copy of the p.CloseTime matrix from Input.xlsx
CloseTime = p.CloseTime;

% create a mask for CloseTime between individuals
if contains(APath,'Short') % for Short_contact
    mask = zeros(8, 2);
    mask(5:8, :) = [0 1; 1 0; 0 1; 1 0];
    CloseContMax = p.CloseTime(5,2); % CloseTime will range from 0 to the value in the Excel spreadsheet
end
if contains(APath,'Long') % for Long_contact
    mask = zeros(7, 2);
    mask(4:7, :) = [0 1; 1 0; 0 1; 1 0];
    CloseContMax = p.CloseTime(4,2); % CloseTime will range from 0 to the value in the Excel spreadsheet
end
mask = logical(mask);

NCloseCont = 20; % number of points in CloseCont
CloseCont = linspace(0,1,NCloseCont+1); % this is the fraction of the max. close proximity time

offset = p.NoObj+2*p.NoInd+2;
vExpTot = zeros(NCleanMax+1, NCloseCont+1); % array for the total exposure. Tthe first index is y, second is x

tic
for m = 1:NCloseCont+1 % loop through the values of CloseTime
    p.CloseTime(mask) = CloseCont(m)*CloseTime(mask); % Set CloseTime for individuals - scale the relevant CloseTime matrix values
    for k = NCleans %loop through the different numbers of cleaning events
        if k == 0
            p.Tc = [];
            p.Tch = [];
        else
            % cleaning schedule at regular intervals between t=0 and t=p.tdur(2)
            % which is the duration of stay of the infected individual
            CleanTimes = (1:k)*p.tdur(2)/k; 
            % The document (object 1) is not cleaned while the remaining
            % objects are cleaned simultaneously
            p.Tc = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoObj-1,1)];
            % Hand washing at the same times as cleaning:
            p.Tch = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoInd-1,1)];
        end
        [T,Y] = simulation(p);
        vExpTot(k+1,m) = Y(end,3*p.NoInd+offset);  % total viral exposure of susceptible individual
    end
end
toc

% Plot the results
f1 = figure
fig_pos_X = 0;
fig_pos_Y = 100;
fig_width = 2000;
fig_height = 300;
f1.Position = [fig_pos_X, fig_pos_Y, fig_pos_X+fig_width, fig_pos_Y+fig_height];

ax(1) = subplot(1,3,1);
[X,Y] = meshgrid(CloseContMax*CloseCont,NCleans);
contourf(ax(1),X,Y,vExpTot,10)
colorbar
xlabel('Close contact time fraction')
ylabel('Number of cleaning events')
% exportgraphics(f1,[APath 'Cleaning-CloseTime.TIFF'],'Resolution',300)

%% 2. The parametric sweep over the number of cleaning/hand washing events
% and close contact duration both person-to-person and person-to-fomite (!).
% This mimics the effect of wearing coverinds with different efficacy
% altering the amount of large droplets landing on fomites and the
% susceptible person's mucosa
NCleanMax = 8; % max number of cleaning/hand washing evends
NCleans = 0:NCleanMax; % array of different numbers of cleaning events

% create a mask for CloseTime between individuals and people-and-fomites
if contains(APath,'Short') % for Short_contact
    mask = ones(8, 2); % this ensures that all CloseTime with fomites will be scaled
    mask(5:8, :) = [0 1; 1 0; 0 1; 1 0];
    CloseContMax = p.CloseTime(5,2); % CloseTime will range from 0 to the value in the Excel spreadsheet
end
if contains(APath,'Long') % for Long_contact
    mask = ones(7, 2);
    mask(4:7, :) = [0 1; 1 0; 0 1; 1 0];
    CloseContMax = p.CloseTime(4,2); % CloseTime will range from 0 to the value in the Excel spreadsheet
end
mask = logical(mask);

CloseCont = linspace(0,1,NCloseCont+1); % This is now the fraction of the LD that the infected person emits

offset = p.NoObj+2*p.NoInd+2;
vExpTot = zeros(NCleanMax+1, NCloseCont+1); % array for the total exposure. Tthe first index is y, second is x

tic
for m = 1:NCloseCont+1 % loop through the values of CloseTime
    p.CloseTime(mask) = CloseCont(m)*CloseTime(mask); % Set CloseTime for individuals
    for k = NCleans %loop through the different numbers of cleaning events
        if k == 0
            p.Tc = [];
            p.Tch = [];
        else
            % cleaning schedule at regular intervals between t=0 and t=p.tdur(2)
            % which is the duration of stay of the infected individual
            CleanTimes = (1:k)*p.tdur(2)/k; 
            % The document (object 1) is not cleaned while the remaining
            % objects are cleaned simultaneously
            p.Tc = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoObj-1,1)];
            % Hand washing at the same times as cleaning:
            p.Tch = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoInd-1,1)];
        end
        [T,Y] = simulation(p);
        vExpTot(k+1,m) = Y(end,3*p.NoInd+offset);  % total viral exposure of susceptible individual
    end
end
toc

% Plot the results
ax(2) = subplot(1,3,2);
[X,Y] = meshgrid(1-CloseCont,NCleans); %!!! The expression 1-CloseCont corresponds to the efficacy of a face covering, i.e., 1 means no LD are emitted (CloseCont = 0) while 0 means no LD are stopped
contourf(ax(2),X,Y,vExpTot,10)
colorbar
xlabel('Face covering efficacy')
ylabel('Number of cleaning events')
% exportgraphics(f1,[APath 'Cleaning-CloseTime.TIFF'],'Resolution',300)


%% 3. The parametric sweep over the number of cleaning/hand washing events
% and ventilation in Air Changes per Hour

p = LoadParams(APath); % re-load Inputs.xlsx to refresh parameter values

NCleanMax = 8; % max number of cleaning/hand washing evends
NCleans = 0:NCleanMax; % array of different numbers of cleaning events

NVent = 20; % number of different ventilation rates
Vent = linspace(0,5,NVent+1); % array of ACH values from 0 to 5

offset = p.NoObj+2*p.NoInd+2;
vExpTot2 = zeros(NCleanMax+1, NVent+1); % array for the total exposure. Tthe first index is y, second is x

tic
for m = 1:NVent+1 % loop through the values of ventilation rate
    p.Rref = p.Vair*Vent(m); % Set air refresh rate
    for k = NCleans %loop through the different numbers of cleaning events
        if k == 0
            p.Tc = [];
            p.Tch = [];
        else
            % cleaning schedule at regular intervals between t=0 and t=p.tdur(2)
            % which is the duration of stay of the infected individual
            CleanTimes = (1:k)*p.tdur(2)/k; 
            % The document (object 1) is not cleaned while the remaining
            % objects are cleaned simultaneously
            p.Tc = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoObj-1,1)];
            % Hand washing at the same times as cleaning:
            p.Tch = [zeros(size(CleanTimes)); repmat(CleanTimes,p.NoInd-1,1)];
        end
        [T,Y] = simulation(p);
        vExpTot2(k+1,m) = Y(end,3*p.NoInd+offset);  % total viral exposure of susceptible individual
    end
end
toc

% Plot the results
% f2 = figure
ax(3) = subplot(1,3,3);
[X,Y] = meshgrid(Vent,NCleans);
contourf(ax(3),X,Y,vExpTot2,10)
colorbar
xlabel('Ventilation rate (ACH)')
ylabel('Number of cleaning events')

% Resize the subplots to make them slightly wider
aPos1 = get(ax(1),'Position');
set(ax(1), 'Position', [aPos1(1) aPos1(2) 1.15*aPos1(3)  aPos1(4)]);
aPos2 = get(ax(2),'Position');
set(ax(2), 'Position', [aPos2(1) aPos2(2) 1.15*aPos2(3)  aPos2(4)]);
aPos3 = get(ax(3),'Position');
set(ax(3), 'Position', [aPos3(1) aPos3(2) 1.15*aPos3(3)  aPos3(4)]);

exportgraphics(f1,[APath 'Cleaning-CloseTime-Ventilation.TIFF'],'Resolution',300)


%% Functions

% This was extracted from InfectionRisk_main
function p = LoadParams(ADir)
        % Load spreadsheet'
        disp('Reading inputs');
        if ~exist(ADir)
          ADir =input('Filepath of input spreadsheet (press nothing for current directory, follow a folder name with /): ','s');
        end
        ADir = [ADir,''];
        infilename = [ADir,'Inputs.xlsx'];
        disp(['Reading inputs from ',infilename]);
        [D1,D2,D3,D4,D5,D6,D7,D8,~,err] = readinputs(infilename,0);
        if err == 2
           disp('Inputs loaded') 
        else
           error('Error: inputs not found')
        end
        
        % Assign model parameters
        p = modelinputs(D1,D2,D3,D4,D5,D6,D7,D8);
        if size(p.fobj) ~= [p.NoObj,p.NoInd]
            error('Error in Contacts size')
        end
        if size(p.CloseTime) ~= [p.NoObj+2*p.NoInd,p.NoInd]
            error('Error in CloseTime size')
        end
        if size(p.CloseTransfer) ~= [p.NoObj+2*p.NoInd,p.NoInd]
            error('Error in CloseTransfer size')
        end
        
        % Define initial conditions
        p = initcond(p);
end
