function [precisionEntropy, recallEntropy, FScoreEntropy] = computeEntropy(precisionMatrix, recallMatrix, FScoreMatrix)
% compute weighted entropy for each identified cluster by RMT and MatrixProfile
numOfCluster = size(precisionMatrix, 1);
precisionEntropyArray = zeros(numOfCluster, 1);
recallEntropyArray = zeros(numOfCluster, 1);
FScoreEntryArray = zeros(numOfCluster, 1);

for i = 1 : numOfCluster
    precisionEntropyArray(i) = unWeightedEntropy(precisionMatrix(i, :));
    recallEntropyArray(i) = unWeightedEntropy(recallMatrix(i, :));
    FScoreEntryArray(i) = unWeightedEntropy(FScoreMatrix(i, :));
end
precisionEntropy = mean(precisionEntropyArray);
recallEntropy = mean(recallEntropyArray);
FScoreEntropy = mean(FScoreEntryArray);
end

function [arrayEntropy] = unWeightedEntropy(array)
if(size(nonzeros(array), 1) == 0)
    arrayEntropy = 0;
else
    % it's weighted by the sum of similarity score
    denominator = sum(array);
    numerator = max(array);
    array = array/denominator;
    % compute entropy on 'array'
    % eps is machine eps defined by matlab
    % arrayEntropy = (-sum(array.*log2(array + eps))) * numerator;
    arrayEntropy = entropy(array) * numerator;
end
end