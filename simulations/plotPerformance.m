function fig = plotPerformance(results, key)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here

% close all

params = strsplit(key, '_');
h_sq = str2num(params{3});
key = char(join(params, ' - '));

ompPerf = results.OMP.testPerf - results.GT.Perf;
qtcatPerf = results.QTCAT.testPerf - results.GT.Perf;


hFig = figure('Position', [200 100 800 500]);
grid on
grid minor
box on
axis equal
hold on

dQTCAT = distributionPlot(qtcatPerf','widthDiv',[2 2],'histOri','right','color',rgb('IndianRed'),'showMM',1,...
                          'histOpt',1, 'divFactor', 1);
alpha(dQTCAT{3}, 0.75);

dOMP = distributionPlot(ompPerf','widthDiv',[2 1],'histOri','left','color',rgb('SteelBlue'),'showMM',1,...
                        'histOpt',1, 'divFactor', 1);
alpha(dOMP{3}, 0.75);

xticks('')

% %============= HELPER LINES ==============
ylims = [-0.69, 0.09];
ylim(ylims);

%---------- seperate
sepL = plot([1,1], ylims);
sepL.Color = rgb('Black');
sepL.LineStyle = '-';
sepL.LineWidth = 1;
%----------

%---------- min
minL = plot(xlim, [0 0]);
minL.Color = rgb('Black');
minL.LineStyle = '-';
minL.LineWidth = 1.2;


%---------- max theor
max_theorL = plot(xlim, [-h_sq -h_sq]);
max_theorL.Color = rgb('DarkGray');
max_theorL.LineStyle = '-';
max_theorL.LineWidth = 1.2;

%---------- welch ttest
[~,pvalue] = ttest(ompPerf', qtcatPerf');

mean(ompPerf)
mean(qtcatPerf)
if mean(ompPerf) > mean(qtcatPerf)
    dim = [.25 .49 .1 .1];
    col = rgb('SteelBlue');
else
    dim = [.25+0.5 .49 .1 .1];
    col = rgb('IndianRed');   
end

tb = annotation('textbox',dim, 'String',['\textbf{$p_{value}=$}', ' ', sprintf('%.2e',pvalue)],...
                'FitBoxToText','on', 'Interpreter','latex');          
            
tb.BackgroundColor = col;
tb.FaceAlpha = 0.53;
tb.FontSize = 12;
tb.HorizontalAlignment = 'center';
tb.VerticalAlignment = 'middle';
tb.FontWeight = 'bold';




[d1,d2,d3,d4] = legendflex([dOMP{1}, dQTCAT{1}],{'\textbf{epilogi}', '\textbf{QTCAT}'},...
           'anchor', {'s', 's'}, ...
           'buffer', [-0.25 0.18], ...
           'bufferunit', 'normalized',...
           'padding', [2 1 4]);
[d1,d2,d3,d4] = legendflex([dOMP{2}(1), dOMP{2}(2)],{'\textbf{Mean}', '\textbf{Median}'},...
           'ref', d1,...
           'anchor', {'ne', 'nw'}, ...
           'buffer', [0.01 0], ...
           'bufferunit', 'normalized',...
           'padding', [2 1 4]);       
       
       
[l1, l2, l3, l4] = legendflex([minL, max_theorL],{'base', 'min'},...
           'anchor', {'s', 's'}, ...
           'buffer', [0.2 0.18], ...
           'bufferunit', 'normalized',...
           'padding', [2 1 4]);
       
       
title(key); 
ylabel('Performance Diffrence')

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



flag=1;
end

