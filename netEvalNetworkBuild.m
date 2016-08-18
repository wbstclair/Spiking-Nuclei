function [connectivity, coords] = netEvalNetworkBuild(currentIDDM, currentIDDV, currentEDDM, currentEDDV, currentINCPN, currentENCPN, returnRandomForm)
% delay distribution (internally) within a cluster. mean and variance
%internalDelayDistribMean = [1:6:30]; IDDM
%internalDelayDistribVariance = [0:4:18]; IDDV
% delay between clusters (externally) mean and variance
%externalDelayDistribMean = [1:6:30]; EDDM
%externalDelayDistribVariance = [0:4:18]; EDDV
% connections per neuron within a cluster (corresponds to density)
%internalNumConnectionsPerNeuron = [10:20:90]; INCPN
% connections per neuron between clusters (corresponds to density)
%externalNumConnectionsPerNeuron = [10:10:50]; ENCPN
% stimuli firing rate (per second) mean and variance
%stimuliMean = [30:100:500]; StimMean
%stimuliVariance = [0:10:40]; StimVariance
%rateCode = rand(200,1); row # = neuron index, value = rate
%timeThreshold , used to impose a hard maximum on how long it takes to run
%the evaluation. The number itself refers to the # of spikes in the list,
%not the clock time it takes to run the evaluation.
% This is a version that returns example networks.
if ~exist('timeThreshold')
    timeThreshold = NaN;
end

if ~exist('returnRandomForm')
    returnRandomForm = 0;
end


rng('shuffle');

numClusters = 6;


numNuclei = numClusters;
% Initialize the metanetwork cell array.
%nuclei = cell(numNuclei,numNuclei);
for i = 1:numNuclei
    for j = 1:numNuclei
        nuclei{i}{j} = [];
    end
end


% network parameters.
%Number of excitatory neurons
params.Ne = 200;
%Number of inhibitory neurons
params.Ni = 40;
params.N = params.Ne + params.Ni;
% neuron model parameters for the excitatory neurons
params.exA = 0.02;
params.exB = 0.2;
params.exC = -65;
params.exD = 8;
% neuron model parameters for the inhibitory neurons.
params.inA = 0.1;
params.inB = 0.2;
params.inC = -65;
params.inD = 2;
% Number of outgoing connections per neuron. 
% I have set this to zero to allow no self-connections for the source
% nuclei.
params.numConnectionsPerNeuron = 0;
% a vector of inclusive lower bound and inclusive upper bound of the range of conductance delays. in ms
% Izhi&Szat have 20ms max, uniform.
params.delayRange = currentIDDM + [0 currentIDDV];
%params.isSpatialNetwork = true;
%params.spatialClusterType = 'poisson';
params.initExWeight = 5;
params.initInWeight = -4;
% weight bounds, applied every millisecond.
params.weightUpperbound = 8;
params.weightLowerbound = -8;
% Izhikevich iters two .5 ms to add to 1ms. This is not really a parameter.
params.timeStep = .5; % 0.5 ms.

network1 = networkBuild(params);
network1.nucleiIndex = 1;

% network parameters.
%Number of excitatory neurons
params.Ne = 200;
%Number of inhibitory neurons
params.Ni = 40;
params.N = params.Ne + params.Ni;
% neuron model parameters for the excitatory neurons
params.exA = 0.02;
params.exB = 0.2;
params.exC = -65;
params.exD = 8;
% neuron model parameters for the inhibitory neurons.
params.inA = 0.1;
params.inB = 0.2;
params.inC = -65;
params.inD = 2;
% Number of outgoing connections per neuron.
params.numConnectionsPerNeuron = currentINCPN;
% a vector of inclusive lower bound and inclusive upper bound of the range of conductance delays. in ms
% Izhi&Szat have 20ms max, uniform.
params.delayRange = currentIDDM + [0 currentIDDV];
params.initExWeight = 5;
params.initInWeight = -4;
% weight bounds, applied every millisecond.
params.weightUpperbound = 8;
params.weightLowerbound = -8;
% Izhikevich iters two .5 ms to add to 1ms. This is not really a parameter.
params.timeStep = .5; % 0.5 ms.


nuclei{1}{1} = network1;
clear network1;

% Build numClusters # of nuclei.
for currentCluster = 2:numClusters
    network = networkBuild(params);
    network.nucleiIndex = currentCluster;
    nuclei{currentCluster}{currentCluster} = network;
end
clear params network currentCluster


% Now, build the connections between the source nuclei and the different
% clusters.
delayRange = currentEDDM + [0 currentEDDV];
%baseDelay = 5; % the minimum delay
%delayVariability = 3;
numConnectionsPerNeuron = currentENCPN;
weightUpperbound = 8;
weightLowerbound = -8;
numNuclei = numClusters;

% this builds connections between the source cluster and downstream
% clusters (forward only)
for currentCluster = 2:numClusters
    % Feed forward connect nuclei index to another nuclei index.
    ffConnect = [1 currentCluster];
    % a vector of inclusive lower bound and inclusive upper bound of the range of conductance delays. in ms
    nuclei = buildConnections(nuclei, numNuclei, ffConnect, delayRange, ...
        numConnectionsPerNeuron, weightLowerbound, weightUpperbound);
end

% This builds connections between each downstream cluster.
for sourceCluster = 2:numClusters
    for targetCluster = 2:numClusters
        % Only build external connections.
        if sourceCluster ~= targetCluster
            ffConnect = [sourceCluster targetCluster];
            nuclei = buildConnections(nuclei, numNuclei, ffConnect, delayRange, ...
              numConnectionsPerNeuron, weightLowerbound, weightUpperbound);
        end
    end
end
clear ffConnect numConnectionsPerNeuron
clear weightUpperbound weightLowerbound delayRange        


numNeurons = 240;
connectivity = zeros(numNeurons*numClusters);
for fromCluster = 1:numClusters
    for toCluster = 1:numClusters
        if ~isempty(nuclei{fromCluster}{toCluster}.lastFire)
            connectivity(((fromCluster-1)*numNeurons+1):(fromCluster*numNeurons), ...
                ((toCluster-1)*numNeurons+1):(toCluster*numNeurons)) ...
                =  nuclei{fromCluster}{toCluster}.conductanceDelays;
        end
    end
end

% extraSpacing = 2000;
% angleIncrement = 2*pi/(numNeurons*numClusters);
% ang = 0:angleIncrement:2*pi;
% r = 1000;
% 
% nodeIndex = 0;
% coords = zeros(1440,2);
% for clusterNum = 1:numClusters
%     for neuronNum = 1:numNeurons
%         nodeIndex = nodeIndex + 1;
%         coords(nodeIndex,:) = [r*cos(ang(nodeIndex)) r*sin(ang(nodeIndex))];
%     end
% end
% 

neuronsPerRow = 15;
rowsOfNeurons = 16;
maxHeight = numNeurons*3/rowsOfNeurons;%should be integer

%coords = [];

%coords = zeros(length(connectivity),8);
coords = zeros(length(connectivity),2);
for i = 1:length(connectivity)
    neuronN = mod(i-1,numNeurons)+1;
    nucN = floor((i-1)/numNeurons)+1;
    nucX = mod(nucN-1,2)+1;
    nucY = ceil(nucN/2);
    neurX = mod(neuronN-1,neuronsPerRow) + 1;
    neurY = ceil(neuronN/neuronsPerRow);
    
    coords(i,:) = [neurX+(nucX-1)*neuronsPerRow, neurY+(nucY-1)*rowsOfNeurons]; 
%    coords(i,:) = [neurX+(nucX-1)*neuronsPerRow, neurY+(nucY-1)*rowsOfNeurons, neuronN, nucN, nucX, nucY,neurX,neurY]; 
end

usePercentage = 1;

if usePercentage
    
    
    % I can use the existing coords to shape new coords
    % Coordinates currently indicate its nucleic index and neuron number. 
    % For each neuron, take its delay pattern and compute 
    
end


if returnRandomForm
    for i = 1:size(connectivity,1)
            % determine local clustering coef
            neighborhood = connectivity(i,:);
%            localClusteringCoef = sum(connectivity(neighborhood,neighborhood))/(nnz(neighborhood)*(nnz(neighborhood)-1);
    end
end

return