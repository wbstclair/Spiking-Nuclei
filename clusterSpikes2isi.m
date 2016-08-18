function ISIs = clusterSpikes2isi(spikes, maxISI,includeRawISI)
% (spikes, maxISI)
% Take cluster spike data and return mean ISIs and standard deviation ISIs
% for each neuron within each cluster, of the form [nucleiNumber
% neuronNumber mean std]. Input is of the form [time neuron nuclei] for
% each spike. If none, returns an empty matrix.
% maxISI should be an integer that operates as the maximum ISI to be
% considered for analysis. If the maxISI is negative, then do not use a
% maximum interspike interval for generating averages.
% returned ISIs = nucleiNumber neuronNumber mean(trimmedISIs) std(trimmedISIs)
if ~exist('maxISI')
    maxISI = -1;
end

if ~exist('includeRawISI')
    includeRawISI = 0;
end

nucleiList = unique(spikes(:,3));

%totalSize = 0;
% preallocate ISI size...
%for nucleiIndex = 1:numel(nucleiList)
%    nucleiNumber = nucleiList(nucleiIndex);
%    spikesInNucleiIndex = nucleiNumber == spikes(:,3);
%    neuronList = unique(spikes(spikesInNucleiIndex, 2));
%    totalSize = totalSize + numel(neuronList);
%end
%ISIs = zeros(totalSize, 4);

currentDataIndex = 0;
for nucleiIndex = 1:numel(nucleiList)
    nucleiNumber = nucleiList(nucleiIndex);
    spikesInNucleiIndex = nucleiNumber == spikes(:,3);
    nucleiSpikes = spikes(spikesInNucleiIndex, :);
    neuronList = unique(spikes(spikesInNucleiIndex, 2));
    % For each neuron, compute ISIs for all spikes.
    for neuronIndex = 1:numel(neuronList)
        neuronNumber = neuronList(neuronIndex);
        % neuronSpikeTimes is a list of all the times this neuron
        % spiked.
        neuronSpikeTimes = nucleiSpikes(nucleiSpikes(:,2) == neuronNumber, 1);
        neuronISIs = neuronSpikeTimes;
        prevTime = 0;
        for spikeNum = 1:numel(neuronSpikeTimes)
            neuronISIs(spikeNum) = neuronSpikeTimes(spikeNum) - prevTime;
            prevTime = neuronSpikeTimes(spikeNum);
        end
        % now implement maxISI
        % instead of replacing it with the max (skewing the data), just cut
        % the high ISIs out of the data.
        trimmedISIs = neuronISIs;
        if maxISI > 1
            trimmedISIs = neuronISIs(neuronISIs < maxISI);
        end
        if ~isempty(trimmedISIs)
            currentDataIndex = currentDataIndex + 1;

            ISIs(currentDataIndex,:) = [nucleiNumber neuronNumber mean(trimmedISIs) std(trimmedISIs) length(trimmedISIs)];
            if includeRawISI
                rawISI{currentDataIndex} = trimmedISIs;
                rawNucleiNum(currentDataIndex,:) = [nucleiNumber neuronNumber];
            end
        end
    end
end



if ~exist('ISIs')
    ISIs = [];
end

if includeRawISI
    if ~isempty(ISIs)
        completeReturn{1} = ISIs;
        completeReturn{2} = rawISI;
        completeReturn{3} = rawNucleiNum;
        ISIs = completeReturn;
    else
        completeReturn{1} = [];
        completeReturn{2} = {};
        completeReturn{3} = [];
        ISIs = completeReturn;
    end
end


end