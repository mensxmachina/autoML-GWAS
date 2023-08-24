
distribution = "gamma";
nSNPs = "20";
h = "0.7";

key = char(join([distribution, nSNPs, h], '_'));
load(char(join(["results/athaliana", key, "results.mat"], '_')));

% Plot model performance
plotPerformance(results, key)

% Plot signature performance
[fig, TPR, FDR] = plotSignature(results, key);

% Plot time
plotTime();