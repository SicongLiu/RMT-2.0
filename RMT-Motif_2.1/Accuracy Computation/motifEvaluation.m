function [MotifEntropy, precisionMatrix, recallMatrix, FScoreMatrix, total_index] = motifEvaluation(groundTruthFile, motifFile, algorithmType, windowSize, threshold, timeOverlapThreshold)
% MotifEntropy: precisionEntropy, recallEntropy, FScoreEntropy

motifFeatureCount = csvread(groundTruthFile);

% if(strcmp(algorithmType,'RMT') || strcmp(algorithmType,'RME') == 1)
%     [num,txt,raw] = xlsread(motifFile, 'AP_all_SubC');
%     %[num,txt,raw] = xlsread(motifFile, 'AP_all');
% else
%     window = ['Lenght_', num2str(windowSize)];
%     [num,txt,raw] = xlsread(motifFile, window);
% end

num = csvread(motifFile);

motifClass = unique(motifFeatureCount(:, 1));
motifClassCount = [];
% update motif class count
for i = 1 : size(motifClass, 1)
    currentMotifClassCount = size(nonzeros(motifFeatureCount(:, 1) == i), 1);
    motifClassCount = [motifClassCount, currentMotifClassCount];
end

% loop through classID
classID = num(:, 1);
myClassID = unique(classID);


% ignore single cluster elements
[myClassID, classID, num] = filter_single_cluster(myClassID, classID, num);

% stateMatrix: predicated_class_size x injected_class_size
precisionMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));
recallMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));
FScoreMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));

for i = 1 : size(myClassID, 1)
    currentClassIndex = classID == myClassID(i);
    statEntry = num(currentClassIndex, :);
    
    % for each of these predicated class, precision and recall for each injected class
    % currentInjectedClassID = unique(injectedClassID);
    currentRetrievedSize = size(statEntry, 1); % used for precision
    
    for j = 1 : size(motifClassCount, 2)
        % update statMatrix
        % group feature scores
        relevantSize = motifClassCount(j); % for this precision of current class
        [precision, recall] = groupFeatureScores(statEntry, j, relevantSize, currentRetrievedSize, threshold, timeOverlapThreshold);
        
        precisionMatrix(i, j) = precision;
        recallMatrix(i, j) = recall;
        if(precision == 0 || recall ==0)
            FScoreMatrix(i, j) = 0;
        else
            FScoreMatrix(i, j) = 2 * precision * recall / (precision + recall);
        end
    end
    
end

[precisionMatrix, recallMatrix, FScoreMatrix, total_index] = delete_zeros(precisionMatrix, recallMatrix, FScoreMatrix);
if(size(precisionMatrix, 1) == 0)
    precisionMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));
end

if(size(recallMatrix, 1) == 0)
    recallMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));
end

if(size(FScoreMatrix, 1) == 0)
    FScoreMatrix = zeros(size(myClassID, 1), size(motifClassCount, 2));
end
%% from Silv Why  is this here?
[precisionEntropy, recallEntropy, FScoreEntropy] = computeEntropy(precisionMatrix, recallMatrix, FScoreMatrix);
MotifEntropy = [precisionEntropy, recallEntropy, FScoreEntropy];
end