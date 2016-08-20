function [] = visualizationGUI(dataPath, stimulationKind, saveTag, parametersAlreadyRun, fileNames)
% Create a control panel for creating visualizations of our parametric
% topology data.



if ~exist('saveTag')
    saveTag = 'default';
end

% Change to the location where the data is stored, preserving our previous
% path location.
prevPath = pwd;
if ~exist('parametersAlreadyRun') || ~exist('fileNames')
    reloadRuns();
else
    fprintf('Parameter list pre-loaded!\n');
    
    if ~exist(['completeSpikeHistogram_' saveTag '.mat'], 'file')
        fprintf('... though metrics have not been run yet.\n');
    end
end

cd(dataPath)
cd ..
subPath = pwd;
cd(prevPath)
subPath = [subPath((length(prevPath)+2):end) '/'];
plotFolder = 'data_plots/';


% if ~exist('spikeCountDataPath')
%     global spikeCountDataPath
%     spikeCountDataPath = '20to480ms_spikeCounts.mat';
% end

variableNames{1} = 'Internal Delay Minimum';
variableNames{2} = 'Internal Delay Range';
variableNames{3} = 'External Delay Minimum';
variableNames{4} = 'External Delay Range';
variableNames{5} = 'Internal Connection Density';
variableNames{6} = 'External Connection Density';
variableNames{7} = 'Stimulation Frequency';
variableNames{8} = 'Stimulation Jitter';

stimulationNames{1} = 'Poisson Stimulation';
stimulationNames{2} = 'Normal Stimulation';
stimulationNames{3} = 'Synchronous Normal Stimulation';

metricNames = {'histogramMaximums', ...
                  'summedHistograms', 'histogramVariances', ...
                  'histogramVariancesNZ','histogramNNZ', ...
                  'histogramMedians','histSpectraMetric', ...
                  'isiMeans', 'isiStds', 'isiCounts', ...
                  'driverISImeans','driverISIstds', ...
                  'driverISIcounts', 'spikeCount',...
                  'isiMeansStds','isiStdsStds', ...
                  'driverISImeansStds','driverISIstdsStds', ...
                  'spuriousSpikeCounts', 'spuriousNeuronCounts'};


global hasBeenUpdated
hasBeenUpdated = false;

% % delay distribution (internally) within a cluster. mean and variance
% internalDelayDistribMean = 1:6:30;
% internalDelayDistribVariance = [0:4:18];
% % delay between clusters (externally) mean and variance
% externalDelayDistribMean = [1:6:30];
% externalDelayDistribVariance = [0:4:18];
% % connections per neuron within a cluster (corresponds to density)
% internalNumConnectionsPerNeuron =  5:3:17;
% % connections per neuron between clusters (corresponds to density)
% externalNumConnectionsPerNeuron = 5:3:17;
% % stimuli firing rate (per second) mean and variance
% stimuliMean = 5:10:45;
% stimuliVariance =0:5:20];


parameterRanges = [1:6:25; 0:4:16; 1:6:25; 0:4:16; 5:3:17; 5:3:17; ...
                    5:10:45; 0:5:20];


% First create the figure and plot to manipulate with the slider.
%x = 0:.1:100;  % Some simple data.  Notice the data goes beyond xlim.
%f = figure;  % This is the figure which has the axes to be controlled.
%ax = axes;  % This axes will be controlled.
%plot(x,sin(x));
%xlim([0,pi]);  % Set the beginning x/y limits.
%ylim([-1,1])



% I need to make many check boxes and, for each check box, there needs to be
% something that changes the corresponding parameter in the data.

S.fh = figure('units','pixels',...
              'position',[600 600 950 600],...
              'menubar','none',...
              'name','Network Topology Data Visualizer',...
              'numbertitle','off',...
              'resize','off');        
          

% one text element for each parameter, one check box for each setting of
% that parameter
%S.somethingelse = uicontrol('style','text',...
%                 'unit','pix',...
%                 'position',[10 150 180 40],...
%                 'string','Parameter',...
%                 'fontsize',23);



plotConditions = zeros(8,5);
% This is an invisible ui element hack to store the plotConditions data in
% the figure in a way that makes it easy to modify and pass to functions
% plotConditions is for the check boxes.
S.plotConditions = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                 'position', [10 550 180 40], ...
                                 'string', num2str(plotConditions), ...
                                 'visible', 'off');

% Edit run choices
S.timeRangetx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[620 550 100 20],...
                    'string', 'Analysis Range', ...
                    'fontsize', 14);
S.edTimeRange1 = uicontrol('style','edit',...
                 'units','pix',...
                 'position',[620 520 40 25],...
                 'min',0,'max',1,...
                 'string',{'1'},...                 
                 'fontweight','bold',...
                 'horizontalalign','center',...
                 'fontsize',11);
S.edTimeRange2 = uicontrol('style','edit',...
             'units','pix',...
             'position',[680 520 40 25],...
             'min',0,'max',1,...
             'string',{'1000'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);

 S.maxISItx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[620 480 100 20],...
                    'string', 'Max ISI', ...
                    'fontsize', 14);
S.edMaxISI = uicontrol('style','edit',...
                 'units','pix',...
                 'position',[645 450 40 25],...
                 'min',0,'max',1,...
                 'string',{'1000'},...                 
                 'fontweight','bold',...
                 'horizontalalign','center',...
                 'fontsize',11);
 S.minSpikes = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[620 340 140 20],...
                    'string', 'Spike Count Bounds', ...
                    'fontsize', 14);
S.edSpikeRange1 = uicontrol('style','edit',...
                 'units','pix',...
                 'position',[620 310 60 30],...
                 'min',0,'max',1,...
                 'string',{'200'},...                 
                 'fontweight','bold',...
                 'horizontalalign','center',...
                 'fontsize',11);
S.edSpikeRange2 = uicontrol('style','edit',...
             'units','pix',...
             'position',[680 310 60 30],...
             'min',0,'max',1,...
             'string',{'500000'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);
         
S.histMaxtx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[780 550 140 20],...
                    'string', 'Max Histogram Cutoff', ...
                    'fontsize', 14);
S.useHistMax = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[850 520 80 25],...
                 'string','Use',...
                 'fontsize',12);
S.edHistMax = uicontrol('style','edit',...
             'units','pix',...
             'position',[790 520 40 25],...
             'min',0,'max',1,...
             'string',{'2000'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);
         
         
S.histSpectratx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[780 465 140 40],...
                    'string', 'Histogram Spectra Metric', ...
                    'fontsize', 14);
S.useHistSpectra = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[890 430 140 25],...
                 'string','Use',...
                 'fontsize',12);
S.edHistSpectraMin = uicontrol('style','edit',...
             'units','pix',...
             'position',[790 430 50 25],...
             'min',0,'max',1,...
             'string',{'-10000'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);
S.edHistSpectraMax = uicontrol('style','edit',...
             'units','pix',...
             'position',[840 430 50 25],...
             'min',0,'max',1,...
             'string',{'2000'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);
         


% S.histShifttx = uicontrol('style','text',...
%                     'unit', 'pix',...
%                     'position',[780 380 140 40],...
%                     'string', 'Histogram Shift Speed', ...
%                     'fontsize', 14);
%                 
% S.useShiftSpeed = uicontrol('style','check',...
%                  'unit','pix',...
%                  'position',[890 350 140 25],...
%                  'string','Use',...
%                  'fontsize',12);
% S.edShiftSpeedMin = uicontrol('style','edit',...
%              'units','pix',...
%              'position',[790 350 50 25],...
%              'min',0,'max',1,...
%              'string',{'0'},...                 
%              'fontweight','bold',...
%              'horizontalalign','center',...
%              'fontsize',11);
% S.edShiftSpeedMax = uicontrol('style','edit',...
%              'units','pix',...
%              'position',[840 350 50 25],...
%              'min',0,'max',1,...
%              'string',{'0.125'},...                 
%              'fontweight','bold',...
%              'horizontalalign','center',...
%              'fontsize',11);
         
         
S.isiCounttx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[780 310 140 20],...
                    'string', 'ISI Count Minimum', ...
                    'fontsize', 14);
                
S.edisiCountMin = uicontrol('style','edit',...
             'units','pix',...
             'position',[790 270 50 25],...
             'min',0,'max',1,...
             'string',{'120'},...                 
             'fontweight','bold',...
             'horizontalalign','center',...
             'fontsize',11);
S.useISIcount = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[890 270 140 25],...
                 'string','Use',...
                 'fontsize',12);

             
S.metricTx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[790 240 100 15],...
                    'string', 'Metric Axes', ...
                    'fontsize', 14);             
S.xMetricTx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[770 210 20 20],...
                    'string', 'x:', ...
                    'fontsize', 12);
S.yMetricTx = uicontrol('style','text',...
                    'unit', 'pix',...
                    'position',[770 180 20 20],...
                    'string', 'y:', ...
                    'fontsize', 12);
S.xMetric = uicontrol('style','pop',...
                  'units','pixels',...
                  'position',[790 190 150 40],...
                  'string',metricNames);
S.yMetric = uicontrol('style','pop',...
                  'units','pixels',...
                  'position',[790 160 150 40],...
                  'string',metricNames);


         
% S.numReptx = uicontrol('style','text',...
%                     'unit', 'pix',...
%                     'position',[620 400 100 35],...
%                     'string', 'Number of Replications', ...
%                     'fontsize', 14);
% S.edNumRep = uicontrol('style','edit',...
%                  'units','pix',...
%                  'position',[645 370 40 25],...
%                  'min',0,'max',1,...
%                  'string',{'1'},...                 
%                  'fontweight','bold',...
%                  'horizontalalign','center',...
%                  'fontsize',11);


                             
% State the parameter, then state 5 check boxes.
S.iddmtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 560 180 20], ...
                                'string', variableNames{1}, ...
                                'fontsize', 14);
S.iddm1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 525 40 35],...
                 'string',num2str(parameterRanges(1,1)),...
                 'fontsize',12);
S.iddm2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 525 40 35],...
                 'string',num2str(parameterRanges(1,2)),...
                 'fontsize',12);
S.iddm3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 525 40 35],...
                 'string',num2str(parameterRanges(1,3)),...
                 'fontsize',12);
S.iddm4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 525 40 35],...
                 'string',num2str(parameterRanges(1,4)),...
                 'fontsize',12);
S.iddm5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 525 40 35],...
                 'string',num2str(parameterRanges(1,5)),...
                 'fontsize',12);
             
S.iddvtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 485 180 20], ...
                                'string', variableNames{2}, ...
                                'fontsize', 14);
S.iddv1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 450 40 35],...
                 'string',num2str(parameterRanges(2,1)),...
                 'fontsize',12);
S.iddv2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 450 40 35],...
                 'string',num2str(parameterRanges(2,2)),...
                 'fontsize',12);
S.iddv3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 450 40 35],...
                 'string',num2str(parameterRanges(2,3)),...
                 'fontsize',12);
S.iddv4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 450 40 35],...
                 'string',num2str(parameterRanges(2,4)),...
                 'fontsize',12);
S.iddv5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 450 40 35],...
                 'string',num2str(parameterRanges(2,5)),...
                 'fontsize',12);
             

S.eddmtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 410 180 20], ...
                                'string', variableNames{3}, ...
                                'fontsize', 14);
S.eddm1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 375 40 35],...
                 'string',num2str(parameterRanges(3,1)),...
                 'fontsize',12);
S.eddm2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 375 40 35],...
                 'string',num2str(parameterRanges(3,2)),...
                 'fontsize',12);
S.eddm3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 375 40 35],...
                 'string',num2str(parameterRanges(3,3)),...
                 'fontsize',12);
S.eddm4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 375 40 35],...
                 'string',num2str(parameterRanges(3,4)),...
                 'fontsize',12);
S.eddm5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 375 40 35],...
                 'string',num2str(parameterRanges(3,5)),...
                 'fontsize',12);            
             
S.eddvtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 335 180 20], ...
                                'string', variableNames{4}, ...
                                'fontsize', 14);
S.eddv1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 300 40 35],...
                 'string',num2str(parameterRanges(4,1)),...
                 'fontsize',12);
S.eddv2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 300 40 35],...
                 'string',num2str(parameterRanges(4,2)),...
                 'fontsize',12);
S.eddv3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 300 40 35],...
                 'string',num2str(parameterRanges(4,3)),...
                 'fontsize',12);
S.eddv4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 300 40 35],...
                 'string',num2str(parameterRanges(4,4)),...
                 'fontsize',12);
S.eddv5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 300 40 35],...
                 'string',num2str(parameterRanges(4,5)),...
                 'fontsize',12);            

S.incpntx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 260 180 20], ...
                                'string', variableNames{5}, ...
                                'fontsize', 14);
S.incpn1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 225 40 35],...
                 'string',num2str(parameterRanges(5,1)),...
                 'fontsize',12);
S.incpn2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 225 40 35],...
                 'string',num2str(parameterRanges(5,2)),...
                 'fontsize',12);
S.incpn3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 225 40 35],...
                 'string',num2str(parameterRanges(5,3)),...
                 'fontsize',12);
S.incpn4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 225 40 35],...
                 'string',num2str(parameterRanges(5,4)),...
                 'fontsize',12);
S.incpn5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 225 40 35],...
                 'string',num2str(parameterRanges(5,5)),...
                 'fontsize',12);            

S.encpntx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 185 180 20], ...
                                'string', variableNames{6}, ...
                                'fontsize', 14);
S.encpn1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 150 40 35],...
                 'string',num2str(parameterRanges(6,1)),...
                 'fontsize',12);
S.encpn2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 150 40 35],...
                 'string',num2str(parameterRanges(6,2)),...
                 'fontsize',12);
S.encpn3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 150 40 35],...
                 'string',num2str(parameterRanges(6,3)),...
                 'fontsize',12);
S.encpn4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 150 40 35],...
                 'string',num2str(parameterRanges(6,4)),...
                 'fontsize',12);
S.encpn5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 150 40 35],...
                 'string',num2str(parameterRanges(6,5)),...
                 'fontsize',12);            

S.smtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 110 180 20], ...
                                'string', variableNames{7}, ...
                                'fontsize', 14);
S.sm1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 75 40 35],...
                 'string',num2str(parameterRanges(7,1)),...
                 'fontsize',12);
S.sm2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 75 40 35],...
                 'string',num2str(parameterRanges(7,2)),...
                 'fontsize',12);
S.sm3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 75 40 35],...
                 'string',num2str(parameterRanges(7,3)),...
                 'fontsize',12);
S.sm4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 75 40 35],...
                 'string',num2str(parameterRanges(7,4)),...
                 'fontsize',12);
S.sm5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 75 40 35],...
                 'string',num2str(parameterRanges(7,5)),...
                 'fontsize',12);                              

S.smtx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [40 50 180 20], ...
                                'string', variableNames{8}, ...
                                'fontsize', 14);
S.sv1 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[10 15 40 35],...
                 'string',num2str(parameterRanges(8,1)),...
                 'fontsize',12);
S.sv2 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[50 15 40 35],...
                 'string',num2str(parameterRanges(8,2)),...
                 'fontsize',12);
S.sv3 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[100 15 40 35],...
                 'string',num2str(parameterRanges(8,3)),...
                 'fontsize',12);
S.sv4 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[150 15 40 35],...
                 'string',num2str(parameterRanges(8,4)),...
                 'fontsize',12);
S.sv5 = uicontrol('style','check',...
                 'unit','pix',...
                 'position',[200 15 40 35],...
                 'string',num2str(parameterRanges(8,5)),...
                 'fontsize',12);                              
             

S.linetx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [370 550 180 40], ...
                                'string', 'Split this parameter into multiple lines:', ...
                                'fontsize', 14);
             


S.lineRadio(1) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [350 500 80 35], ...
                             'string', 'IDDM', ...
                             'Value', 0);
S.lineRadio(2) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [410 500 80 35], ...
                             'string', 'IDDV', ...
                             'Value', 0);
S.lineRadio(3) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [470 500 80 35], ...
                             'string', 'EDDM', ...
                             'Value', 0);
S.lineRadio(4) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [530 500 80 35], ...
                             'string', 'EDDV', ...
                             'Value', 0);
S.lineRadio(5) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [350 475 80 35], ...
                             'string', 'INCPN', ...
                             'Value', 0);
S.lineRadio(6) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [410 475 80 35], ...
                             'string', 'ENCPN', ...
                             'Value', 0);
S.lineRadio(7) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [470 475 80 35], ...
                             'string', 'SM', ...
                             'Value', 0);
S.lineRadio(8) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myRadio, ...
                            'unit', 'pix', ...
                             'position', [530 475 80 35], ...
                             'string', 'SV', ...
                             'Value', 0);

S.axistx = uicontrol('style', 'text', ...
                                'unit', 'pix', ...
                                'position', [370 400 180 40], ...
                                'string', 'Vary this parameter along the horizontal axis:', ...
                                'fontsize', 14);                         
                         
S.axisRadio(1) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [350 350 80 35], ...
                             'string', 'IDDM', ...
                             'Value', 0);
S.axisRadio(2) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [410 350 80 35], ...
                             'string', 'IDDV', ...
                             'Value', 0);
S.axisRadio(3) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [470 350 80 35], ...
                             'string', 'EDDM', ...
                             'Value', 0);
S.axisRadio(4) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [530 350 80 35], ...
                             'string', 'EDDV', ...
                             'Value', 0);
S.axisRadio(5) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [350 325 80 35], ...
                             'string', 'INCPN', ...
                             'Value', 0);
S.axisRadio(6) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [410 325 80 35], ...
                             'string', 'ENCPN', ...
                             'Value', 0);
S.axisRadio(7) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [470 325 80 35], ...
                             'string', 'SM', ...
                             'Value', 0);
S.axisRadio(8) = uicontrol('Style', 'radiobutton', ...
                            'Callback', @myLineRadio, ...
                            'unit', 'pix', ...
                             'position', [530 325 80 35], ...
                             'string', 'SV', ...
                             'Value', 0);                         
                         
S.checkAll = uicontrol('style', 'pushbutton', ...
                        'units', 'pixels', ...
                        'position', [260 20 80 35], ...
                        'string', 'Check All', ...
                        'fontsize', 12);
                    
S.visualizeISI = uicontrol('style','pushbutton',...
                  'units','pixels',...
                  'position',[320 200 180 35],...
                  'string','Visualize ISIs',...
                  'fontsize',12);

S.metricLines = uicontrol('style','pushbutton',...
                  'units','pixels',...
                  'position',[320 250 180 35],...
                  'string','Plot Lines of Metric',...
                  'fontsize',12);
              
S.plotDistribution = uicontrol('style','pushbutton',...
                  'units','pixels',...
                  'position',[600 250 150 35],...
                  'string','Plot ISI Freq Distributions',...
                  'fontsize',12);

% S.plotSpikeHist = uicontrol('style','pushbutton',...
%                   'units','pixels',...
%                   'position',[600 150 150 35],...
%                   'string','Plot Spike Distributions',...
%                   'fontsize',12);

% S.plotSpikeCount = uicontrol('style','pushbutton',...
%                   'units','pixels',...
%                   'position',[600 200 150 35],...
%                   'string','Plot Spike Count',...
%                   'fontsize',12);
              
S.stimTriggeredHist = uicontrol('style','pushbutton',...
                  'units','pixels',...
                  'position',[500 250 70 35],...
                  'string','...StimTriggered',...
                  'fontsize',12);
              
% S.missingRuns = uicontrol('style','pushbutton',...
%                   'units','pixels',...
%                   'position',[400 150 150 35],...
%                   'string','Determine Missing Runs',...
%                   'fontsize',12);
S.plotSpikes = uicontrol('style','pushbutton',...
                  'units','pixels',...
                  'position',[400 110 150 35],...
                  'string','Plot All Spike Rasters',...
                  'fontsize',12);
% S.runMissingData = uicontrol('style','pushbutton',...
%                   'units','pixels',...
%                   'position',[400 60 150 35],...
%                   'string','Run missing data...',...
%                   'fontsize',12);
              
S.busy = uicontrol('style', 'text', ...
                    'units', 'pixels',...
                    'position', [360 270 200 30], ...
                    'string', 'Evaluating Data...', ...
                    'fontsize', 20, ...
                    'visible', 'off');
% S.plotISIvariance = uicontrol('style','pushbutton',...
%                   'units','pixels',...
%                   'position',[400 20 150 35],...
%                   'string','Plot All ISIs and Save',...
%                   'fontsize',12);
% S.runSshJobsParallel = uicontrol('style','pushbutton',...
%           'units','pixels',...
%           'position',[250 100 150 35],...
%           'string','Distribute jobs over Network',...
%           'fontsize',12);
      
% S.scrapeData = uicontrol('style','pushbutton',...
%           'units','pixels',...
%           'position',[250 60 150 35],...
%           'string','Scrape Data from Network',...
%           'fontsize',12);

% S.computeMetrics = uicontrol('style','pushbutton',...
%           'units','pixels',...
%           'position',[250 150 75 35],...
%           'string','Run Metrics',...
%           'fontsize',12);
S.plotCentrality = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[325 150 75 35],...
          'string','Plot Cent',...
          'fontsize',12);      
S.plotSingleSpikes = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[600 100 150 35],...
          'string','Single Run Spike Raster',...
          'fontsize',12);
S.plotMaxHistSpikes = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[600 50 150 35],...
          'string','Plot ==MaxHist Spikes',...
          'fontsize',12);

S.singleRunISIs = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[600 10 150 35],...
          'string','Plot ISIs for Single Run',...
          'fontsize',12);
% S.spikeCountVsHistMaxVsMedian = uicontrol('style','pushbutton',...
%           'units','pixels',...
%           'position',[770 10 150 35],...
%           'string','Plot spikeCount vs histMedian',...
%           'fontsize',12);
S.metricVsMetricPlot = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[770 50 150 35],...
          'string','X vs. Y Metric Plot',...
          'fontsize',12);
S.plotSingleDerivatives = uicontrol('style','pushbutton',...
          'units','pixels',...
          'position',[770 100 150 35],...
          'string','Single Run Analysis Plots',...
          'fontsize',12);

%plotSingleDerivatives_call


                


set(S.checkAll, 'callback', {@checkAll_call, S});              
set(S.visualizeISI, 'callback', {@visualizeISI_call, S});
set(S.metricLines, 'callback', {@metricLines_call, S});
set(S.stimTriggeredHist, 'callback', {@stimTriggeredHist_call, S});
%set(S.missingRuns, 'callback', {@missingRuns_call, S});
set(S.plotSpikes, 'callback', {@plotAllSpikes_call, S});
set(S.plotMaxHistSpikes, 'callback', {@plotAllParamsMaxHist_call, S});
set(S.singleRunISIs, 'callback', {@singleRunISIs_call, S});
%set(S.spikeCountVsHistMaxVsMedian, 'callback', {@spikeCountVsHistMaxVsMedian_call, S});
set(S.metricVsMetricPlot, 'callback', {@metricVsMetricPlot_call, S});
set(S.plotSingleSpikes, 'callback', {@plotSingleSpikes_call, S});
set(S.plotSingleDerivatives, 'callback', {@plotSingleDerivatives_call, S});
set(S.plotDistribution, 'callback', {@ISIdistribution_call,S});
%set(S.plotSpikeCount, 'callback', {@spikeCount_call,S});
%set(S.plotSpikeHist, 'callback', {@spikeHistogram_call,S});
%set(S.runMissingData, 'callback', {@runMissingData_call, S});
%set(S.plotISIvariance, 'callback', {@plotISIvariance_call, S});
set(S.plotCentrality, 'callback', {@plotCentrality_call, S});
%set(S.runSshJobsParallel, 'callback', {@runSshJobsParallel_call,S});
%set(S.computeMetrics, 'callback', {@computeMetrics_call,S});
%set(S.scrapeData, 'callback', {@scrapeData_call, S});


set(S.lineRadio, 'callback', {@myRadio, S});
set(S.axisRadio, 'callback', {@myLineRadio, S});

set(S.iddm1, 'callback', {@iddm1_call, S});
set(S.iddm2, 'callback', {@iddm2_call, S});
set(S.iddm3, 'callback', {@iddm3_call, S});
set(S.iddm4, 'callback', {@iddm4_call, S});
set(S.iddm5, 'callback', {@iddm5_call, S});
set(S.iddv1, 'callback', {@iddv1_call, S});
set(S.iddv2, 'callback', {@iddv2_call, S});
set(S.iddv3, 'callback', {@iddv3_call, S});
set(S.iddv4, 'callback', {@iddv4_call, S});
set(S.iddv5, 'callback', {@iddv5_call, S});
set(S.eddm1, 'callback', {@eddm1_call, S});
set(S.eddm2, 'callback', {@eddm2_call, S});
set(S.eddm3, 'callback', {@eddm3_call, S});
set(S.eddm4, 'callback', {@eddm4_call, S});
set(S.eddm5, 'callback', {@eddm5_call, S});
set(S.eddv1, 'callback', {@eddv1_call, S});
set(S.eddv2, 'callback', {@eddv2_call, S});
set(S.eddv3, 'callback', {@eddv3_call, S});
set(S.eddv4, 'callback', {@eddv4_call, S});
set(S.eddv5, 'callback', {@eddv5_call, S});
set(S.incpn1, 'callback', {@incpn1_call, S});
set(S.incpn2, 'callback', {@incpn2_call, S});
set(S.incpn3, 'callback', {@incpn3_call, S});
set(S.incpn4, 'callback', {@incpn4_call, S});
set(S.incpn5, 'callback', {@incpn5_call, S});
set(S.encpn1, 'callback', {@encpn1_call, S});
set(S.encpn2, 'callback', {@encpn2_call, S});
set(S.encpn3, 'callback', {@encpn3_call, S});
set(S.encpn4, 'callback', {@encpn4_call, S});
set(S.encpn5, 'callback', {@encpn5_call, S});
set(S.sm1, 'callback', {@sm1_call, S});
set(S.sm2, 'callback', {@sm2_call, S});
set(S.sm3, 'callback', {@sm3_call, S});
set(S.sm4, 'callback', {@sm4_call, S});
set(S.sm5, 'callback', {@sm5_call, S});
set(S.sv1, 'callback', {@sv1_call, S});
set(S.sv2, 'callback', {@sv2_call, S});
set(S.sv3, 'callback', {@sv3_call, S});
set(S.sv4, 'callback', {@sv4_call, S});
set(S.sv5, 'callback', {@sv5_call, S});


function [] = myRadio(varargin)
    S = varargin{3};
    otherRadio = S.lineRadio(S.lineRadio ~= varargin{1});
    set(otherRadio, 'Value', 0)
    % This makes it so if you click an already-on radio button, it stays on
    % instead of turning off. This ensures that at least one radio button
    % always has a value of 1 (since the GUI starts with one on already).
    specificRadio = S.lineRadio(S.lineRadio == varargin{1});
    set(specificRadio, 'Value', 1);
end

function [] = myLineRadio(varargin)
    S = varargin{3};
    otherRadio = S.axisRadio(S.axisRadio ~= varargin{1});
    set(otherRadio, 'Value', 0)
    % This makes it so if you click an already-on radio button, it stays on
    % instead of turning off. This ensures that at least one radio button
    % always has a value of 1 (since the GUI starts with one on already).
    specificRadio = S.axisRadio(S.axisRadio == varargin{1});
    set(specificRadio, 'Value', 1);
end

function [] = iddm1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,1)
        plotConditions(1,1) = 0;
    else
        plotConditions(1,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddm2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,2)
        plotConditions(1,2) = 0;
    else
        plotConditions(1,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddm3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,3)
        plotConditions(1,3) = 0;
    else
        plotConditions(1,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddm4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,4)
        plotConditions(1,4) = 0;
    else
        plotConditions(1,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddm5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,5)
        plotConditions(1,5) = 0;
    else
        plotConditions(1,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddv1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(2,1)
        plotConditions(2,1) = 0;
    else
        plotConditions(2,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddv2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(2,2)
        plotConditions(2,2) = 0;
    else
        plotConditions(2,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddv3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(2,3)
        plotConditions(2,3) = 0;
    else
        plotConditions(2,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddv4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(2,4)
        plotConditions(2,4) = 0;
    else
        plotConditions(2,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = iddv5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(2,5)
        plotConditions(2,5) = 0;
    else
        plotConditions(2,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddm1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(3,1)
        plotConditions(3,1) = 0;
    else
        plotConditions(3,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddm2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(3,2)
        plotConditions(3,2) = 0;
    else
        plotConditions(3,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddm3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(3,3)
        plotConditions(3,3) = 0;
    else
        plotConditions(3,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddm4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(3,4)
        plotConditions(3,4) = 0;
    else
        plotConditions(3,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddm5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(3,5)
        plotConditions(3,5) = 0;
    else
        plotConditions(3,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddv1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(4,1)
        plotConditions(4,1) = 0;
    else
        plotConditions(4,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddv2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(4,2)
        plotConditions(4,2) = 0;
    else
        plotConditions(4,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddv3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(4,3)
        plotConditions(4,3) = 0;
    else
        plotConditions(4,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddv4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(4,4)
        plotConditions(4,4) = 0;
    else
        plotConditions(4,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = eddv5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(4,5)
        plotConditions(4,5) = 0;
    else
        plotConditions(4,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = incpn1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(5,1)
        plotConditions(5,1) = 0;
    else
        plotConditions(5,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = incpn2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(5,2)
        plotConditions(5,2) = 0;
    else
        plotConditions(5,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = incpn3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(5,3)
        plotConditions(5,3) = 0;
    else
        plotConditions(5,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = incpn4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(5,4)
        plotConditions(5,4) = 0;
    else
        plotConditions(5,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = incpn5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(5,5)
        plotConditions(5,5) = 0;
    else
        plotConditions(5,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = encpn1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(6,1)
        plotConditions(6,1) = 0;
    else
        plotConditions(6,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = encpn2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(6,2)
        plotConditions(6,2) = 0;
    else
        plotConditions(6,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = encpn3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(6,3)
        plotConditions(6,3) = 0;
    else
        plotConditions(6,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = encpn4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(6,4)
        plotConditions(6,4) = 0;
    else
        plotConditions(6,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = encpn5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(6,5)
        plotConditions(6,5) = 0;
    else
        plotConditions(6,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sm1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(7,1)
        plotConditions(7,1) = 0;
    else
        plotConditions(7,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sm2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(7,2)
        plotConditions(7,2) = 0;
    else
        plotConditions(7,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sm3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(7,3)
        plotConditions(7,3) = 0;
    else
        plotConditions(7,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sm4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(7,4)
        plotConditions(7,4) = 0;
    else
        plotConditions(7,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sm5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(7,5)
        plotConditions(7,5) = 0;
    else
        plotConditions(7,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sv1_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(8,1)
        plotConditions(8,1) = 0;
    else
        plotConditions(8,1) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sv2_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(8,2)
        plotConditions(8,2) = 0;
    else
        plotConditions(8,2) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sv3_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(8,3)
        plotConditions(8,3) = 0;
    else
        plotConditions(8,3) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sv4_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(8,4)
        plotConditions(8,4) = 0;
    else
        plotConditions(8,4) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end
function [] = sv5_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(8,5)
        plotConditions(8,5) = 0;
    else
        plotConditions(8,5) = 1;
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end


function [] = checkAll_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    if plotConditions(1,1)
        plotConditions(:,:) = 0;
        set(S.iddm1, 'Value', 0);
        set(S.iddm2, 'Value', 0);
        set(S.iddm3, 'Value', 0);
        set(S.iddm4, 'Value', 0);
        set(S.iddm5, 'Value', 0);
        set(S.iddv1, 'Value', 0);
        set(S.iddv2, 'Value', 0);
        set(S.iddv3, 'Value', 0);
        set(S.iddv4, 'Value', 0);
        set(S.iddv5, 'Value', 0);
        set(S.eddm1, 'Value', 0);
        set(S.eddm2, 'Value', 0);
        set(S.eddm3, 'Value', 0);
        set(S.eddm4, 'Value', 0);
        set(S.eddm5, 'Value', 0);
        set(S.eddv1, 'Value', 0);
        set(S.eddv2, 'Value', 0);
        set(S.eddv3, 'Value', 0);
        set(S.eddv4, 'Value', 0);
        set(S.eddv5, 'Value', 0);
        set(S.incpn1, 'Value', 0);
        set(S.incpn2, 'Value', 0);
        set(S.incpn3, 'Value', 0);
        set(S.incpn4, 'Value', 0);
        set(S.incpn5, 'Value', 0);
        set(S.encpn1, 'Value', 0);
        set(S.encpn2, 'Value', 0);
        set(S.encpn3, 'Value', 0);
        set(S.encpn4, 'Value', 0);
        set(S.encpn5, 'Value', 0);
        set(S.sm1, 'Value', 0);
        set(S.sm2, 'Value', 0);
        set(S.sm3, 'Value', 0);
        set(S.sm4, 'Value', 0);
        set(S.sm5, 'Value', 0);
        set(S.sv1, 'Value', 0);
        set(S.sv2, 'Value', 0);
        set(S.sv3, 'Value', 0);
        set(S.sv4, 'Value', 0);
        set(S.sv5, 'Value', 0);
    else
        plotConditions(:,:) = 1;
        set(S.iddm1, 'Value', 1);
        set(S.iddm2, 'Value', 1);
        set(S.iddm3, 'Value', 1);
        set(S.iddm4, 'Value', 1);
        set(S.iddm5, 'Value', 1);
        set(S.iddv1, 'Value', 1);
        set(S.iddv2, 'Value', 1);
        set(S.iddv3, 'Value', 1);
        set(S.iddv4, 'Value', 1);
        set(S.iddv5, 'Value', 1);
        set(S.eddm1, 'Value', 1);
        set(S.eddm2, 'Value', 1);
        set(S.eddm3, 'Value', 1);
        set(S.eddm4, 'Value', 1);
        set(S.eddm5, 'Value', 1);
        set(S.eddv1, 'Value', 1);
        set(S.eddv2, 'Value', 1);
        set(S.eddv3, 'Value', 1);
        set(S.eddv4, 'Value', 1);
        set(S.eddv5, 'Value', 1);
        set(S.incpn1, 'Value', 1);
        set(S.incpn2, 'Value', 1);
        set(S.incpn3, 'Value', 1);
        set(S.incpn4, 'Value', 1);
        set(S.incpn5, 'Value', 1);
        set(S.encpn1, 'Value', 1);
        set(S.encpn2, 'Value', 1);
        set(S.encpn3, 'Value', 1);
        set(S.encpn4, 'Value', 1);
        set(S.encpn5, 'Value', 1);
        set(S.sm1, 'Value', 1);
        set(S.sm2, 'Value', 1);
        set(S.sm3, 'Value', 1);
        set(S.sm4, 'Value', 1);
        set(S.sm5, 'Value', 1);
        set(S.sv1, 'Value', 1);
        set(S.sv2, 'Value', 1);
        set(S.sv3, 'Value', 1);
        set(S.sv4, 'Value', 1);
        set(S.sv5, 'Value', 1);
    end
    set(S.plotConditions, 'string', num2str(plotConditions));
end

% ###### Data Infrastructure functions

function [ultimateParameterList] = missingRuns_call(varargin)
    % This function will determine which runs are required to generate
    % a plot with the specified conditions.


S = varargin{3};
plotConditions = str2num(get(S.plotConditions, 'string'));


numReplications = str2double(get(S.edNumRep,'string'));
numFiles = size(parametersAlreadyRun, 1);


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);
if isempty(lineParam) || isempty(axisParam)
    fprintf('\n No line or axis parameters selected! Returning empty.');
    ultimateParameterList = [];
    return
end


plotParams(1) = lineParam;
plotParams(2) = axisParam;
% Ignore check boxes for params that define lines and axes
plotConditions(lineParam, :) = [1 1 1 1 1];
plotConditions(axisParam, :) = [1 1 1 1 1];

if lineParam == axisParam
    disp('Your axis parameter is the same as your line parameter! Consider revising.');
end


plotParamNum = 1;
% To have index values that correspond to the correct parameter, we create
% a list of indexes for each parameter combination we don't have.
for parIndex = 1:8
    if nnz(parIndex == plotParams) > 0
        % The value doesn't matter here, just that it exists so that we
        % don't fail to run the code contained by the parameter's for
        % loop.
        chosenParameterIndexes{parIndex} = 1;
        plotParamIndexes{plotParamNum} = find(plotConditions(parIndex,:));
        plotParamNum = plotParamNum + 1;
    else
        chosenParameterIndexes{parIndex} = find(plotConditions(parIndex,:));
    end
end

% Now that we know which parameter conditions to run, we can see which have
% already been run.

% The ultimateParameterList combines all the finalParameterLists into a
% giant list of all parameters that are to be run. This allows parfors
% to distribute the optimal amount of jobs per initiation in the loop
% that follows this one.
ultimateParameterList = [];

fprintf('Determining runs... ');

% Now that we know which parameter conditions to consider, we determine
% which conditions have already been run.
for p1 = parameterRanges(1, chosenParameterIndexes{1})
    for p2 = parameterRanges(2, chosenParameterIndexes{2})
        for p3 = parameterRanges(3, chosenParameterIndexes{3})
            for p4 = parameterRanges(4, chosenParameterIndexes{4})
                for p5 = parameterRanges(5, chosenParameterIndexes{5})
                    for p6 = parameterRanges(6, chosenParameterIndexes{6})
                        for p7 = parameterRanges(7, chosenParameterIndexes{7})
                            for p8 = parameterRanges(8, chosenParameterIndexes{8})

                                % At this point, assemble a list of
                                % parameter settings to be checked in
                                % parallel.                                    
                                fullParamList = [];
                                for parParam1 = parameterRanges(lineParam, plotParamIndexes{1})
                                    for parParam2 = parameterRanges(axisParam, plotParamIndexes{2})
                                       tempParams = [p1 p2 p3 p4 p5 p6 p7 p8];
                                       tempParams(plotParams(1)) = parParam1;
                                       tempParams(plotParams(2)) = parParam2;
                                       fullParamList = [fullParamList; tempParams];
                                    end
                                end

                                % indexesToBeRun has tracks how many
                                % runs are required of each parameter
                                % set. It starts off at the number of
                                % replications, and is decreased for
                                % each replication found.
                                indexesToBeRun = numReplications*ones(size(fullParamList,1),1);
                                % Only check if there are previous runs.
                                if numFiles > 0
                                    % Since all the runs will have 6
                                    % fixed parameters, we restrict our
                                    % itemized search to only runs
                                    % with all parameters.
                                    fixedParams = ones(8,1);
                                    fixedParams(plotParams(1)) = 0;
                                    fixedParams(plotParams(2)) = 0;
                                    alreadyRunFilter = zeros(size(parametersAlreadyRun, 1), 1);
                                    fixedParams= find(fixedParams);
                                    for pIndex = 1:length(fixedParams)
                                        nonParallelParIndex = fixedParams(pIndex);
                                        runsWithParameter = parametersAlreadyRun(:,nonParallelParIndex) == fullParamList(1, nonParallelParIndex);
                                        alreadyRunFilter = alreadyRunFilter + runsWithParameter;
                                    end
                                    alreadyRunFilter = alreadyRunFilter == 6;
                                    possibleAlreadyRun = parametersAlreadyRun(alreadyRunFilter,:);
                                    for paramSetNumber = 1:size(fullParamList,1)
                                        p = fullParamList(paramSetNumber,:);
                                        for alreadyIndex = 1:size(possibleAlreadyRun,1)
                                            if possibleAlreadyRun(alreadyIndex,:) == p
                                                % Replication found,
                                                % decrease # of runs
                                                indexesToBeRun(paramSetNumber) = indexesToBeRun(paramSetNumber) - 1;
                                            end
                                        end
                                    end
                                end

                                % Assemble the final parameter list
                                % with one row per run.
                                finalParameterList = [];
                                for paramSetNumber = 1:size(fullParamList,1)
                                    if indexesToBeRun(paramSetNumber) > 0
                                        for currentReplication = 1:indexesToBeRun(paramSetNumber)
                                            finalParameterList = [finalParameterList; fullParamList(paramSetNumber,:)];
                                        end
                                    end
                                end

                                % Add the found parameters to the
                                % ULTIMATE LIST.
                                ultimateParameterList = [ultimateParameterList; finalParameterList];
                            end
                        end
                    end
                end
            end
        end
    end
end




if size(ultimateParameterList,1) < 60
    for i = 1:size(ultimateParameterList, 1)
        fprintf(['\n' num2str(ultimateParameterList(i, :))]);
    end
    fprintf(['\n\n' num2str(size(ultimateParameterList,1)) ' Runs Needed.\n']);
else
    fprintf(['\n' num2str(size(ultimateParameterList,1)) ' Runs Needed.\n']);
end

return;

end

function [] = runSshJobsParallel_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));

    %scrape the radio button values to determine indices
    lineParam = zeros(8,1);
    for i = 1:8
        lineParam(i) = get(S.lineRadio(i), 'Value');
    end
    axisParam = zeros(8,1);
    for i = 1:8
        axisParam(i) = get(S.axisRadio(i), 'Value');
    end
    lineParam = find(lineParam);
    axisParam = find(axisParam);

    % Ignore check boxes for params that define lines and axes
    plotConditions(lineParam, :) = [1 1 1 1 1];
    plotConditions(axisParam, :) = [1 1 1 1 1];

    parameterList = missingRuns_call('', '', S, parametersAlreadyRun);
    
    % Now, SSH into the machine and run the parallel function
%    addpath('/Users/wbstclair/Dropbox/Research/matlab/sshfrommatlab_13b')
%    addpath('/Users/wbstclair/Dropbox/Research/matlab/sshfrommatlab_13b/ganymed-ssh2-build250')

    % Change everything to be flexible to the number of machines.
    numMachines = 4;
%    machineNames{1} = 'stubb';
%     machineNames{2} = 'tashtego';
%     machineNames{3} = 'starbuck';
%     machineNames{4} = 'queequeg';
%     machineNames{5} = 'daggoo';
    machineNames{1} = 'starbuck';
    machineNames{2} = 'queequeg';
    machineNames{3} = 'stubb';
    machineNames{4} = 'tashtego';
    machineNames{5} = 'daggoo';



    % machine order (max 5):
    % stubb
    % tashtego
    % starbuck
    % queequeg
    % daggoo
    machineParameters = cell(numMachines,1);

    if size(parameterList,1) > 8
        runsPerMachine = floor(size(parameterList,1)/numMachines);
        for machineNum = 1:numMachines
            if machineNum == numMachines
                % last machine gets the extra runs
                tempIndexes = ((machineNum - 1)*runsPerMachine+1):size(parameterList,1);
            else
                tempIndexes = ((machineNum - 1)*runsPerMachine+1):(runsPerMachine*machineNum);
            end
            machineParameters{machineNum} = parameterList(tempIndexes,:);
        end
    else
        machineParameters{1} = parameterList;
    end
    
    for machineNum = 1:numMachines
        if ~isempty(machineParameters{machineNum})
            initiateNetworkRuns(machineParameters{machineNum}, machineNames{machineNum});
        end
    end
    
    
    fprintf('\nAll jobs sent.\n');

end

function [] = initiateNetworkRuns(parameterList, computerName)
    
    if strcmp(computerName, 'starbuck')
        accountName = 'wbs';
    else
        accountName = computerName;
    end
    
    prevPath = pwd;    

    sourcePath = '//Users/wbstclair/Desktop/complete_cluster_data/';
    destinationPath = 'Desktop/cluster_code_v2.3/';
    
    fileName = ['parametersSentTo_' computerName];
    cd(sourcePath);
    save(fileName, 'parameterList');
    cd(prevPath);
    fileName = [fileName '.mat'];
    system(['sh //Users/wbstclair/Desktop/sendParamFile.sh ' computerName ' ' accountName ' ' fileName ' ' sourcePath ' ' destinationPath]);

    fprintf(['\n Parameters sent to ' computerName '... \n'])
    
    % This code can be modified to inject new method versions to be run on
    % the machines. NOTE: Changing this makes data new in kind. Only use it
    % when starting a fresh data path, as there will be no way to
    % distinguish between data created from different method versions.
    codeFileName = 'networkEvaluate.m';
    sourcePath = '//Users/wbstclair/Dropbox/Research/matlab/';
    % destinationPath is left unchanged, because it's going to the same place.
%    completeFileName = '//Users/wbstclair/Dropbox/Research/matlab/networkEvaluate.m';
    system(['sh //Users/wbstclair/Desktop/sendParamFile.sh ' computerName ' ' accountName ' ' codeFileName ' ' sourcePath ' ' destinationPath]);
    % Needs to rehash once new networkEvaluate is sent. Rehash done in
    % stuff (below)
    
    %//Users/wbstclair/Dropbox/Research/matlab/parallelNetEval.m
    codeFileName = 'parallelNetEval.m';
    system(['sh //Users/wbstclair/Desktop/sendParamFile.sh ' computerName ' ' accountName ' ' codeFileName ' ' sourcePath ' ' destinationPath]);

    fprintf(['\n New code sent to ' computerName '... \n'])


    % This will initiate the ssh connection.
    matlabChannel = sshfrommatlab_publickey_file(accountName, [computerName '.ccnl.ucmerced.edu'], '//Users/wbstclair/.ssh/wbs','');
    
    fprintf(['\n Connected to ssh on ' computerName '... \n'])

    % Rename the sent code (in case the file was sent using a different
    % name
%    sshfrommatlabissue(matlabChannel,['cd Desktop/cluster_code_v2.3; mv ' codedFileName ' ' actualName]);    
    
    %Clear the quick_run folder...
    sshfrommatlabissue(matlabChannel,'cd Desktop/cluster_code_v2.3/run_on_demand; rm -r quick_run; mkdir quick_run');
    % Load parameter file.
    sshfrommatlabissue(matlabChannel,['screen -DRR matlabSession -X stuff "load(''' fileName ''')"; screen -DRR matlabSession -X stuff $(echo -ne ''\015'')']);     
    
    %Initiate Runs. rehash done in case new code was injected above.
    parallelCommand = ['rehash; parallelNetEval(parameterList, NaN, 64, ''run_on_demand/quick_run'', ' num2str(stimulationKind) ', ''' saveTag ''')'];
    % sshMatlabPsuedoExecute(matlabChannel,['screen -DRR matlabSession -X stuff "' parallelCommand '"; screen -DRR matlabSession -X stuff $(echo -ne ''\015'')']);
    sshfrommatlabissue(matlabChannel,['screen -DRR matlabSession -X stuff "' parallelCommand '"; screen -DRR matlabSession -X stuff $(echo -ne ''\015'')']);
    
    fprintf([num2str(size(parameterList,1)) ' jobs are running on ' computerName '!\n'])
    
    sshfrommatlabclose(matlabChannel);
end

function addNewRuns()
    prevPath = pwd;
    % I have modified this to be poisson_data and merged_data
%    quickPath = '//Users/wbstclair/Desktop/complete_cluster_data/cluster_analysis/quick_run';
    mergedDataPath = ['//Users/wbstclair/Desktop/complete_cluster_data/' dataPath];
    cd(mergedDataPath);
    cd ..
    cd quick_run
    fprintf('\nChecking for new data... ');
    fileList = what;
    if numel(fileList.mat) > 0
        cd ..
        % Integrate the quick_run data into the merged_data
        system('ditto quick_run merged_data');
        system('rm -r quick_run');
        system('mkdir quick_run');

        fprintf([num2str(numel(fileList.mat)) ' new files moved.\n']);
        cd(prevPath);
%        save('parametersAlreadyRun','parametersAlreadyRun','fileNames');
        hasBeenUpdated = true;
        reloadRuns();
    else
        fprintf('\n Folder empty! Nothing has been changed.\n');
    end

    cd(prevPath)
end

function reloadRuns()
    % This reloads parameter lists from the dataPath and saves them.
    prevPath = pwd;
    cd(dataPath);
    fprintf('\nReloading parameters manually... ');
    fileList = what;
    parametersAlreadyRun = zeros(numel(fileList.mat),8);
    fileNames = cell(numel(fileList.mat),1);
    for fileNumber = 1:numel(fileList.mat)
        load(fileList.mat{fileNumber}, 'parameters');
        parametersAlreadyRun(fileNumber,:) = parameters;
        fileNames{fileNumber} = fileList.mat{fileNumber};
    end
    clear fileNumber
    fprintf([num2str(size(parametersAlreadyRun,1)) ' files loaded.\n']);
    cd(prevPath);
    save(['parametersAlreadyRun_' saveTag],'parametersAlreadyRun','fileNames');
end

function scrapeData_call(varargin)
    
    % This is flexible for the number of available machines.
    % The order implies priority, {5} will only be used when there are 5
    % machines available.
    numMachines = 4;
    machineNames{1} = 'starbuck';
    machineNames{2} = 'queequeg';
    machineNames{3} = 'stubb';
    machineNames{4} = 'tashtego';
    machineNames{5} = 'daggoo';
        
    for machineNum = 1:numMachines
%        system('sh //Users/wbstclair/Desktop/campus_data_pull_stubb.sh');
        computerName = machineNames{machineNum};
        if strcmp(computerName, 'starbuck')
            accountName = 'wbs';
        else
            accountName = computerName;
        end
        zipFileName = 'tempZip';
        system(['sh //Users/wbstclair/Desktop/campus_data_pull.sh ' computerName ' ' accountName ' ' zipFileName ' ' dataPath]);
        addNewRuns();
    end

end

function validConditions = generateRunFilter()
        % The purpose of this function is apply the filters implied by the
        % GUI in a way agnostic of the plotting function. This way,
        % modifications of the filter itself apply uniformly across all
        % plotting functions.

    minTime = str2double(get(S.edTimeRange1,'string'));
    maxTime = str2double(get(S.edTimeRange2,'string'));
    totalTime = maxTime - minTime + 1;
    minSpikeCount = str2double(get(S.edSpikeRange1,'string'));
    maxSpikeCount = str2double(get(S.edSpikeRange2,'string'));
    maxHistVal =  str2double(get(S.edHistMax,'string'));
    useHistVal = get(S.useHistMax,'Value');
    useHistSpectra = get(S.useHistSpectra,'Value');
    minHistSpectra = str2double(get(S.edHistSpectraMin,'string'));
    maxHistSpectra = str2double(get(S.edHistSpectraMax,'string'));
%    useShiftSpeed = get(S.useShiftSpeed,'Value');
%    shiftSpeedMin = str2double(get(S.edShiftSpeedMin,'string'));
%    shiftSpeedMax = str2double(get(S.edShiftSpeedMax,'string'));
    useISIcount = get(S.useISIcount,'Value');
    minISIcount = str2double(get(S.edisiCountMin, 'string'));
    
    if useHistVal
        withinHistRange = zeros(length(parametersAlreadyRun),1);
        % Load the histogram data to find maximum hist value in the time
        % window. We will Load as a matfile, which allows us to only load part
        % of the file.
    %    histData = matfile('spikeHistogramData.mat');
%        load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat', 'histogramMaximums');
        load(['histogramMetrics_' saveTag '.mat'], 'histogramMaximums');
        withinHistRange = histogramMaximums < maxHistVal;
    else
        withinHistRange = ones(length(parametersAlreadyRun),1);
    end


    if useHistSpectra
        withinHistSpectraRange = zeros(length(parametersAlreadyRun),1);
        % Load the histogram data to find maximum hist value in the time
        % window. We will Load as a matfile, which allows us to only load part
        % of the file.
    %    histData = matfile('spikeHistogramData.mat');
        load(['histogramMetrics_' saveTag '.mat'], 'histSpectraMetric');

%        load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat', 'histSpectraMetric');
        % Multiply by -1 to fit expectations, since the order of the difference
        % was reverse from its initial calculation.
        %histSpectraMetric = -1.*histSpectraMetric;
        % I reversed the subtraction in the histSpectraMetric calculation.
        % So it should it be required to multiply by -1
        withinHistSpectraRange = (histSpectraMetric < maxHistSpectra) & (minHistSpectra < histSpectraMetric);
    else
        withinHistSpectraRange = ones(length(parametersAlreadyRun),1);
    end
    
    useShiftSpeed = 0; % Overriding since old data set problems
    if useShiftSpeed
        withinShiftSpeedRange = zeros(length(parametersAlreadyRun),1);
        % Load the histogram data to find maximum hist value in the time
        % window. We will Load as a matfile, which allows us to only load part
        % of the file.
    %    histData = matfile('spikeHistogramData.mat');
        fprintf('\n WARNING: Using shift speed!!! this is only used by the old data set...\n')
        load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat', 'histMaxShiftSpeed');

        withinShiftSpeedRange = (histMaxShiftSpeed < shiftSpeedMax) & (shiftSpeedMin <= histMaxShiftSpeed);
    else
        withinShiftSpeedRange = ones(length(parametersAlreadyRun),1);
    end
    
    if useISIcount
        withinISIcountRange = zeros(length(parametersAlreadyRun),1);
        load(['isiMetrics_' saveTag '.mat'], 'isiCounts');
        %load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','isiCounts');
        withinISIcountRange = isiCounts >= minISIcount;
    else
        withinISIcountRange = ones(length(parametersAlreadyRun),1);
    end
    

    %save('histogramMaximums_26-475ms.mat','histogramMaximums');



    %load relevant spikeCount data. 
    %load(spikeCountDataPath, 'spikeCount');
    % ^ This was commented out because of load regime change

    %load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat','summedHistograms');
    load(['histogramMetrics_' saveTag '.mat'], 'spikeCount');


    % Determine indexes of data within the spike count range.
    validSpikeCounts = (spikeCount > minSpikeCount & spikeCount < maxSpikeCount);


    validConditions = validSpikeCounts & withinHistRange & withinHistSpectraRange & withinShiftSpeedRange & withinISIcountRange;
        return
end

function computeMetrics_call(varargin)
   % This function will compute the necessary spike metrics needed to plot
   % the data using this visualizer. 
    tic
    minTime = str2double(get(S.edTimeRange1,'string'));
    maxTime = str2double(get(S.edTimeRange2,'string'));
    totalTime = maxTime - minTime + 1;
    maxISI = str2double(get(S.edMaxISI,'string'));
    falseTest = 0;
    if falseTest
   % First: Create the spike histograms for each run
    fprintf('\nComputing spike histograms...\n')
    numClusters = 6;
    totalTime = maxTime-minTime+1;
    completeSpikeHistogram = cell(size(parametersAlreadyRun,1),1);
    spikeCount = zeros(size(parametersAlreadyRun,1),1);
    for pNum = 1:size(parametersAlreadyRun,1)
        load([dataPath fileNames{pNum}], 'spikeData');
        spikeCount(pNum) = nnz(spikeData(:,3)>1);
        %spikeData = spikeData(spikeData(:,3) > 1,1);
        totalSpikeHistogram = zeros(numClusters,totalTime);
        for nucNumber = 1:numClusters
            % Extract spikes from the relevant nuclei.
            clusterData = spikeData(spikeData(:,3) == nucNumber,1);
            clusterHistogram = hist(clusterData,1:totalTime);
            totalSpikeHistogram(nucNumber,:) = clusterHistogram;
        end
        completeSpikeHistogram{pNum} = totalSpikeHistogram;
        if pNum == round(length(parametersAlreadyRun)/2)
            timeRemaining = toc/40*(size(parametersAlreadyRun,1)-40)/60;
            fprintf(['...' num2str(timeRemaining) ' minutes remaining...\n'])
        end
    end

    save(['completeSpikeHistogram_' saveTag],'completeSpikeHistogram');
    fprintf('Computing binned histograms...\n')
    
    % Second: compute the binned histogram

    binnedHistogram = cell(size(parametersAlreadyRun,1),1);
    newTime = toc;
    for pNum = 1:length(parametersAlreadyRun)
        particularHist = completeSpikeHistogram{pNum};
        % Take the 1ms bucket histogram and convert to a 10ms moving bucket,
        % centered around the point. If the point is on the edge, exclude
        % those points from the count.
        bucketSize = 10; %must be divisible by 2
        moreParticularHist = zeros(6,length(particularHist));
        for t = 1:1000
            timeIndexes = (t-bucketSize/2):(t+bucketSize/2);
            timeIndexes = timeIndexes(timeIndexes > 0 & timeIndexes <= 1000);  
            moreParticularHist(:,t) = sum(particularHist(:,timeIndexes),2);
        end
        binnedHistogram{pNum} = moreParticularHist;
        if pNum == 40
            timeRemaining = (toc-newTime)/40*(size(parametersAlreadyRun,1)-40)/60;
            fprintf(['...' num2str(timeRemaining) ' minutes remaining...\n'])
        end
    end
    save(['binnedHistogram_' saveTag],'binnedHistogram');
    fprintf(['\n Finished in ' num2str(toc/60) ' minutes.\n'])
    fprintf('Computing histogram metrics...\n')

    % Third: compute metrics that are dependent on the binnedHistogram.
    
    histogramMaximums = zeros(length(parametersAlreadyRun),1);
    summedHistograms = zeros(length(parametersAlreadyRun),1);
    histogramVariances = zeros(length(parametersAlreadyRun),1);
    histogramVariancesNZ = zeros(length(parametersAlreadyRun),1);
    histogramNNZ = zeros(length(parametersAlreadyRun),1);
    histogramMedians = zeros(length(parametersAlreadyRun),1);
    histSpectraMetric = zeros(length(parametersAlreadyRun),1);
    histMaxTimes = zeros(length(parametersAlreadyRun),1);
    newTime = toc;
    for pNum = 1:length(parametersAlreadyRun)
        moreParticularHist = binnedHistogram{pNum};
        histogramMaximums(pNum) = max(max(moreParticularHist(2:6,minTime:maxTime)));
        summedHistograms(pNum) = sum(sum(moreParticularHist(2:6,minTime:maxTime)));
        histMaxTimes(pNum) = find(histogramMaximums(pNum) == max(moreParticularHist(2:6,minTime:maxTime)),1);
        % The data needs to be transposed because there is no way to select
        % a dimension on the variance function var, and the computations are not equivalent.
        subsection = moreParticularHist(2:6,minTime:maxTime);
        histogramVariances(pNum) = mean(var(transpose(subsection)));
        if nnz(subsection) > 0
%            nonzeroCases = subsection > 0;
            nonzeroVariances = zeros(5,1);
            for i = 1:5
                if nnz(subsection(i,:)>0) > 1
                    nonzeroVariances(i) = var(subsection(i,subsection(i,:)>0));
                end
            end
            histogramVariancesNZ(pNum) = mean(nonzeroVariances);
        end
        histogramMedians(pNum) = mean(median(subsection,2));
        histogramNNZ(pNum) = nnz(subsection);
 
        specificHistogram = moreParticularHist(:,minTime:maxTime);
        driveSpectra = abs(fft(specificHistogram(1,:)));
        avgNucSpectra = 0;
        for nucNum = 2:6
            nucSpectra = abs(fft(specificHistogram(nucNum,:)));
            avgNucSpectra = avgNucSpectra + sum(nucSpectra(2:11));
        end
        avgNucSpectra = avgNucSpectra/5;
        histSpectraMetric(pNum) = avgNucSpectra - sum(driveSpectra(2:11));
        
        if pNum == 40
            timeRemaining = (toc-newTime)/40*(size(parametersAlreadyRun,1)-40)/60;
            fprintf(['...' num2str(timeRemaining) ' minutes remaining...\n'])
        end
    end

    save(['histogramMetrics_' saveTag], ...
        'histogramMaximums', 'summedHistograms', 'histogramVariances', ...
        'histogramVariancesNZ','histogramNNZ','histogramMedians', ...
        'histSpectraMetric','spikeCount', 'histMaxTimes');
    fprintf(['\n Finished in ' num2str((toc-newTime)/60) ' minutes.\n'])
    
end
    fprintf('Computing ISI metrics...\n')
    
    % Fourth: compute ISI metrics.
    isiMeans = zeros(length(parametersAlreadyRun),1);
    isiStds = zeros(length(parametersAlreadyRun),1);
    isiCounts = zeros(length(parametersAlreadyRun),1);
    isiMeansStds = zeros(length(parametersAlreadyRun),1);
    isiStdsStds = zeros(length(parametersAlreadyRun),1);
    driverISImeans = zeros(length(parametersAlreadyRun),1);
    driverISIstds = zeros(length(parametersAlreadyRun),1);
    driverISIcounts = zeros(length(parametersAlreadyRun),1);
    driverISImeansStds = zeros(length(parametersAlreadyRun),1);
    driverISIstdsStds = zeros(length(parametersAlreadyRun),1);
    spuriousSpikeCounts = zeros(length(parametersAlreadyRun),1);
    spuriousNeuronCounts = zeros(length(parametersAlreadyRun),1);
	newTime = toc;  
    for pNum = 1:length(parametersAlreadyRun)
        load([dataPath fileNames{pNum}], 'spikeData');
        spikeData = spikeData(spikeData(:,1) > minTime & spikeData(:,1) < maxTime,:);
        % Compute the ISI mean per neuron and standard deviation with no
        % maximum ISI value and without returning neuron information
        ISIs = clusterSpikes2isi(spikeData, maxISI, 0);
        % ISIs is a matrix with each column as such:
        % nucleiNumber neuronNumber mean(trimmedISIs) std(trimmedISIs)

        drivenISIs = ISIs(ISIs(:,1) > 1,:);
        % This counts how many spikes are missing given the ISI, with tol
        tolerance = 0.30;
        spikesMissing = (tolerance*totalTime)./drivenISIs(:,3) - drivenISIs(:,5);
%         testA_Mean{pNum} = drivenISIs(:,3);
%         testA_count{pNum} = drivenISIs(:,5);
        sufficientData = spikesMissing <= 0;        
        spuriousSpikeCounts(pNum) = sum(drivenISIs(~sufficientData,5));
        spuriousNeuronCounts(pNum) = nnz(~sufficientData);
        isiMeans(pNum) = mean(drivenISIs(sufficientData,3));
        isiStds(pNum) = mean(drivenISIs(sufficientData,4));
        isiCounts(pNum) = sum(drivenISIs(sufficientData,5));
        isiMeansStds(pNum) = std(drivenISIs(sufficientData,3));
        isiStdsStds(pNum) = std(drivenISIs(sufficientData,4));
        driverISIs = ISIs(ISIs(:,1) == 1,:);
        driverISImeans(pNum) = mean(driverISIs(:,3));
        driverISIstds(pNum) = mean(driverISIs(:,4));
        driverISIcounts(pNum) = sum(driverISIs(:,5));
        driverISImeansStds(pNum) = std(driverISIs(:,3));
        driverISIstdsStds(pNum) = std(driverISIs(:,4));
        if pNum == round((length(parametersAlreadyRun)/2))
            timeRemaining = (toc-newTime)/40*(size(parametersAlreadyRun,1)-40)/60;
            fprintf(['...' num2str(timeRemaining) ' minutes remaining...\n'])
        end
    end
    
    save(['isiMetrics_' saveTag], ...
        'isiMeans', 'isiStds', 'isiCounts', 'driverISImeans', ...
        'driverISIstds','driverISIcounts','isiMeansStds','isiStdsStds', ...
        'driverISImeansStds','driverISIstdsStds', 'spuriousSpikeCounts', 'spuriousNeuronCounts');
    fprintf(['\n Finished in ' num2str((toc-newTime)/60) ' minutes.\n'])
    fprintf(['All metrics computed and saved in ' num2str(toc/60) ' minutes.\n'])
end


% This is antiquated, would need updating to function.
% Has functionally replaced with distributing the jobs to the network.
% This would run the jobs locally, which takes foreeevvveerrrr
function [ultimateParameterList] = runMissingData_call(varargin)
    % this function will call networkEvaluate for the current parameter
    % condition.
S = varargin{3};
parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
plotConditions(lineParam, :) = [1 1 1 1 1];
plotConditions(axisParam, :) = [1 1 1 1 1];

ultimateParameterList = missingRuns_call('', '', S, parametersAlreadyRun);


batchSize = size(ultimateParameterList, 1);
parallelData = cell(batchSize,1);
parallelParameters = cell(batchSize,1);


% This can be a parfor!
for paramSetNumber = 1:batchSize
    p = ultimateParameterList(paramSetNumber, :);
    % Omitting timeThreshold
%     parallelData{paramSetNumber} = networkEvaluate(...
%         p(1), p(2), p(3), p(4), p(5), p(6), p(7), p(8), ...
%         rand(200,1), timeThreshold);
    parallelData{paramSetNumber} = networkEvaluate(...
        p(1), p(2), p(3), p(4), p(5), p(6), p(7), p(8), ...
        rand(200,1));
    parallelParameters{paramSetNumber} = p;
end

expRunNum = 0;
expId = datestr(now,30);

% Only attempt to save data that
% exists. Here, we choose indexes that
% actually contained data.
availData = [];
for dataNum = 1:size(parallelData, 1)
    if ~isempty(parallelData{dataNum})
        availData = [availData dataNum];
    end
end

prevPath = pwd;
% Save the data in different files!
for dataNum = availData
    expRunNum = expRunNum + 1;
    spikeData = parallelData{dataNum};
    parameters = parallelParameters{dataNum};
    % Only save if the data is
    % complete. If it is greater
    % than the timeThreshold, then
    % the run ended early.

    cd(dataPath)
    savePath = 'dataScrape/quick_run/';
    save([savePath expId ...
        '_' num2str(expRunNum)], ...
        'spikeData', 'parameters');
    cd(dataPath)

end

prevPath = pwd;
cd(dataPath);
fileList = what;
cd(prevPath);
if numel(fileList.mat) > size(parametersAlreadyRun,1)
    [parametersAlreadyRun, fileNames] = addNewRuns('','',parametersAlreadyRun, fileNames, dataPath);
end


return;

end


% ######  Visualization functions.

% Works. 
function [] = plotSingleSpikes_call(varargin)
    % this function will only plot a single parameter condition.
S = varargin{3};
plotConditions = str2num(get(S.plotConditions, 'string'));

% Go through check boxes and use only the leftmost condition.

% To have index values that correspond to the correct parameter.
chosenParameters = zeros(1,8);
for parIndex = 1:8
    for valIndex = 1:5
        chosenConditions = find(plotConditions(parIndex,:));
        chosenParameters(parIndex) = parameterRanges(parIndex,chosenConditions(1));
    end
end

% Now that we know which parameter condition to find, we can find it
for fileNumber = 1:numel(fileNames)
    if parametersAlreadyRun(fileNumber,:) == chosenParameters
        load([dataPath fileNames{fileNumber}], 'spikeData');
        break
    end
end





figure;

% Plot the clusters.
for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(spikeData(spikeData(:,3) == plotNumber,1), ...
     spikeData(spikeData(:,3) == plotNumber,2), '.', 'MarkerSize',5);
end

end

% Works. 
function [] = plotAllSpikes_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

validConditions = generateRunFilter();

 minTime = str2double(get(S.edTimeRange1,'string'));
 maxTime = str2double(get(S.edTimeRange2,'string'));
 totalTime = maxTime - minTime + 1;
 

%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
%axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
%plotConditions(lineParam, :) = [1 1 1 1 1];
%plotConditions(axisParam, :) = [1 1 1 1 1];



% load centrality data.
%load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.

f=figure;
hold on
numColors = 5;
colorRange = copper(numColors);

numPlotted = 0;


validIndexes = find(validConditions);

plottedConditions = zeros(size(parameterRanges));

for validNumber = 1:length(validIndexes)
    paramNumber = validIndexes(validNumber);
    shouldPlot = 1;
        % If parameter is of interest, plot it!
        for pNum = 1:8
            % This should only be one comparison per if
            if plotConditions(pNum,(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:))) ~= 1
                shouldPlot = 0;
                break;
            end
        end
        if shouldPlot
            for pNum = 1:8
                pIndex = find(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:));
                plottedConditions(pNum,pIndex) = plottedConditions(pNum,pIndex) + 1;
            end

            load([dataPath fileNames{paramNumber}], 'spikeData');
            spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
            
            dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
            figure(f);
            for plotNumber = 1:6
                subplot(3,2,plotNumber);
                if plotNumber == 1
                    axis([0 totalTime 0 200]);
                else
                   axis([0 totalTime 0 250]);
                end
                 hold on
                plot(spikeData(spikeData(:,3) == plotNumber,1), ...
                spikeData(spikeData(:,3) == plotNumber,2), '.','Color',dotColor, 'markers', 2);
            end
            if ~isempty(spikeData)
                numPlotted = numPlotted + 1;
            end

            hold on
    %        drawnow;
        end
end


fprintf(['\n Spike Plot Complete! \n The number of runs plotted was: ' num2str(numPlotted) '\n']);
for i = 1:8
    fprintf([num2str(plottedConditions(i,:)) '\n']);
end



%plotNotInitiated = 1;

%colorRange =  ['r' 'g' 'b' 'm' 'k'];


%annotation('textbox', [.85, .1, .1, .24], 'String', num2str(plotConditions));

end


% Works. Super plotter.
function [] = plotSingleDerivatives_call(varargin)
    % this function will only plot a single parameter condition.
S = varargin{3};
plotConditions = str2num(get(S.plotConditions, 'string'));

minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));


% Go through check boxes and use only the leftmost condition.

% To have index values that correspond to the correct parameter.
chosenParameters = zeros(1,8);
for parIndex = 1:8
    for valIndex = 1:5
        chosenConditions = find(plotConditions(parIndex,:));
        chosenParameters(parIndex) = parameterRanges(parIndex,chosenConditions(1));
    end
end
% Now that we know which parameter condition to find, we need to go through
% the runs and find it.


%Since we can't load all of the data into RAM at once, we must load the
%subset of data we will need. Since the different data run on different
%computers was divided precisely by the first parameter, we can use that
%parameter to determine which data to load.


for fileNumber = 1:numel(fileNames)
    if parametersAlreadyRun(fileNumber,:) == chosenParameters
        load([dataPath fileNames{fileNumber}], 'spikeData');
        break; % once data has been loaded, stop search
    end
end


%minTime = 26;
%maxTime = 475;
totalTime = maxTime-minTime+1;
% Trim out irrele
spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);

% First, build the original histogram:
spikeHistogram = zeros(6, totalTime); 
for nucNumber = 1:6
    nucSpikeData = spikeData(spikeData(:,3) == nucNumber,1);
    spikeHistogram(nucNumber,:) = hist(nucSpikeData,totalTime);
end

% Convert the spikeData into a binned histogram.
% Then, compute the first and second derivatives. Then plot them.

% Now, build binned histogram:
binnedHistogram = zeros(6, totalTime); 

 % Take the 1ms bucket histogram and convert to a 10ms moving bucket,
 % centered around the point. If the point is on the edge, exclude
 % those points from the count.
bucketSize = 10; %must be divisible by 2
moreParticularHist = zeros(6,length(spikeHistogram));
accOfSpikes = zeros(6,length(spikeHistogram));

for t = 1:totalTime
    timeIndexes = (t-bucketSize/2):(t+bucketSize/2);
    timeIndexes = timeIndexes(timeIndexes > 0 & timeIndexes <= totalTime); 
    moreParticularHist(:,t) = sum(spikeHistogram(:,timeIndexes),2);
end
binnedHistogram = moreParticularHist;

% Now, build derivatives:
histDiff = zeros(size(moreParticularHist));
histDiff(:,2:end) = moreParticularHist(:,1:(end-1));
histogramDerivatives = moreParticularHist - histDiff;
histDiff2 = zeros(size(histDiff));
histDiff2(:,2:end) = histDiff(:,1:(end-1));
histogramDerivatives2nd = histDiff - histDiff2;
%         subsection = moreParticularHist(2:6,minTime:maxTime);
%         histogramNNZ(pNum) = nnz(subsection);


for t = 1:totalTime
    accOfSpikes(:,t) = sum(moreParticularHist(:,1:t),2);
end


% Now, the data has been constructed... so plot it!


% Make 4 plots: the spike raster, the histogram data, 1st and 2nd
% derivatives

f1 = figure;

if length(spikeData) > 100000
    mSize = 1;
else
    mSize = 5;
end

%plotNotInitiated = 1;

%colorRange =  ['r' 'g' 'b' 'm' 'k'];

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(spikeData(spikeData(:,3) == plotNumber,1), ...
     spikeData(spikeData(:,3) == plotNumber,2), '.', 'MarkerSize',mSize,'Color','k');
    if plotNumber ~= 1
        axis([0 totalTime 0 240]);
    end
end
plotTitle = 'Spike Raster';
set(gcf,'NextPlot','add');
axes;
h = title(plotTitle);
set(gca,'Visible','off');
set(h,'Visible','on');

saveas(gcf,[subPath plotFolder num2str(fileNumber) '_sr_' saveTag '.png']);



f2 = figure;
x = minTime:maxTime;
yMax = binnedHistogram(2:6,:);
yMax = max(max(yMax));

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(x,binnedHistogram(plotNumber,:),'Color','k');
    if plotNumber ~= 1
        axis([0 totalTime 0 yMax]);
    end
end
plotTitle = 'Binned Histogram';
set(gcf,'NextPlot','add');
axes;
h = title(plotTitle);
set(gca,'Visible','off');
set(h,'Visible','on');
saveas(gcf,[subPath plotFolder num2str(fileNumber) '_bh_' saveTag '.png']);


f3 = figure;

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(x,histogramDerivatives(plotNumber,:));
end
plotTitle = '1st Derivatives';
set(gcf,'NextPlot','add');
axes;
h = title(plotTitle);
set(gca,'Visible','off');
set(h,'Visible','on');

f4 = figure;

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(x,histogramDerivatives2nd(plotNumber,:));
end
title('2nd Derivatives');

f5 = figure;

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    histFFT = abs(fft(binnedHistogram(plotNumber,:)));
    plot(histFFT,'Color','k');
    axis([0 ceil(totalTime/2) 0 max(histFFT(2:(end-1)))]);
%    [M I] = max(abs(fft(binnedHistogram(plotNumber,:))))
end
plotTitle = 'Spectra of Histogram';
set(gcf,'NextPlot','add');
axes;
h = title(plotTitle);
set(gca,'Visible','off');
set(h,'Visible','on');
saveas(gcf,[subPath plotFolder num2str(fileNumber) '_sh_' saveTag '.png']);

f6 = figure;

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    derFFT = abs(fft(histogramDerivatives(plotNumber,:)));
    plot(derFFT);
    axis([0 ceil(totalTime/2) 0 max(derFFT(2:(end-1)))]);
%    [M I] = max(abs(fft(binnedHistogram(plotNumber,:))))
end
title('Spectra of Derivatives');


f7 = figure;

for plotNumber = 1:6
    subplot(3,2,plotNumber);
    plot(x,accOfSpikes(plotNumber,:));
end
title('Histogram Accumulation');

fprintf(['\n fileNumber: ' num2str(fileNumber) '\n'])


%annotation('textbox', [.85, .1, .1, .24], 'String', num2str(plotConditions));




end


% Works
function [] = plotISIvariance_call(varargin)
    % This is being modified to only plot the ISIs, and not run all data.
    
S = varargin{3};
%plotVersion = varargin{4};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

%maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));

% This is edited out because the code does not currently handle
% replications. Though, it would be easy to modify to do so.
%numReplications = str2double(get(S.edNumRep,'string'));


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

%allplot

% Create all plots.
expId = datestr(now,30);

cd([subPath plotFolder]);
system(['mkdir ' expId '_' saveTag])
cd(prevPath);

switch stimulationKind
    case 1
        avoidParamLines = [1 8];
    case 2
        avoidParamLines = [1 7];
end

paramsToRun = ones(1,8);
for i = 1:length(avoidParamLines)
    paramsToRun(avoidParamLines(i)) = 0;
end
paramsToRun = find(paramsToRun);


for lineParam = paramsToRun
    for axisParam = paramsToRun

        if lineParam ~= axisParam
            specialPlotConditions = plotConditions;
            %allplot
% Ignore check boxes for params that define lines and axes
specialPlotConditions(lineParam, :) = [1 1 1 1 1];
specialPlotConditions(axisParam, :) = [1 1 1 1 1];

% 5 is the number of parameter settings for each parameter kind.
for i = 1:5
    for j = 1:5
        paramSpecificMeans{i,j} = [];
        paramSpecificStds{i,j} = [];
    end
end

load(['isiMetrics_' saveTag '.mat'], 'isiCounts', 'isiMeans','isiStds');
% load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','isiCounts');
% load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','isiMeans');
% load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','isiStds');


validConditions = generateRunFilter();
validIndexes = find(validConditions);
for validNumber = 1:length(validIndexes)
    paramNumber = validIndexes(validNumber);
    
    lineParamIndex = find(parameterRanges(lineParam,:) == parametersAlreadyRun(paramNumber,lineParam));
    axisParamIndex = find(parameterRanges(axisParam,:) == parametersAlreadyRun(paramNumber,axisParam));
    
    % Sort the statistic into the right bin.
    paramSpecificMeans{lineParamIndex,axisParamIndex} = [paramSpecificMeans{lineParamIndex,axisParamIndex}; ...
        isiMeans(paramNumber)];
    paramSpecificStds{lineParamIndex,axisParamIndex} = [paramSpecificStds{lineParamIndex,axisParamIndex}; ...
        isiStds(paramNumber)];
    
end

parameterRange = parameterRanges(axisParam, :);
f = figure;
hold on
set(gcf,'units','normalized','outerposition',[0 0 1 1])


%colorRange =  ['r' 'g' 'b' 'm' 'k'];
colorRange = hsv(5);

for lineNumber = 1:5
    
    % Cases with 0 conditions will be NaN in these vectors.
    % So, all code which uses them must be compatible with NaNs
    axisVectorMeans = ...
        [mean(paramSpecificMeans{lineNumber,1}) ...
        mean(paramSpecificMeans{lineNumber,2}) ...
        mean(paramSpecificMeans{lineNumber,3}) ...
        mean(paramSpecificMeans{lineNumber,4}) ...
        mean(paramSpecificMeans{lineNumber,5})];

    axisVectorStds = ...
        [std(paramSpecificMeans{lineNumber,1})/sqrt(length(paramSpecificMeans{lineNumber,1})) ...
        std(paramSpecificMeans{lineNumber,2})/sqrt(length(paramSpecificMeans{lineNumber,2})) ...
        std(paramSpecificMeans{lineNumber,3})/sqrt(length(paramSpecificMeans{lineNumber,3})) ...
        std(paramSpecificMeans{lineNumber,4})/sqrt(length(paramSpecificMeans{lineNumber,4})) ...
        std(paramSpecificMeans{lineNumber,5})/sqrt(length(paramSpecificMeans{lineNumber,5}))];

    subplot(1,2,1);    
    hold on
    
    %errorbar(parameterRange,axisVectorMeans,axisVectorStds, colorRange(lineNumber));
    errorbar(parameterRange,axisVectorMeans,axisVectorStds, 'Color',colorRange(lineNumber,:));

    axisVectorMeans = ...
        [mean(paramSpecificStds{lineNumber,1}) ...
        mean(paramSpecificStds{lineNumber,2}) ...
        mean(paramSpecificStds{lineNumber,3}) ...
        mean(paramSpecificStds{lineNumber,4}) ...
        mean(paramSpecificStds{lineNumber,5})];

    axisVectorStds = ...
        [std(paramSpecificStds{lineNumber,1})/sqrt(length(paramSpecificStds{lineNumber,1})) ...
        std(paramSpecificStds{lineNumber,2})/sqrt(length(paramSpecificStds{lineNumber,2})) ...
        std(paramSpecificStds{lineNumber,3})/sqrt(length(paramSpecificStds{lineNumber,3})) ...
        std(paramSpecificStds{lineNumber,4})/sqrt(length(paramSpecificStds{lineNumber,4})) ...
        std(paramSpecificStds{lineNumber,5})/sqrt(length(paramSpecificStds{lineNumber,5}))];
    
    subplot(1,2,2);
    hold on
    %errorbar(parameterRange,axisVectorMeans,axisVectorStds, colorRange(lineNumber));
    errorbar(parameterRange,axisVectorMeans,axisVectorStds, 'Color',colorRange(lineNumber,:));
end


subplot(1,2,1);
lineParameterRange = parameterRanges(lineParam, :);
legend('location', 'NorthEastOutside', ...
    num2str(lineParameterRange(1)), num2str(lineParameterRange(2)), ...
    num2str(lineParameterRange(3)), num2str(lineParameterRange(4)), ...
    num2str(lineParameterRange(5)));
xlabel(variableNames{axisParam});
ylabel('Mean of ISI averages');
%ylim([400 750]);
title(variableNames{lineParam});

subplot(1,2,2);
lineParameterRange = parameterRanges(lineParam, :);
legend('location', 'NorthEastOutside', ...
    num2str(lineParameterRange(1)), num2str(lineParameterRange(2)), ...
    num2str(lineParameterRange(3)), num2str(lineParameterRange(4)), ...
    num2str(lineParameterRange(5)));
xlabel(variableNames{axisParam});
ylabel('Mean of the ISI Standard Deviations');

%ylim([20 80]);
subplot(1,2,1);


%paramDistribution = runParamDistribution(validConditions);

%paramDistribution = paramDistribution .* specialPlotConditions;

%annotation('textbox', [.875, .1, .125, .15], 'String', num2str(paramDistribution), 'EdgeColor', 'none');


%allplot
saveas(f,[subPath plotFolder expId '_' saveTag '/' expId '_' saveTag '_' variableNames{axisParam} '_' variableNames{lineParam} '.png']);
close(f);
        end
    end
end
%allplot

end

% Works
function plottedConditions = runParamDistribution(filterLogical)
    % This counts the number of times a particular parameter occurs in the
    % filter logical.
        
        validIndexes = find(filterLogical);
        plottedConditions = zeros(8,5);

        for validNumber = 1:length(validIndexes)
            paramNumber = validIndexes(validNumber);

            for pNum = 1:8
                pIndex = find(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:));
                plottedConditions(pNum,pIndex) = plottedConditions(pNum,pIndex) + 1;
            end
        end
        return
end


% May work, needs testing. Uses filter.
function [] = ISIdistribution_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
plotConditions(lineParam, :) = [1 1 1 1 1];
plotConditions(axisParam, :) = [1 1 1 1 1];

f = figure;
hold on
%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);



maxY = 0;
         
figure(f);
hold on

validConditions = generateRunFilter();

validIndexes = find(validConditions);

for validNumber = 1:length(validIndexes)
    paramNumber = validIndexes(validNumber);

    shouldPlot = 1;
    % If parameter is of interest, plot it!
    for pNum = 1:8
        % This should only be one comparison per if
        if plotConditions(pNum,(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:))) ~= 1
            shouldPlot = 0;
            break;
        end
    end
    if shouldPlot

        load([dataPath fileNames{paramNumber}], 'spikeData');
        spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
        %calculate ISIs with no maximum ISI
        includeRawData = 1;
        ISIdata = clusterSpikes2isi(spikeData, maxISI,includeRawData);
%        meanOfSTDs = mean(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4));
%        STDofSTDs = std(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4))/sqrt(200);
        
        % Make 5 ksdensity plots, one for each "axis" parameter, where in
        % each the line parameter is separated by color.
        
        
        rawISIs = ISIdata{2};
        neuronInfo = ISIdata{3};
        nonStimData = neuronInfo(:,1) > 1;
%        rawISIs = rawISIs{neuronInfo(:,1) > 1};

        isiCompoundHists = zeros(1,maxISI);
        nonStimNumber = 0;
        for neuronNumber = 1:size(rawISIs,2)
            if nonStimData(neuronNumber)
                nonStimNumber = nonStimNumber + 1;
                binnedDistribution = zeros(1,maxISI);
                for isiNum = 1:length(rawISIs{neuronNumber})
                    binnedDistribution(rawISIs{neuronNumber}(isiNum)) = ...
                        binnedDistribution(rawISIs{neuronNumber}(isiNum)) + 1;
                end
%                binnedDistribution = hist(rawISIs{neuronNumber},maxISI);
 %               isiHists(nonStimNumber,:) = binnedDistribution;
                isiCompoundHists = isiCompoundHists + binnedDistribution;
            end
        end
%        isiCompoundHists = sum(isiHists, 2);
        
        
       
        
%         plotSize = plotSize + 1;
%         toBePlotted(plotSize,:) = [centPlotMean, meanOfSTDs,STDofSTDs, parameterRanges(lineParam,:) == parametersAlreadyRun(paramNumber,lineParam),centMarker];

        dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
%        errorbar(centPlotMean,meanOfSTDs,STDofSTDs,'Color',dotColor,'MarkerSize',0.1);
        % The axis parameter determines which plot to record data.
        plotNumber = find(parameterRanges(axisParam,:) == parametersAlreadyRun(paramNumber, axisParam));
        subplot(5,1,plotNumber);
        hold on
%             if plotNumber == 1
%                 axis([0 totalTime 0 200]);
%             else
%                axis([0 totalTime 0 250]);
%             end
        x = 1:maxISI;

            
%        y = fit(x, isiCompoundHists', 'cubicinterp');
        % remove less than zeros
%        y(y<0) = 0;
        plot(x,isiCompoundHists, 'Color', dotColor);
        drawnow;
        if max(isiCompoundHists) > maxY
            maxY = max(isiCompoundHists);
        end
%             plot(spikeData(spikeData(:,3) == plotNumber,1), ...
%             spikeData(spikeData(:,3) == plotNumber,2), '.','Color',dotColor, 'markers', 2);
    end
       
        
%        scatter(centPlotMean,meanOfSTDs,centMarker,dotColor);
%        scatter3(centPlotMean,meanOfSTDs,STDofSTDs,centMarker,dotColor,'filled');
        hold on
%        drawnow;
end


for i = 1:5
    subplot(5,1,i)
    axis([0 maxISI 0 maxY]);
end

fprintf('\n Finished ISI distribution plot. \n');


end



function metricLines_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    
    xMetricName = get(S.xMetric,{'string','val'});
    xMetricName = xMetricName{1}{xMetricName{2}};
    yMetricName = get(S.yMetric,{'string','val'});
    yMetricName = yMetricName{1}{yMetricName{2}};
    
    histMat = matfile(['histogramMetrics_' saveTag '.mat']);
    histInfo = whos(histMat);
    
    for i = 1:length(histInfo)
        if strcmp(xMetricName,getfield(histInfo,{i},'name'))
            xMetric = load(['histogramMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(histInfo,{i},'name'))
            yMetric = load(['histogramMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end
    
    isiMat = matfile(['isiMetrics_' saveTag '.mat']);
    isiInfo = whos(isiMat);
    
    for i = 1:length(isiInfo)
        if strcmp(xMetricName,getfield(isiInfo,{i},'name'))
            xMetric = load(['isiMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(isiInfo,{i},'name'))
            yMetric = load(['isiMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end    
    
    if ~exist('xMetric') %|| ~exist('yMetric') currently no y usage here
        fprintf('\n Metric(s) not found!\n');
        return
    end
    
    validConditions = generateRunFilter();

    
    paramLines = zeros(8,5);
    for p = 1:8
        for xVal = 1:5
            validRuns = parametersAlreadyRun(:,p) == parameterRanges(p,xVal);
            validRuns = validRuns & validConditions;
            if nnz(validRuns>0)
                nanBread = isnan(xMetric);
                validRuns = validRuns & ~nanBread;
                paramLines(p,xVal) = mean(xMetric(validRuns));
            end
        end
    end
    plotLines = ones(8,1);
    if stimulationKind == 1
        plotLines(1) = 0;
        plotLines(8) = 0;
    elseif stimulationKind == 2
        plotLines(1) = 0;
        plotLines(7) = 0;
    end        
        
    figure;plot(transpose(paramLines(logical(plotLines),:)));
    title(xMetricName);
end


% Should work. Uses filter and data method.
function metricVsMetricPlot_call(varargin)
    S = varargin{3};
    plotConditions = str2num(get(S.plotConditions, 'string'));
    
    xMetricName = get(S.xMetric,{'string','val'});
    xMetricName = xMetricName{1}{xMetricName{2}};
    yMetricName = get(S.yMetric,{'string','val'});
    yMetricName = yMetricName{1}{yMetricName{2}};
    
    histMat = matfile(['histogramMetrics_' saveTag '.mat']);
    histInfo = whos(histMat);
    
    for i = 1:length(histInfo)
        if strcmp(xMetricName,getfield(histInfo,{i},'name'))
            xMetric = load(['histogramMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(histInfo,{i},'name'))
            yMetric = load(['histogramMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end
    
    isiMat = matfile(['isiMetrics_' saveTag '.mat']);
    isiInfo = whos(isiMat);
    
    for i = 1:length(isiInfo)
        if strcmp(xMetricName,getfield(isiInfo,{i},'name'))
            xMetric = load(['isiMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(isiInfo,{i},'name'))
            yMetric = load(['isiMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end    
    
    if ~exist('xMetric') || ~exist('yMetric')
        fprintf('\n Metric(s) not found!\n');
        return
    end
    

    %scrape the radio button values to determine indices
    lineParam = zeros(8,1);
    for i = 1:8
        lineParam(i) = get(S.lineRadio(i), 'Value');
    end
    axisParam = zeros(8,1);
    for i = 1:8
        axisParam(i) = get(S.axisRadio(i), 'Value');
    end
    lineParam = find(lineParam);
    %axisParam = find(axisParam);    
    
    
    % load histogramMaximums and summedHistograms
 %   load(['histogramMetrics_' saveTag '.mat'], 'summedHistograms','histogramMaximums');

    % To create the whole plot, it only takes one line:
    %figure; plot(summedHistograms,histogramMaximums,'.', 'MarkerSize', 1)

    % However to create a color coded version, we need to go through parameters
    % and sort each condition by a different color.

    %assume parametersAlreadyRun and parameterRanges
    numColors = 5;
    colorRange = copper(numColors);
    mSize = 7;


    validConditions = generateRunFilter();

    % Trying to make it so plot conditions gets implemented here.
%     
%     for p = 1:8
%         parametersAlreadyRun(:,p) == parameterRanges(p,:)
%             if plotConditions(p,(parametersAlreadyRun(:,p)) == parameterRanges(pNum,:))) == 1
%                 
%             end
%     end

    
    %plotsToMake = [1:8];
    plotsToMake = lineParam;
    for p = plotsToMake
        metricMaxes = [0 0];
        figure;
        hold on
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        % split the 5 diff plots code from 2 plots code
        for pVal = 1:5
            subplot(2,3,pVal);
            hold on
            validRuns = parametersAlreadyRun(:,p) == parameterRanges(p,pVal);
            validRuns = validRuns & validConditions;
            dotColor = colorRange(pVal,:);
            dotColor = 'k';
            plot(xMetric(validRuns),yMetric(validRuns),'.','MarkerSize',mSize,'Color',dotColor);
            title([variableNames{p} ' = ' num2str(parameterRanges(p,pVal))]);
            if metricMaxes(1) < max(xMetric(validRuns))
                metricMaxes(1) = max(xMetric(validRuns));
            end
            if metricMaxes(2) < max(yMetric(validRuns))
                metricMaxes(2) = max(yMetric(validRuns));
            end
            xlabel(xMetricName);
            ylabel(yMetricName);
        end
        if nnz(metricMaxes) > 0
            xMin = 0; yMin = 0;
            if min(xMetric(validConditions)) < 0
                xMin = min(xMetric(validConditions));
            end
            if min(yMetric(validConditions)) < 0
                yMin = min(yMetric(validConditions));
            end
            padding = 1.05;
            plotAxis = [xMin-xMin*(padding-1), metricMaxes(1)*padding, yMin-yMin*(padding-1), metricMaxes(2)*padding];
            plotAxis = plotAxis .* 1.05;
            for pVal = 1:5
                subplot(2,3,pVal);
                axis(plotAxis);
            end
        end

         finalPlot = subplot(2,3,6);
         hold on

            for pVal = 1:5
                validRuns = parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal);
                validRuns = validRuns & validConditions;
                dotColor = colorRange(pVal,:);
                plot(xMetric(validRuns),yMetric(validRuns),'.','MarkerSize',mSize,'Color',dotColor);
    %            plot(xMetric(validRuns),yMetric(validRuns),'.','MarkerSize',mSize,'Color','k');
    %                    title(variableNames{p});
            end
         
         
         
%         plot(xMetric(validConditions),yMetric(validConditions),'.', 'MarkerSize', mSize,'Color','k')
         axis(plotAxis)
%         set(finalPlot,'Visible','off')
%         hold on
%         annotation('textbox', [.75, .1, .125, .25], 'String', num2str(runParamDistribution(validConditions)), 'EdgeColor', 'none');                
    end
    
    
    
%     
%             for p = 1:8
%                 figure;
%                 hold on
%                 set(gcf,'units','normalized','outerposition',[0 0 1 1])
%                 % split the 5 diff plots code from 2 plots code
%                 for pVal = 1:5
%                     subplot(2,3,pVal);
%                     hold on
%                     validRuns = parametersAlreadyRun(:,p) == parameterRanges(p,pVal);
%                     validRuns = validRuns & validConditions;
%                     dotColor = colorRange(pVal,:);
%                     plot(xMetric(validRuns),yMetric(validRuns),'.','MarkerSize',1,'Color',dotColor);
%         %            plot(xMetric(validRuns),yMetric(validRuns),'.','MarkerSize',1,'Color','k');
% %                    title(variableNames{p});
%                 end
%             end       
    
    %this puts a top-middle title for subplots... but it overlaps...
% plotTitle = [variableNames{lineParam} ' with ' stimulationNames{stimulationKind}];
% set(gcf,'NextPlot','add');
% axes;
% h = title(plotTitle);
% set(gca,'Visible','off');
% set(h,'Visible','on');
% 






end


function singleRunISIs_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;

% Go through check boxes and use only the leftmost condition.

% To have index values that correspond to the correct parameter.
chosenParameters = zeros(1,8);
for parIndex = 1:8
    for valIndex = 1:5
        chosenConditions = find(plotConditions(parIndex,:));
        chosenParameters(parIndex) = parameterRanges(parIndex,chosenConditions(1));
    end
end

% Now that we know which parameter condition to find, we can find it
for fileNumber = 1:numel(fileNames)
    if parametersAlreadyRun(fileNumber,:) == chosenParameters
        load([dataPath fileNames{fileNumber}], 'spikeData');
        break
    end
end


% %scrape the radio button values to determine indices
% lineParam = zeros(8,1);
% for i = 1:8
%     lineParam(i) = get(S.lineRadio(i), 'Value');
% end
% axisParam = zeros(8,1);
% for i = 1:8
%     axisParam(i) = get(S.axisRadio(i), 'Value');
% end
% lineParam = find(lineParam);
% axisParam = find(axisParam);
% 
% % Ignore check boxes for params that define lines and axes
% % For this function, there is no use to the line Param
% plotConditions(lineParam, :) = [1 1 1 1 1];
% plotConditions(axisParam, :) = [1 1 1 1 1];


%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);



maxY = 0;
         
spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
%calculate ISIs with no maximum ISI
includeRawData = 1;
ISIdata = clusterSpikes2isi(spikeData, maxISI,includeRawData);

%        meanOfSTDs = mean(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4));
%        STDofSTDs = std(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4))/sqrt(200);
        
        % Make 5 ksdensity plots, one for each "axis" parameter, where in
        % each the line parameter is separated by color.
        
ISIs = ISIdata{1};
% ISIs(currentDataIndex,:) = ...
% [nucleiNumber neuronNumber mean(trimmedISIs) std(trimmedISIs) length(trimmedISIs)];
%rawISIs = ISIdata{2};
neuronClusterNum = ISIs(:,1);
%nonStimData = neuronInfo(:,1) > 1;
%        rawISIs = rawISIs{neuronInfo(:,1) > 1};



figure;
for clusterNum = 1:6
    subplot(3,2,clusterNum)
    hold on
    clusterNeurons = neuronClusterNum == clusterNum;
    meansToPlot = ISIs(clusterNeurons,3);
    stdsToPlot = ISIs(clusterNeurons,4);
    neuronsToPlot = ISIs(clusterNeurons,2);
    inNeurons = neuronsToPlot > 200;
    %tempMeans = meansToPlot(~inNuerons);
    [~, newI] = sort(meansToPlot);
    badInhibLocations = neuronsToPlot(newI) > 200;
    if nnz(inNeurons) > 0
        newI = [newI(~badInhibLocations); find(inNeurons)];
    end
        
    errorbar(neuronsToPlot,meansToPlot(newI),stdsToPlot(newI),'ko');
    if max(meansToPlot+stdsToPlot)>maxY
        maxY = max(meansToPlot);
    end
end

for i = 1:6
    subplot(3,2,i)
    axis([0 240 0 maxY]);
end

fprintf('\n Finished ISI distribution plot. \n');
    
    
end



function visualizeISI_call(varargin)
    % This visualization focuses on averaging all runs from a particular
    % parameter setting as a point in a line, with standard error.
S = varargin{3};
%plotVersion = varargin{4};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));

% This is edited out because the code does not currently handle
% replications. Though, it would be easy to modify to do so.
%numReplications = str2double(get(S.edNumRep,'string'));


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

%allplot

% Create all plots.
expId = datestr(now,30);


cd([subPath plotFolder]);
system(['mkdir ' expId '_' saveTag])
cd(prevPath);

switch stimulationKind
    case 1
        avoidParamLines = [1 8];
    case 2
        avoidParamLines = [1 7];
end



plotAllFlag = true; % change this to an argument if needed.


if plotAllFlag
    paramsToRun = ones(1,8);
    paramsToRun(avoidParamLines) = 0;
else
    paramsToRun = zeros(1,8);
    paramsToRun(axisParam) = 1;
end

yMin = maxISI;
yMax = 0;
yMinStd = maxISI;
yMaxStd = 0;
yPadding = 1.1;
paramsToRun = find(paramsToRun);
for axisParam = paramsToRun
        specialPlotConditions = plotConditions;
        %allplot
        % Ignore check boxes for params that define lines
        specialPlotConditions(axisParam, :) = [1 1 1 1 1];

        % 5 is the number of parameter settings for each parameter kind.
        for i = 1:5
                paramSpecificMeans{i} = [];
                paramSpecificStds{i} = [];
        end

        load(['isiMetrics_' saveTag '.mat'], 'isiCounts', 'isiMeans','isiStds');

        validConditions = generateRunFilter();
        validIndexes = find(validConditions);
        for validNumber = 1:length(validIndexes)
            paramNumber = validIndexes(validNumber);

            axisParamIndex = find(parameterRanges(axisParam,:) == parametersAlreadyRun(paramNumber,axisParam));

            % Sort the statistic into the right bin.
            if ~isnan(isiMeans(paramNumber))
                paramSpecificMeans{axisParamIndex} = [paramSpecificMeans{axisParamIndex}; ...
                    isiMeans(paramNumber)];
            end
            if ~isnan(isiStds(paramNumber))
                paramSpecificStds{axisParamIndex} = [paramSpecificStds{axisParamIndex}; ...
                    isiStds(paramNumber)];
            end

        end
        parameterMeans = zeros(1,5);
        parameterErrors = zeros(1,5);
        parameterStds = zeros(1,5);
        parameterStdErrors = zeros(1,5);
        for paramSetting = 1:5
            parameterMeans(paramSetting) = mean(paramSpecificMeans{paramSetting});
            parameterErrors(paramSetting) = std(paramSpecificMeans{paramSetting})/sqrt(length(paramSpecificMeans{paramSetting}));
            parameterStds(paramSetting) = mean(paramSpecificStds{paramSetting});
            parameterStdErrors(paramSetting) = std(paramSpecificStds{paramSetting})/sqrt(length(paramSpecificStds{paramSetting}));
        end
        
        x = parameterRanges(axisParam,:);
        plotVersion = 1;
        
        switch plotVersion
            case 1
                figHandles{axisParam} = figure;
                subplot(1,2,1)
                errorbar(x, parameterMeans, parameterErrors,'k')
                xlabel(variableNames{axisParam})
                ylabel('Average ISI Mean')
                subplot(1,2,2)
                errorbar(x, parameterStds, parameterStdErrors,'k')
                xlabel(variableNames{axisParam})
                ylabel('Average ISI Standard Deviation')
                errorShift = zeros(1,5);

                if yMax < max(parameterMeans+parameterErrors)
                    yMax = max(parameterMeans);
                end
                if yMaxStd < max(parameterStds+parameterStdErrors)
                    yMaxStd = max(parameterStds+parameterStdErrors);
                end
                if yMin > min(parameterMeans-parameterErrors)
                    yMin = min(parameterMeans);
                end
                if yMinStd > min(parameterStds-parameterStdErrors)
                    yMinStd = min(parameterStds-parameterStdErrors);
                end
%                 
%                 if yMax < max(parameterMeans+parameterErrors)
%                     yMax = max(parameterMeans+parameterErrors);
%                 end
%                 if yMaxStd < max(parameterStds+parameterStdErrors)
%                     yMaxStd = max(parameterStds+parameterStdErrors);
%                 end
%                 if yMin > min(parameterMeans-parameterErrors)
%                     yMin = min(parameterMeans-parameterErrors);
%                 end
%                 if yMinStd > min(parameterStds-parameterStdErrors)
%                     yMinStd = min(parameterStds-parameterStdErrors);
%                 end
                
                    
            case 2
                figHandles{axisParam} = figure;
                errorbar(x, parameterMeans, parameterErrors,'k')
                hold on
                if min(parameterMeans-parameterStds) < 0
                    negativeStds = (parameterMeans-parameterStds) < 0;
                    errorShift = abs(parameterMeans-parameterStds);
                    errorShift(~negativeStds) = 0;
                    errorbar(x, parameterMeans+parameterStds+errorShift, parameterStdErrors,'k:')
                    errorbar(x, parameterMeans-parameterStds+errorShift, parameterStdErrors,'k:')
                else
                    errorbar(x, parameterMeans+parameterStds, parameterStdErrors,'k:')
                    errorbar(x, parameterMeans-parameterStds, parameterStdErrors,'k:')
                    errorShift = zeros(1,5);
                end
                xlabel(variableNames{axisParam})
                ylabel('ISI Mean')
                title(['ISI Mean and Standard Deviation of ' variableNames{axisParam}]);
                if max(parameterMeans+parameterStds+errorShift) > yMax
                    yMax = max(parameterMeans+parameterStds+errorShift);
                end
                if min(parameterMeans-parameterStds+errorShift) < yMin
                    yMin = min(parameterMeans-parameterStds+errorShift);
                end
        end
%        keyboard
%         anova1(parameterStds, {parameterRanges(axisParam,1), parameterRanges(axisParam,2), ...
%                                 parameterRanges(axisParam,3), parameterRanges(axisParam,4),...
%                                 parameterRanges(axisParam,5)});


end

for axisParam = paramsToRun
    figure(figHandles{axisParam})
    switch plotVersion
        case 1
            subplot(1,2,1);
            ylim([floor(yMin*(2-yPadding)) ceil(yMax*yPadding)])
            subplot(1,2,2)
            ylim([floor(yMinStd*(2-yPadding)) ceil(yMaxStd*yPadding)])
            
        case 2
            ylim([floor(yMin*(2-yPadding)) ceil(yMax*yPadding)])
    end
    if plotAllFlag
        saveas(figHandles{axisParam},[subPath plotFolder expId '_' saveTag '/' expId '_' saveTag '_' variableNames{axisParam} '.png']);
        %close(f);
    end
end

end


% Needs updating. But could work quickly.
function [] = plotCentrality_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));


    xMetricName = get(S.xMetric,{'string','val'});
    xMetricName = xMetricName{1}{xMetricName{2}};
    yMetricName = get(S.yMetric,{'string','val'});
    yMetricName = yMetricName{1}{yMetricName{2}};
    
    histMat = matfile(['histogramMetrics_' saveTag '.mat']);
    histInfo = whos(histMat);
    
    for i = 1:length(histInfo)
        if strcmp(xMetricName,getfield(histInfo,{i},'name'))
            xMetric = load(['histogramMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(histInfo,{i},'name'))
            yMetric = load(['histogramMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end
    
    isiMat = matfile(['isiMetrics_' saveTag '.mat']);
    isiInfo = whos(isiMat);
    
    for i = 1:length(isiInfo)
        if strcmp(xMetricName,getfield(isiInfo,{i},'name'))
            xMetric = load(['isiMetrics_' saveTag '.mat'], xMetricName);
            xMetric = xMetric.(xMetricName);
        elseif strcmp(yMetricName,getfield(isiInfo,{i},'name'))
            yMetric = load(['isiMetrics_' saveTag '.mat'], yMetricName);
            yMetric = yMetric.(yMetricName);
        end
    end    
    
    if ~exist('xMetric') || ~exist('yMetric')
        fprintf('\n Metric(s) not found!\n');
        return
    end


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
plotConditions(lineParam, :) = [1 1 1 1 1];
%plotConditions(axisParam, :) = [1 1 1 1 1];



% load centrality data.
load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.

validConditions = generateRunFilter();


f1 = figure;
hold on
%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
maxCentMarker = 100;
maxCent = 100;

validIndexes = find(validConditions);
for validIndex = 1:length(validIndexes)
    paramNumber = validIndexes(validIndex);
    shouldPlot = 1;
    % If parameter is of interest, plot it!
    for pNum = 1:8
        % This should only be one comparison per if
        if plotConditions(pNum,(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:))) ~= 1
            shouldPlot = 0;
            break;
        end
    end
    if shouldPlot
        % PLOT!
        centPlotMean = exMeans(parameterRanges(5,:) == parametersAlreadyRun(paramNumber,5),parameterRanges(6,:) == parametersAlreadyRun(paramNumber,6));
        centPlotStd = exStds(parameterRanges(5,:) == parametersAlreadyRun(paramNumber,5),parameterRanges(6,:) == parametersAlreadyRun(paramNumber,6))/sqrt(200);
%        centMarker = floor((maxCentMarker/maxCent)*centPlotStd);
        centMarker = maxCentMarker/maxCent*centPlotStd;
        
        
%        load([dataPath fileNames{paramNumber}], 'spikeData');
%        spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
%         %calculate ISIs with a maximum ISI
%         ISIdata = clusterSpikes2isi(spikeData, maxISI);
%         meanOfSTDs = mean(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4));
%         STDofSTDs = std(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 4))/sqrt(200);
%         
%         meanOfMeans = mean(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 3));
%         STDofMeans = std(ISIdata(ISIdata(:,1) ~= 1 & ISIdata(:,2) <= 160, 3))/sqrt(200);
%         plotSize = plotSize + 1;
%         toBePlotted(plotSize,:) = [centPlotMean, meanOfSTDs,STDofSTDs, parameterRanges(lineParam,:) == parametersAlreadyRun(paramNumber,lineParam),centMarker];

        dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
%        errorbar(centPlotMean,meanOfSTDs,STDofSTDs,'Color',dotColor,'MarkerSize',0.1);

        hold on
%        scatter3(centPlotMean,meanOfSTDs,STDofSTDs,centMarker,dotColor,'filled');
        scatter3(xMetric(paramNumber),yMetric(paramNumber),centPlotMean,centMarker,dotColor,'filled');
        %drawnow;
    end
    if mod(validIndex, round(length(validIndexes)/10)) == 0
        fprintf(['\n On ' num2str(validIndex) ' of ' num2str(length(validIndexes)) ' remaining.'])
        drawnow;
    end
end
drawnow;
xlabel(xMetricName)
ylabel(yMetricName)
zlabel('Centrality')

end


function stimTriggeredHist_call(varargin)
    % This function will take a single run, and slice it against itself.
    % Then, it will analyze that slicing.
    
    S = varargin{3};

plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;

% Go through check boxes and use only the leftmost condition.

% To have index values that correspond to the correct parameter.
chosenParameters = zeros(1,8);
for parIndex = 1:8
    for valIndex = 1:5
        chosenConditions = find(plotConditions(parIndex,:));
        chosenParameters(parIndex) = parameterRanges(parIndex,chosenConditions(1));
    end
end

% Now that we know which parameter condition to find, we can find it
for fileNumber = 1:numel(fileNames)
    if parametersAlreadyRun(fileNumber,:) == chosenParameters
        load([dataPath fileNames{fileNumber}], 'spikeData');
        break
    end
end

%Once data is loaded, analysis can begin.
stimMean = parametersAlreadyRun(fileNumber,7);
times = spikeData(:,1);
synchronizedHistogram = zeros(floor(totalTime/stimMean),stimMean);
prevTime = 0;
for i = 1:floor(totalTime/stimMean)
    windowTimes = (times > prevTime) & (times < (i*stimMean)) & (spikeData(:,3) > 1);
    if nnz(windowTimes) > 0
        timeIndexes = find(windowTimes);
        for j = 1:length(timeIndexes)
            timeIndex = timeIndexes(j);
            synchronizedHistogram(i,times(timeIndex)-prevTime) = ...
                synchronizedHistogram(i,times(timeIndex)-prevTime) + 1;
        end
    end
    prevTime = i*stimMean;

end

figure;

surface(synchronizedHistogram)

end


% Needs updating. Does not use filter. Or new data method.
function plotAllParamsMaxHist_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;
minSpikeCount = str2double(get(S.edSpikeRange1,'string'));
maxSpikeCount = str2double(get(S.edSpikeRange2,'string'));
maxHistVal =  str2double(get(S.edHistMax,'string'));
%useHistVal = get(S.useHistMax,'Value'); % this code assumes using maxHistVal


withinHistRange = zeros(length(parametersAlreadyRun),1);
load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat', 'histogramMaximums');

% This function will plot only conditions equal
withinHistRange = histogramMaximums == maxHistVal;

%save('histogramMaximums_26-475ms.mat','histogramMaximums');



%load relevant spikeCount data. 
%load(spikeCountDataPath, 'spikeCount');
% ^ This was commented out because of load regime change

load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat','summedHistograms');
spikeCount = summedHistograms;

% Determine indexes of data within the spike count range.
validSpikeCounts = (spikeCount > minSpikeCount & spikeCount < maxSpikeCount);


validConditions = validSpikeCounts & withinHistRange;


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
% axisParam = zeros(8,1);
% for i = 1:8
%     axisParam(i) = get(S.axisRadio(i), 'Value');
% end
lineParam = find(lineParam);
%axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param

% CC: The line parameter is just being used to 
%plotConditions(lineParam, :) = [1 1 1 1 1];
%plotConditions(axisParam, :) = [1 1 1 1 1];


% load centrality data.
%load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.


f = figure;
hold on
%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);

% maxCentMarker = 200;
% maxCent = 100;
% plotSize = 0;
% toBePlotted = [];

numPlotted = 0;


paramCountMatrix = zeros(8,5);

validIndexes = find(validConditions);


for validNumber = 1:length(validIndexes)
    paramNumber = validIndexes(validNumber);
    runParams = parametersAlreadyRun(paramNumber,:);
    for i = 1:8
        paramCountMatrix(i, runParams(i) == parameterRanges(i,:)) = ...
            paramCountMatrix(i, runParams(i) == parameterRanges(i,:)) ...
            + 1;
    end

        load([dataPath fileNames{paramNumber}], 'spikeData');
        spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);

        dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
        figure(f);
        for plotNumber = 1:6
            subplot(3,2,plotNumber);
            if plotNumber == 1
                axis([0 totalTime 0 200]);
            else
               axis([0 totalTime 0 250]);
            end
             hold on
            plot(spikeData(spikeData(:,3) == plotNumber,1), ...
            spikeData(spikeData(:,3) == plotNumber,2), '.','Color',dotColor, 'markers', 2);
        end
        if length(spikeData) > 0
            numPlotted = numPlotted + 1;
        end

        hold on
%        drawnow;

end


fprintf(['\n Spike Plot Complete! \n The number of runs plotted was: ' num2str(numPlotted) '\n']);
fprintf('These parameters participated in conditions: \n')
for i = 1:8
    fprintf([num2str(paramCountMatrix(i,:)) '\n']);
end

end


% Uncertain what this does...
% It's a method to overlay spike histograms for parameter kinds.
function [] = spikeHistogram_call(varargin)
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
plotConditions(lineParam, :) = [1 1 1 1 1];
plotConditions(axisParam, :) = [1 1 1 1 1];


% load centrality data.
%load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.

f = figure;
hold on
%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);

%maxCentMarker = 200;
%maxCent = 100;
%plotSize = 0;
%toBePlotted = [];


maxY = 150;
histMax = 1;
histBinSize = ceil((maxTime-minTime)/5);
         
figure(f);
hold on
       

for paramNumber = 1:length(parametersAlreadyRun)
    shouldPlot = 1;
    % If parameter is of interest, plot it!
    for pNum = 1:8
        % This should only be one comparison per if
        if plotConditions(pNum,(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:))) ~= 1
            shouldPlot = 0;
            break;
        end
    end
    if shouldPlot

        load([dataPath fileNames{paramNumber}], 'spikeData');
        spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
        
        
        % Cut out data from the stimulus drive.
        % Keep only the spike times.
        spikeData = spikeData(spikeData(:,3) > 1,1);
        spikeHistogram = hist(spikeData,histBinSize);

        if max(spikeHistogram) > histMax
            histMax = max(spikeHistogram);
        end
        
        
        

        dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
%        errorbar(centPlotMean,meanOfSTDs,STDofSTDs,'Color',dotColor,'MarkerSize',0.1);
        % The axis parameter determines which plot to record data.
        plotNumber = find(parameterRanges(axisParam,:) == parametersAlreadyRun(paramNumber, axisParam));
        subplot(5,1,plotNumber);
        hold on
%             if plotNumber == 1
%                 axis([0 totalTime 0 200]);
%             else
%                axis([0 totalTime 0 250]);
%             end
        x = (1:histBinSize) * ceil(maxTime-minTime)/100;
        
        axis([0 histBinSize 0 histMax]);
            
%        y = fit(x', spikeHistogram', 'cubicinterp');
        % remove less than zeros
%        y(y<0) = 0;
        plot(x,spikeHistogram, 'Color', dotColor);
        drawnow;
%             plot(spikeData(spikeData(:,3) == plotNumber,1), ...
%             spikeData(spikeData(:,3) == plotNumber,2), '.','Color',dotColor, 'markers', 2);
    end
       
        
%        scatter(centPlotMean,meanOfSTDs,centMarker,dotColor);
%        scatter3(centPlotMean,meanOfSTDs,STDofSTDs,centMarker,dotColor,'filled');
        hold on
%        drawnow;
end

for plotNumber = 1:5
        subplot(5,1,plotNumber);
        axis([0 histBinSize 0 histMax]);
end



fprintf('\n Finished the Spike Histogram plot. \n');

end

% This was designed to be a 3d plot to disambiguate scatter plots
% this should maybe be trashed. seems worthless atm.
% it should create plots of spike count vs parameter value.
function [] = spikeCount_call(varargin)
    
S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

maxISI = str2double(get(S.edMaxISI,'string'));
minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;


%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
plotConditions(lineParam, :) = [1 1 1 1 1];
plotConditions(axisParam, :) = [1 1 1 1 1];

parametersAlreadyRun = varargin{4};
fileNames = varargin{5};
dataPath = varargin{6};


% load centrality data.
load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.


f = figure;
hold on
%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);

%maxCentMarker = 200;
%maxCent = 100;
%plotSize = 0;
%toBePlotted = [];


maxY = 150;
histMax = 1;
histBinSize = ceil((maxTime-minTime)/5);
         
figure(f);
hold on

for paramNumber = 1:length(parametersAlreadyRun)
    shouldPlot = 1;
    % If parameter is of interest, plot it!
    for pNum = 1:8
        % This should only be one comparison per if
        if plotConditions(pNum,(parametersAlreadyRun(paramNumber,pNum) == parameterRanges(pNum,:))) ~= 1
            shouldPlot = 0;
            break;
        end
    end
    if shouldPlot

        load([dataPath fileNames{paramNumber}], 'spikeData');
        spikeData = spikeData(spikeData(:,1) >= minTime & spikeData(:,1) <= maxTime,:);
        centPlotMean = exMeans(parameterRanges(5,:) == parametersAlreadyRun(paramNumber,5),parameterRanges(6,:) == parametersAlreadyRun(paramNumber,6));
%        centPlotStd = exStds(parameterRanges(5,:) == parametersAlreadyRun(paramNumber,5),parameterRanges(6,:) == parametersAlreadyRun(paramNumber,6))/sqrt(200);
        
        
        % Cut out data from the stimulus drive.
        % Keep only the spike times.
        spikeData = spikeData(spikeData(:,3) > 1,1);
        spikeCount = size(spikeData,1);

        

        dotColor = colorRange(parametersAlreadyRun(paramNumber,lineParam) == parameterRanges(lineParam,:),:);
%        errorbar(centPlotMean,meanOfSTDs,STDofSTDs,'Color',dotColor,'MarkerSize',0.1);
        % The axis parameter determines which plot to record data.
%        plotNumber = find(parameterRanges(axisParam,:) == parametersAlreadyRun(paramNumber, axisParam));
%        subplot(5,1,plotNumber);
%         hold on
%             if plotNumber == 1
%                 axis([0 totalTime 0 200]);
%             else
%                axis([0 totalTime 0 250]);
%             end
%        x = (1:histBinSize) * ceil(maxTime-minTime)/100;
        
%        axis([0 histBinSize 0 histMax]);
            
%        y = fit(x', spikeHistogram', 'cubicinterp');
        % remove less than zeros
%        y(y<0) = 0;
        axisValue = parametersAlreadyRun(paramNumber,axisParam);
        scatter(axisValue,spikeCount, 20, dotColor,'filled');
        %scatter(centPlotMean,spikeCount, 20, dotColor,'filled');
        drawnow;
    end
       
        
%        scatter(centPlotMean,meanOfSTDs,centMarker,dotColor);
%        scatter3(centPlotMean,meanOfSTDs,STDofSTDs,centMarker,dotColor,'filled');
        hold on
%        drawnow;
end

%for plotNumber = 1:5
%        subplot(5,1,plotNumber);
%        axis([0 histBinSize 0 histMax]);
%end



fprintf('\n Finished the spike count plot. \n');

end
% Needs updating. Does not use filter. Or new data method.
function spikeCountVsHistMax_call(varargin)

S = varargin{3};
%parametersAlreadyRun = varargin{4};
%set(S.busy, 'visible', 'on');
plotConditions = str2num(get(S.plotConditions, 'string'));

minTime = str2double(get(S.edTimeRange1,'string'));
maxTime = str2double(get(S.edTimeRange2,'string'));
totalTime = maxTime - minTime + 1;
minSpikeCount = str2double(get(S.edSpikeRange1,'string'));
maxSpikeCount = str2double(get(S.edSpikeRange2,'string'));
maxHistVal =  str2double(get(S.edHistMax,'string'));
useHistVal = get(S.useHistMax,'Value'); % this code assumes using maxHistVal

%scrape the radio button values to determine indices
lineParam = zeros(8,1);
for i = 1:8
    lineParam(i) = get(S.lineRadio(i), 'Value');
end
axisParam = zeros(8,1);
for i = 1:8
    axisParam(i) = get(S.axisRadio(i), 'Value');
end
lineParam = find(lineParam);
%axisParam = find(axisParam);

% Ignore check boxes for params that define lines and axes
% For this function, there is no use to the line Param
%plotConditions(lineParam, :) = [1 1 1 1 1];
%plotConditions(axisParam, :) = [1 1 1 1 1];

parametersAlreadyRun = varargin{4};
fileNames = varargin{5};
dataPath = varargin{6};



withinHistRange = ones(length(parametersAlreadyRun),1);
load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat', 'histogramMaximums');

% This function will plot only conditions less than or equal to maxHistVal
if useHistVal
    withinHistRange = histogramMaximums <= maxHistVal;
end


%load relevant spikeCount data. 
%load(spikeCountDataPath, 'spikeCount');
% ^ This was commented out because of load regime change

load('26-475_summedHistograms_HistogramMaximums_10ms_binsize.mat','summedHistograms');
spikeCount = summedHistograms;

load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','histogramVariances');
% histogramVariances
% histogramVariancesNZ
load('26-475_summedHistograms_HistogramMaximums__variances_10ms_binsize.mat','histogramVariancesNZ');

histogramVariances = histogramVariancesNZ;

% Determine indexes of data within the spike count range.
validSpikeCounts = (spikeCount > minSpikeCount & spikeCount < maxSpikeCount);


boundedConditions = validSpikeCounts & withinHistRange;

%validConditions = false(length(boundedConditions));
%validConditions = zeros(length(boundedConditions),1);
invalidConditions = zeros(length(boundedConditions),1);

% Go through each plotCondition and keep only specified validConditions
for i = 1:8 % for each parameter kind
    if i ~= lineParam
        for j = 1:5 % for each parameter setting
            if ~plotConditions(i,j)
               parameterConditions = parametersAlreadyRun(:,i) == parameterRanges(i,j);
               %boundedParameterConditions = parameterConditions & boundedConditions;
               invalidConditions = invalidConditions + parameterConditions;
            end
%                 
%             if plotConditions(i,j)
%                if j == 5 & i == 6
%                    keyboard
%                end
%                parameterConditions = parametersAlreadyRun(:,i) == parameterRanges(i,j);
%                boundedParameterConditions = parameterConditions & boundedConditions;
% %               clear parameterConditions
%                tempConditions = validConditions + boundedParameterConditions;
% %               clear boundedParameterConditions;
%                validConditions = tempConditions;
% %               clear tempConditions
%                 % this broke my memory
%                %validConditions = validConditions | ((parametersAlreadyRun(:,i) == parameterRanges(i,j)) & boundedConditions);
%             end
        end
    end
end

invalidConditions = invalidConditions > 0;

validConditions = boundedConditions - invalidConditions;

validConditions = validConditions > 0;


clear parameterConditions boundedParameterConditions tempConditions



% load centrality data.
%load('centrality_data','exMeans','exStds','inMeans','inStds');
% This file should contain exMeans exStds inMeans inStds and centrality

% now, for the data specified in plot conditions, plot different sized circles on 

% Go through all the data, if it is one of the plot conditions, plot the
% data in terms of the parameter setting's centrality data.


%colorRange =  ['r' 'g' 'b' 'm' 'k'];
% Color Range going uniformly from red to blue.
%colorRange = [1 0 0; 0.8 0 0.2; 0.6 0 0.4; 0.4 0 0.6; 0.2 0 0.8; 0 0 1];
% extract color range from rgb matrix...
numColors = 5;
colorRange = copper(numColors);

colorRange = [0 0 0; 0 0 0; 0 0 0; 0 0 0; 0 0 0];

variableNames{1} = 'Internal Delay Distribution Mean';
variableNames{2} = 'Internal Delay Distribution Variance';
variableNames{3} = 'External Delay Distribution Mean';
variableNames{4} = 'External Delay Distribution Variance';
variableNames{5} = 'Internal Number of Connections per Neuron';
variableNames{6} = 'External Number of Connections per Neuron';
variableNames{7} = 'Stimuli Mean';
variableNames{8} = 'Stimuli Variance';
    
numPlotted = 0;


paramCountMatrix = zeros(8,5);


f = figure;
hold on
title(variableNames{lineParam});

set(gcf,'units','normalized','outerposition',[0 0 1 1])

scMax = 0;
hmMax = 0;
hvMax = 0;

%         % split the 5 diff plots code from 2 plots code
%         for pVal = 1:5
%             subplot(2,3,pVal);
%             hold on
%             validRuns = parametersAlreadyRun(:,p) == parameterRanges(p,pVal);
%             dotColor = colorRange(pVal,:);
%             plot(summedHistograms(validRuns),histogramMaximums(validRuns),'.','MarkerSize',1,'Color',dotColor);
%             title(variableNames{p});
%         end

% 5 plot condition
% Go through each color and plot the runs within the constraints
% pVal is the particular parameter setting which corresponds to a
% particular color.
for pVal = 1:5
    subplot(2,3,pVal);
    hold on
    validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
    dotColor = colorRange(pVal,:);
    if max(histogramMaximums(validRuns)) > hmMax
        hmMax = max(histogramMaximums(validRuns));
    end
    if max(summedHistograms(validRuns)) > scMax
        scMax = max(summedHistograms(validRuns));
    end
    plot(summedHistograms(validRuns),histogramMaximums(validRuns),'.','MarkerSize',.1,'Color',dotColor);
    if pVal == 2
        title([variableNames{lineParam} ' plotting spikeCount vs histMax']);
    end
    xlabel('spikeCount');
    ylabel('histMax');
    numPlotted = numPlotted + nnz(validRuns);
    for i = 1:8
        paramCountMatrix(i,pVal) = nnz((parametersAlreadyRun(validRuns,i) == parameterRanges(i,pVal)));
    end
end

for pVal = 1:5
    subplot(2,3,pVal);
    plotAxis = [0 scMax 0 hmMax];
    plotAxis = plotAxis .* 1.05;
    axis(plotAxis);
end


% Plot histogram variance vs. spikeCount
f2 = figure;
hold on

set(gcf,'units','normalized','outerposition',[0 0 1 1])
for pVal = 1:5
    subplot(2,3,pVal);
    hold on
    validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
    if max(sqrt(histogramVariances(validRuns))) > hvMax
        hvMax = max(sqrt(histogramVariances(validRuns)));
    end
    dotColor = colorRange(pVal,:);
    if pVal == 2
        title([variableNames{lineParam} ' plotting spikeCount vs histVariances']);
    end
    xlabel('spikeCount');
    ylabel('histVariances');
    plot(summedHistograms(validRuns),sqrt(histogramVariances(validRuns)),'.','MarkerSize',.1,'Color',dotColor);
end

for pVal = 1:5
    subplot(2,3,pVal);
    plotAxis = [0 scMax 0 hvMax];
    plotAxis = plotAxis .* 1.05;
    axis(plotAxis);
end

% Plot histogram variance vs. spikeCount
f3 = figure;
hold on

set(gcf,'units','normalized','outerposition',[0 0 1 1])
for pVal = 1:5
    subplot(2,3,pVal);
    hold on
    validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
    dotColor = colorRange(pVal,:);
    if pVal == 2
        title([variableNames{lineParam} ' plotting histVariances vs histMax']);
    end
    xlabel('histVariances');
    ylabel('histMax');
    plot(sqrt(histogramVariances(validRuns)),histogramMaximums(validRuns),'.','MarkerSize',.1,'Color',dotColor);
end


for pVal = 1:5
    subplot(2,3,pVal);
    plotAxis = [0 hvMax 0 hmMax];
    plotAxis = plotAxis .* 1.05;
    axis(plotAxis);
end

f4 = figure;
hold on

set(gcf,'units','normalized','outerposition',[0 0 1 1])
for pVal = 1:5
    subplot(2,3,pVal);
    hold on
    validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
    dotColor = colorRange(pVal,:);
    if pVal == 2
        title([variableNames{lineParam} ' plotting histVariances vs histMax vs spikeCount']);
    end
    xlabel('spikeCount');
    ylabel('histVariances');
    zlabel('histMax');
    plot3(summedHistograms(validRuns),sqrt(histogramVariances(validRuns)),histogramMaximums(validRuns),'.','MarkerSize',.1,'Color','k');
    plotAxis = [0 scMax 0 hvMax 0 hmMax];
    plotAxis = plotAxis .* 1.05;
    axis(plotAxis);
end

% 2 plot condition 
% subplot(1,2,1);
% hold on
% % Go through each color and plot the runs within the constraints
% % pVal is the particular parameter setting which corresponds to a
% % particular color.
% for pVal = 1:5
%     validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
%     dotColor = colorRange(pVal,:);
%     plot(summedHistograms(validRuns),histogramMaximums(validRuns),'.','MarkerSize',1,'Color',dotColor);
%     title(variableNames{lineParam});
%     numPlotted = numPlotted + nnz(validRuns);
%     for i = 1:8
%         paramCountMatrix(i,pVal) = nnz((parametersAlreadyRun(validRuns,i) == parameterRanges(i,pVal)));
%     end
% end
% 
% subplot(1,2,2);
% hold on
% for pVal = 5:-1:1
%     validRuns = (parametersAlreadyRun(:,lineParam) == parameterRanges(lineParam,pVal)) & validConditions;
%     dotColor = colorRange(pVal,:);
%     plot(summedHistograms(validRuns),histogramMaximums(validRuns),'.','MarkerSize',1,'Color',dotColor);
% end



fprintf(['\n Spike Plot Complete! \n The number of runs plotted was: ' num2str(numPlotted) '\n']);
fprintf('These parameters participated in conditions: \n')
for i = 1:8
    fprintf([num2str(paramCountMatrix(i,:)) '\n']);
end

end

%This is not a real function.
function centrality = graphAnalysis()
    % This is standalone code, it doesn't interact with the rest of the
    % code.

% for each parameter combination, create a network.
% Convert that network to one large, binary connectivity matrix. Run
% through the betweenness algorithm. betweenness_bin
% Store the centrality in a vector corresponding to the parameter
% combination, called centrality.   
    
                
internalConnections = 5:3:17;
externalConnections = 5:3:17;
centrality = zeros(25,1440);
clustering = zeros(25,1440);
centralityIndex = 0;
for i = 1:5
    for j = 1:5
        centralityIndex = centralityIndex+1;
        [connectivityDelays coords] = netEvalNetworkBuild(1,0,1,0,internalConnections(i),externalConnections(j));
        connectivity = connectivityDelays > 0;
        clustering(centralityIndex,:) = clustering_coef_bd(connectivity);
        centrality(centralityIndex,:) = betweenness_bin(connectivity);
    end
end
    

% Take centrality and divide it between inhibitory and excitatory. Then
% calculate means and stds.
exCent = zeros(25,1000);
inCent = zeros(25,200);

for i = 2:6
    nucleusCent = centrality(:,((i-1)*240+1):i*240);
    exCent(:,((i-1)*200+1):i*200) = nucleusCent(:,1:200);
    inCent(:,((i-1)*40+1):i*40) = nucleusCent(:,201:240);
end

avgExCent = mean(exCent');
stdExCent = std(exCent');

avgInCent = mean(inCent');
stdInCent = std(inCent');

exMeans = [avgExCent(1:5); avgExCent(6:10); avgExCent(11:15); avgExCent(16:20); avgExCent(21:25)];
inMeans = [avgInCent(1:5); avgInCent(6:10); avgInCent(11:15); avgInCent(16:20); avgInCent(21:25)];

exStds = [stdExCent(1:5); stdExCent(6:10); stdExCent(11:15); stdExCent(16:20); stdExCent(21:25)];
inStds = [stdInCent(1:5); stdInCent(6:10); stdInCent(11:15); stdInCent(16:20); stdInCent(21:25)];

save('centrality_data', 'centrality', 'exMeans','inMeans','exStds','inStds');

end

%This is not a real function
% It would work if spikeCount were loaded...
function spikeMatrix = spikeCountMatrix(validRuns)

    spikeSums = zeros(8,5);
    spikeCounts = zeros(8,5);
    
    validIndexes = find(validRuns);
    
    for validIndex = 1:length(validIndexes)
        pNum = validIndexes(validIndex);
        paramSet = parametersAlreadyRun(pNum,:);
        for p = 1:8
            paramSetting = find(paramSet(p) == parameterRanges(p,:));
            spikeSums(p,paramSetting) = spikeSums(p,paramSetting) + spikeCount(pNum);
            spikeCounts(p,paramSetting) = spikeCounts(p,paramSetting) + 1;
        end
    end

    
end


end