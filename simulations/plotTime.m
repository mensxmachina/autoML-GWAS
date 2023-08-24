function plotTime()

nPoints = 15;
cp = 9;

samples = linspace(0.1, 1, nPoints);
vars = samples(1:cp);



timeQ = readtable(['results/TIME/RTime/TIME.csv']);
timeQ = timeQ{:, 1:cp};

timeO = struct2cell(load('results/TIME/MTime/TIME.mat'));
timeO = timeO{1}(:,1:9);


samplesP = 3:length(samples);
varsP = 1:length(vars);

vq = linspace(vars(1), vars(end), 15);
sq = linspace(0.2, samples(end), 15);

figure('Position', [600 100 900 800], 'Units','points');
%==========================================================================
subplot(2,2,[1;3])
box on
grid on
hold all

vInds = [1, 3, 6, 9];
vText = string({'0.1','0.2','0.4','0.6'});
c=0;
for v=vInds
    c=c+1;
    
    tq = interp1(samples(samplesP), timeQ(samplesP,v),sq, 'pchip');
    
    p1 = plot(sq, tq);
    p1.Color = rgb('IndianRed');
    p1.LineStyle = '-';
    p1.Marker = 's';
    p1.MarkerSize = 6;
    p1.LineWidth = 1.5;
    
    t = text(samples(end), timeQ(end,v),char(vText(c)));
    t.Color = rgb('DarkRed');
    t.FontSize = 10;
    t.FontWeight = 'bold';

    %-----------------------------------------
    
    to = interp1(samples(samplesP), timeO(samplesP,v),sq, 'pchip');

    p2 = plot(sq, to);
    p2.Color = rgb('SteelBlue');
    p2.LineStyle = '-';
    p2.Marker = 'o';
    p2.MarkerSize = 5;
    p2.LineWidth = 1.5;  
    
    t = text(samples(end), timeO(end,v),char(vText(c)));
    t.Color = rgb('DarkBlue');
    t.FontSize = 10;
    t.FontWeight = 'bold';    
end

xlim([0.1 1.15])
xlabel('Sample size')

ylim([-500 12500])
ylabel('Computational time(s)')

legend([p2, p1], {'epilogi','QTCAT'})
title('\fontsize{16}I')
%==========================================================================



%==========================================================================
subplot(2,2,[2;4])
box on
grid on
hold all

sInds = [3,8,11,15];
sText = string({'0.1','0.2','0.4','0.6'});
c=0;
for s=sInds
    c=c+1;
    
    tq = interp1(vars(varsP), timeQ(s,varsP),vq, 'pchip');
    
    p1 = plot(vq, tq);
    p1.Color = rgb('IndianRed');
    p1.LineStyle = '-';
    p1.Marker = 's';
    p1.MarkerSize = 6;
    p1.LineWidth = 1.5; 
    
    t = text(vars(end), timeQ(s,end), char(sText(c)));
    t.Color = rgb('DarkRed');
    t.FontSize = 10;
    t.FontWeight = 'bold';    
    %-----------------------------------------
    
    to = interp1(vars(varsP), timeO(s,varsP),vq, 'pchip');
    
    p2 = plot(vq, to);
    p2.Color = rgb('SteelBlue');
    p2.LineStyle = '-';
    p2.Marker = 'o';
    p2.MarkerSize = 5;
    p2.LineWidth = 1.5;    
    
    t = text(vars(end), timeO(s,end), char(sText(c)));
    t.Color = rgb('DarkBlue');
    t.FontSize = 10;
    t.FontWeight = 'bold';      
end
xlim([0.05 0.69])
xlabel('Feature size')

ylim([-500 12500])
ylabel('Computational time(s)')

legend([p2, p1], {'epilogi','QTCAT'})
title('\fontsize{16}II')
%==========================================================================

end