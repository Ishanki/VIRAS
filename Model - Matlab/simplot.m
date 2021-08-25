function [] = simplot(T,Y,p,dir)
%% plot the viral load results Y against the time T for parameters p in directiory dir.
    Figdir=strcat(dir,'Figures/');

    if ~exist(Figdir,'dir')
      mkdir(Figdir);
    end
    dir=Figdir;
   
    air_index = p.NoObj+2*p.NoInd+1;
    pI = Y(:,air_index+1:end);

    fgrn = 0;
    
    % Plot viral load on objects
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for i = 1:p.NoObj
        plot(T,Y(:,i));
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load on objects (No)');
    xlim([min(T(:)),max(T(:))]);
    legend(p.Obj,'Location','eastoutside');
    saveas(f,[dir,'ViralLoadObjects.png'])

    % Plot viral density on objects
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for obji = 1:p.NoObj
        plot(T,Y(:,obji)/p.Aobj(obji,1));
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral density on objects (No./sqcm)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    legend(p.Obj,'Location','eastoutside');
    saveas(f,[dir,'ViralDensityObjects.png'])

    % Plot viral load in air
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    plot(T,Y(:,p.NoObj+2*p.NoInd+1));
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load in air (No)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
%     legend(p.Obj,'Location','eastoutside');
    saveas(f,[dir,'ViralLoadAir.png'])

    % Plot viral density in air
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    plot(T,Y(:,p.NoObj+2*p.NoInd+1)/p.Vair);
    grid on;
    xlabel('Time (h)');
    ylabel('Virus concentration in air (No./cbcm)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
%     legend(p.Obj,'Location','eastoutside');
    saveas(f,[dir,'ViralDensityAir.png'])

    % Plot viral density on materials
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    Atot = zeros(p.NoMat,1);
    Ytot = zeros(size(Y,1),p.NoMat);
    hold on;
    for obji = 1:p.NoMat
        Atot(obji,1) = sum(p.Aobj(p.ObjMat==obji,1));
        Ytot(:,obji) = sum(Y(:,p.ObjMat==obji),2);
        plot(T,Ytot(:,obji)/Atot(obji,1));
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Virus concentration on materials (No./sqcm)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    legend(p.mat,'Location','eastoutside');
    saveas(f,[dir,'ViralDensityMaterials.png'])

    % Plot viral load on hands
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    leg = cell(p.NoInd,1);
    hold on;
    for indi = 1:p.NoInd
        plot(T,Y(:,p.NoObj+indi));
%         plot(T,Y(:,p.NoObj+p.NoInd+indi));
        leg{indi,1} = ['Hands ',num2str(p.IDInd(indi))];
%         leg{2*indi,1} = ['Mucosa ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load on hands (No.)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    legend(leg','Location','eastoutside');
    saveas(f,[dir,'ViralLoadHands.png'])
    
    % Plot viral load on mucous membranes
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    set(f,'Visible',p.FigPop)
    clf;
    leg = cell(p.NoInd,1);
    hold on;
    for indi = 1:p.NoInd
%         plot(T,Y(:,p.NoObj+indi));
        plot(T,Y(:,p.NoObj+p.NoInd+indi));
%         leg{2*indi-1,1} = ['Hands ',num2str(p.IDInd(indi))];
        leg{indi,1} = ['Mucosa ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load on mucous membrane (No.)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    legend(leg','Location','eastoutside');
    saveas(f,[dir,'ViralLoadMucosa.png'])

    % Plot infection risk
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    leg = cell(p.NoInd,1);
    hold on;
    for indi = 1:p.NoInd
        plot(T,100*pI(:,4*p.NoInd+indi));
        leg{indi,1} = num2str(p.IDInd(indi));
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Infection risk (%)');
    % axis([0,p.tsim,0,1]);
    legend(leg','Location','eastoutside');
    saveas(f,[dir,'InfectionRisk.png'])
    
    % Plot viral load on susceptible individual's mucous membrane
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:p.NoInd
     if p.Inf(indi)==0
       plot(T,Y(:,p.NoObj+p.NoInd+indi));
     end
    %         leg{2*indi-1,1} = ['Mucosa ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load on mucous membrane of susceptible individual (No.)');
%     ylim([0,3500]);
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ViralLoadMucosaSus.png'])
    
    % Plot viral exposure of susceptible individual to fomites
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:1
    plot(T,pI(:,indi));
    %         leg{2*indi-1,1} = ['Exposure ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral exposure of susceptible individual to fomites (No.)');
%     ylim([0,3500]);
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ExposureFomitesSus.png'])
    
    % Plot viral exposure of susceptible individual to close contact
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:1
    plot(T,pI(:,p.NoInd+indi));
    %         leg{2*indi-1,1} = ['Exposure ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral exposure of susceptible individual to close contact (No.)');
%     ylim([0,3500]);
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ExposureClosConSus.png'])
    
    % Plot viral exposure of susceptible individual to aerosol
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:1
    plot(T,pI(:,2*p.NoInd+indi));
    %         leg{2*indi-1,1} = ['Exposure ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral exposure of susceptible individual to aerosol (No.)');
%     ylim([0,3500]);
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ExposureAerosolSus.png'])
    
    % Plot total viral exposure of susceptible individual
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:1
        plot(T,pI(:,3*p.NoInd+indi));
    %         leg{2*indi-1,1} = ['Exposure ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Total viral exposure of susceptible individual (No.)');
%     ylim([0,3500]);
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ViralExposureSus.png'])

    % Plot viral load on susceptible individual's hand
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:p.NoInd
      if p.Inf(indi)==0
        plot(T,Y(:,p.NoObj+indi));
      end
    %         leg{2*indi,1} = ['Hands ',num2str(p.IDInd(indi))];
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Viral load on hands of susceptible individual (No.)');
    % axis([min(T(:)),max(T(:)),min(Y(:)),max(Y(:))]);
    saveas(f,[dir,'ViralLoadHandsSus.png'])

    % Plot susceptible individual infection risk
    fgrn = fgrn+1;
    f = figure('Name',int2str(fgrn),'Visible',p.FigPop);
    clf;
    hold on;
    for indi = 1:1
        plot(T,100*pI(:,4*p.NoInd+indi));
    end
    hold off;
    grid on;
    xlabel('Time (h)');
    ylabel('Infection risk of susceptible individual (%)');
%     ylim([0,3.5]);
    % axis([0,p.tsim,0,1]);
    saveas(f,[dir,'InfectionRiskSus.png'])    
    
end