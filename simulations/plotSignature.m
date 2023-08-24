function [fig, TPR, FDR] = plotSignature(results, key)
%PLOTSIGNATURE Summary of this function goes here
%   Detailed explanation goes here


ri = 1;

figure('Position', [600 100 800 450], 'Units','points');
grid on
grid minor
box on
hold on

scenarioParams = strsplit(key, '_');
scenarioParams = ["athaliana", scenarioParams, "ALL"];

folder = ['./results/'];




%============== GROUND TRUTH =============
gtFolder = [folder '/baseline/'];

gtSigs = results.GT.Signature;
nReps = length(gtSigs);
%=========================================


%================= QTCAT =================
qtcatFolder = [folder '/QTCAT/'];

qtcatInfo = results.QTCAT.Range;
%=========================================


%================== gOMP =================
ompFolder = [folder '/epilogi/'];

ompInfo = results.OMP.Range;
%=========================================



%=============== MAIN LOOP ===============
nTh = length(qtcatInfo(1).Signature);
nReps = length(gtSigs);

TPR.QTCAT = nan(nReps, nTh);
TPR.OMP = nan(nReps, nTh);
TPR.OMP2 = nan(nReps, nTh);

FDR.QTCAT = nan(nReps, nTh);
FDR.OMP = nan(nReps, nTh);
FDR.OMP2 = nan(nReps, nTh);

bestFS = nan(nReps, 2);

for i = 1:nReps
    sigGT = gtSigs{i}';
    qFile = [char(join(string({scenarioParams{1}, 'QTCAT', scenarioParams{2:end}, i, 'results'}), '_')) '.mat'];
    oFile = [char(join(string({scenarioParams{1}, 'OMP', scenarioParams{2:end}, i, 'results'}), '_')) '.mat'];
%     disp(['--------------------' num2str(i)])
    for j = 1:nTh
        %----- QTCAT ----
        sigQTCAT = qtcatInfo(i).Signature{j}';
        
        [TPqtcat, FPqtcat] = confmatCalc(sigGT, sigQTCAT, false);
        %-- Correct plot
        TPR.QTCAT(i, j) = length(TPqtcat)/length(sigGT);  
        FDR.QTCAT(i, j) = length(FPqtcat)/length(sigQTCAT);
        
        %----- gOMP ----
        sigOMP = ompInfo(i).Signature{j};
        queueOMP = ompInfo(i).Queues{j};
        if ~iscell(queueOMP)
            queueOMP = mat2cell(queueOMP, 1, ones(1,length(queueOMP)));
        end        
                
        [TPomp, FPomp] = confmatCalc(sigGT, sigOMP, false, queueOMP);
        %-- Correct plot
        TPR.OMP(i, j) = length(TPomp)/length(sigGT);
        FDR.OMP(i, j) = length(FPomp)/length(sigOMP);

        [TPomp2, FPomp2] = confmatCalc(sigGT, sigOMP, true, queueOMP);
        %-- Correct plot
        TPR.OMP2(i, j) = length(TPomp2)/length(sigGT);
        FDR.OMP2(i, j) = length(FPomp2)/length(sigOMP);        
        
    end

    dumkey = char(join(string({scenarioParams{2:end-1}}), '_'));
    qload = load([folder 'QTCAT/' dumkey '/' qFile]);
    oload = load([folder 'epilogi/' dumkey '/' oFile]);
    
    bestFS(i,:) = [qload.qtcatResults.model.bestConfigurationCV(2),...
                   oload.ompResults.model.bestConfigurationCV(2)];

        
end
%=========================================
pvalBoundsLog = log10([1e-6, 0.8]);
pvalThresh = fliplr(logspace(pvalBoundsLog(1), pvalBoundsLog(2), nTh)); % how many scenarios
BICn = 1182; % !!!! HARD CODED !!!!
dbicThresh = chi2inv(1-pvalThresh, 1) + log(BICn);

frbFS = mode(bestFS);
frbFSval = [pvalThresh(frbFS(1)), dbicThresh(frbFS(2))];

TPR.QTCAT = fliplr(TPR.QTCAT);
TPR.OMP = fliplr(TPR.OMP);
TPR.OMP2 = fliplr(TPR.OMP2);

FDR.QTCAT = fliplr(FDR.QTCAT);
FDR.OMP = fliplr(FDR.OMP);
FDR.OMP2 = fliplr(FDR.OMP2);

for j = 1:nTh
    FDR.QTCAT(isnan(FDR.QTCAT(:,j)), j) = mean(FDR.QTCAT(~isnan(FDR.QTCAT(:,j)), j));
    FDR.OMP(isnan(FDR.OMP(:,j)), j) = mean(FDR.OMP(~isnan(FDR.OMP(:,j)), j));
    FDR.OMP2(isnan(FDR.OMP2(:,j)), j) = mean(FDR.OMP2(~isnan(FDR.OMP2(:,j)), j));    
end


offset = 0.02*(0:9);
baseR = 0.03;
%================= QTCAT =================
xq = mean(FDR.QTCAT);
yq = mean(TPR.QTCAT);


xse = std(FDR.QTCAT)/sqrt(size(FDR.QTCAT, 1));
yse = std(TPR.QTCAT)/sqrt(size(TPR.QTCAT, 1));

errQTCAT = errorbar(xq, yq,...
                    yse, min([1-yq; yse]),...
                    xse, min([1-xq; xse]));

errQTCAT.Color = rgb('IndianRed');
errQTCAT.Marker = 'o';
errQTCAT.MarkerFaceColor = rgb('IndianRed');
errQTCAT.LineWidth = 1.2;


Rq = baseR * sum(bestFS(:,1)~=frbFS(1))/nReps;

lsc = [0.55, 0.75, 0.35, 0.015];
RealLims = [0.4, 0.56, 0.25, 0.015];



% lsc = [ones(1,3), 0.015];  % circle if plot axis 1:1

% mod = 1.6;
% qbm = ellipse(Rq*mod, Rq*lsc(ri)*mod,0, xq(nTh+1-frbFS(1)), yq(nTh+1-frbFS(1)));
% qbm.LineStyle = ':';
% qbm.LineWidth = 2;
% qbm.Color = 'k';
%=========================================


%================= gOMP ==================
xo = mean(FDR.OMP);
yo = mean(TPR.OMP);


xse = std(FDR.OMP)/sqrt(size(FDR.OMP, 1));
yse = std(TPR.OMP)/sqrt(size(TPR.OMP, 1));

errOMP = errorbar(xo, yo,...
                    yse, min([1-yo; yse]),...
                    xse, min([1-xo; xse]));

errOMP.Color = rgb('SteelBlue');
errOMP.Marker = 'o';
errOMP.MarkerFaceColor = rgb('SteelBlue');
errOMP.LineWidth = 1.2;


% Ro = baseR * sum(bestFS(:,2)~=frbFS(2))/nReps;
% 
% obm = ellipse(Ro*mod, Ro*lsc(ri)*mod,0, xo(nTh+1-frbFS(2)), yo(nTh+1-frbFS(2)));
% obm.LineStyle = ':';
% obm.LineWidth = 2;
% obm.Color = 'k';
%=========================================

%================= gOMP ==================
xo2 = mean(FDR.OMP2);
yo2 = mean(TPR.OMP2);


xse = std(FDR.OMP2)/sqrt(size(FDR.OMP2, 1));
yse = std(TPR.OMP2)/sqrt(size(TPR.OMP2, 1));

errOMP2 = errorbar(xo2, yo2,...
                    yse, min([1-yo2; yse]),...
                    xse, min([1-xo2; xse]));


errOMP2.Color = rgb('MidnightBlue');
errOMP2.Marker = 'o';
errOMP2.MarkerFaceColor = rgb('MidnightBlue');
errOMP2.LineWidth = 1.2;


% Ro = baseR * sum(bestFS(:,2)~=frbFS(2))/nReps;
% 
% obm = ellipse(Ro*mod, Ro*lsc(ri)*mod,0, xo2(nTh+1-frbFS(2)), yo2(nTh+1-frbFS(2)));
% obm.LineStyle = ':';
% obm.LineWidth = 2;
% obm.Color = 'k';
%=========================================

lims = [-0.01, 1.01];
xlim(lims);


lsc = [0.375, 0.55, 0.25, 0.015];

scTags = string({'athaliana_gamma_20_0.7_ALL', 'athaliana_gaussian_20_0.7_ALL', 'athaliana_gaussian_50_0.7_ALL', 'athaliana_gaussian_150_0.4_ALL'});
ylim(lims)




axPos = get(gca,'Position');

xMinMax = xlim;
yMinMax = ylim;


hold off

xlabel('FDR')
ylabel('TPR')

legend([errOMP, errQTCAT, errOMP2], {'epilogi', 'QTCAT', 'epilogi-MS'}, 'Location','ne');
 
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3) - 0.04;
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left+0.02 bottom ax_width ax_height];


fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];


sum(bestFS(:,1)==frbFS(1)) / nReps;
sum(bestFS(:,2)==frbFS(2)) / nReps;

end


