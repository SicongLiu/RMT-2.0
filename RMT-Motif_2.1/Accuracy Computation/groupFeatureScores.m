function [precision, recall] = groupFeatureScores(statEntry, currentInjectedClassID, relevantSize, currentRetrievedSize, threshold, timeOverlapThreshold)

myStatEntry = statEntry(statEntry(:, 5) == currentInjectedClassID, :);
[uniqueRows, firstIndex, membershipIndex] = unique( myStatEntry(:,[7 8]), 'rows');
uniqueSize = size(uniqueRows, 1);
precisionScore = zeros(relevantSize, 1);
recallBestScore = zeros(uniqueSize, 1);

for i = 1 : uniqueSize
    resultIndex = find(membershipIndex(:) == i);
    bestTO = max(myStatEntry(resultIndex, 9));
    bestVO = max(myStatEntry(resultIndex, 10));
    
    recallBestScore(i) = bestTO * bestVO;
    if(bestTO >= timeOverlapThreshold && recallBestScore(i) >= threshold)
        recallBestScore(i) = 1;
    else
        recallBestScore(i) = 0;
    end
end

for i = 1 : size(myStatEntry, 1)
    score_TO = myStatEntry(i, 9);
    score_VO = myStatEntry(i, 10);
    
    precisionScore(i) = score_TO * score_VO;
    if(score_TO >= timeOverlapThreshold && precisionScore(i) >= threshold)
        precisionScore(i) = 1;
    else
        precisionScore(i) = 0;
    end
end

if(sum(precisionScore) == 0.75 || sum(recallBestScore) == 1)
    % skip the case that in the cluster there is only one motif matched the inserted one
    precision = 0;
    recall = 0;
else
    precision = sum(precisionScore) / currentRetrievedSize;
    recall = sum(recallBestScore) / relevantSize;
end