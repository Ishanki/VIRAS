close all
clear all

%% Load the Input file. Change the path to either './Short_contact_2pers/' or './Long_contact_2pers/'
APath = './Case_Study-Par_sweeps/Short_contact_2pers/';
% APath = './Case_Study-Par_sweeps/Long_contact_2pers/';
p = LoadParams(APath);

%% Run the simulations
NCleanMax = 2; % run two simulations: one without cleaning and another one with one clean

NCleans = 0:NCleanMax;

offset = p.NoObj+2*p.NoInd+2;
% vExp = zeros(NCleanMax+1, 7);

%% Figure preparation

% Get the standard colours by creating a temporary plot and saving the
% colours
f = figure;
h = plot(1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2,1:2);
c = get(h,'Color');
close(f)

% Figure properties
f = figure;

fig_pos_X = 100;
fig_pos_Y = 0;
fig_width = 1250;
fig_height = 1000;
f.Position = [fig_pos_X, fig_pos_Y, fig_pos_X+fig_width, fig_pos_Y+fig_height];

LnWidth = 1.5; % Line width

for k = 1:4
    ax(k) = subplot(2,2,k);
    hold(ax(k),'on');
    grid(ax(k),'on');
    xlabel('Time (h)');
end

% Create another figure for viral concentrations on fomites
f_conc = figure;
ax_c = axes;
hold(ax_c,'on');
grid(ax_c,'on');
xlabel('Time (h)');
ylabel('Viral concentration on objects (copies/cm^2)');


for k = NCleans
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
        
        p.epsilon = min(p.epsilon, CleanTimes(1)/50); % make sure epsilon is not too large for the duration between the events
    end
    [T,Y] = simulation(p);
    
    % Plot the results
    if k == 0
        LnStyle = '-';
    elseif k == 1
        LnStyle = '--';
    else
        LnStyle = '-.';
    end
    % Viral loads on objects
    for i = 1:p.NoObj
        plot(ax(1),T,Y(:,i),'LineStyle', LnStyle, 'Color', c{i}, 'LineWidth', LnWidth);
    end
    xlim(ax(1),[min(T(:)),max(T(:))]); % make sure the time range is tight

    % Plot viral concentrations on fomites
    for i = 1:p.NoObj
        plot(ax_c,T,Y(:,i)/p.Aobj(i),'LineStyle', LnStyle, 'Color', c{i}, 'LineWidth', LnWidth);
    end

    % Plot viral exposure of susceptible individual to the different pathways
    plot(ax(2),T,Y(:,offset),'LineStyle', LnStyle, 'Color', c{1}, 'LineWidth', LnWidth); % fomite path
    plot(ax(2),T,Y(:,p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{2}, 'LineWidth', LnWidth); % close contact path
    plot(ax(2),T,Y(:,2*p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{3}, 'LineWidth', LnWidth); % aerosol
    plot(ax(2),T,Y(:,3*p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{4}, 'LineWidth', LnWidth); % total exposure
    
    % Plot viral load in air
    plot(ax(3),T,Y(:,p.NoObj+2*p.NoInd+1),'LineStyle', LnStyle, 'Color', c{1}, 'LineWidth', LnWidth);

    % Plot relative viral exposure of susceptible individual to the different pathways
    plot(ax(4),T,Y(:,offset)./Y(:,3*p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{1}, 'LineWidth', LnWidth); % fomite path
    plot(ax(4),T,Y(:,p.NoInd+offset)./Y(:,3*p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{2}, 'LineWidth', LnWidth); % close contact path
    plot(ax(4),T,Y(:,2*p.NoInd+offset)./Y(:,3*p.NoInd+offset),'LineStyle', LnStyle, 'Color', c{3}, 'LineWidth', LnWidth); % aerosol

%     vExp(k+1,1) = Y(end,offset);            % viral exposure of susceptible individual to fomites
%     vExp(k+1,2) = Y(end,p.NoInd+offset);    % viral exposure of susceptible individual to close contact
%     vExp(k+1,3) = Y(end,2*p.NoInd+offset);  % viral exposure of susceptible individual to aerosol
%     vExp(k+1,4) = Y(end,3*p.NoInd+offset);  % total viral exposure of susceptible individual
%     vExp(k+1,5) = vExp(k+1,1)/vExp(k+1,4);          % relative exposure to fomites
%     vExp(k+1,6) = vExp(k+1,2)/vExp(k+1,4);          % relative exposure to close contact
%     vExp(k+1,7) = vExp(k+1,3)/vExp(k+1,4);          % relative exposure to aerosol
end

%% Finalise the plots

% Viral concentrations
hold(ax_c,'off');
% set(ax_c,'yscale','log')
% ylim(ax_c,[1,2E4]);

% Subplots of the big plot
for k = 1:4
    hold(ax(k),'off');
end

set(ax(1),'yscale','log')
ylim(ax(1),[1000,5E7]);

ylabel(ax(1),'Viral load on objects');
legend(ax(1),[p.Obj, strcat(p.Obj,' (1 clean)'), strcat(p.Obj,' (2 cleans)')],'Location','northoutside','NumColumns',3);

ylabel(ax(2),'Viral exposure through different pathways');
labels2 = {'Fomites', 'Close contact', 'Aerosol', 'Total'};
legend(ax(2),[labels2, strcat(labels2,' (1 clean)'), strcat(labels2,' (2 cleans)')],'Location','northoutside','NumColumns',3);

ylabel(ax(3),'Viral load in air');
legend(ax(3),{'No cleaning', 'One clean', 'Two cleans'},'Location','northoutside','NumColumns',3);

ylabel(ax(4),'Relative viral exposure through different pathways');
labels4 = {'Fomites', 'Close contact', 'Aerosol'};
legend(ax(4),[labels4, strcat(labels4,' (1 clean)'), strcat(labels4,' (2 cleans)')],'Location','northoutside','NumColumns',3);

% make sure all the subplots have the same dimensions
aPos1 = get(ax(1),'Position');
set(ax(1), 'Position', [aPos1(1:3)  0.9*aPos1(4)]);
aPosTmp = get(ax(2),'Position');
set(ax(2), 'Position', [aPosTmp(1:3)  0.9*aPos1(4)]);
aPosTmp = get(ax(3),'Position');
set(ax(3), 'Position', [aPosTmp(1:3)  0.9*aPos1(4)]);
aPosTmp = get(ax(4),'Position');
set(ax(4), 'Position', [aPosTmp(1:3)  0.9*aPos1(4)]);
% resize the figure itself


if contains(APath,'Short') % for Short_contact
    exportgraphics(f,[APath 'Short_contact.TIFF'],'Resolution',300)
    exportgraphics(f_conc,[APath 'Short_contact_fomites.TIFF'],'Resolution',300)
else
    exportgraphics(f,[APath 'Long_contact.TIFF'],'Resolution',300)
    exportgraphics(f_conc,[APath 'Long_contact_fomites.TIFF'],'Resolution',300)
end    

%% Plot results

% % Plot viral exposure to different pathways
% figure
% plot(NCleans', vExp(:,1:4))
% grid on;
% xlabel('Number of surface cleaning events');
% ylabel('Viral exposure due to different pathways (No.)');
% legend({'Fomites', 'Close contact', 'Aerosol', 'Total'},'Location','northeast');
% 
% % Plot relative viral exposure to different pathways
% figure
% plot(NCleans', vExp(:,5:7))
% grid on;
% xlabel('Number of surface cleaning events');
% ylabel('Relative viral exposure due to different pathways');
% legend({'Fomites', 'Close contact', 'Aerosol'},'Location','east');


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
        tic;
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
