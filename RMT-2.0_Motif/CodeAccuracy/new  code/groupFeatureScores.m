function [precision, recall] = groupFeatureScores(statEntry, currentInjectedClassID, relevantSize, currentRetrievedSize, threshold)

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
    if(recallBestScore(i) >= threshold)
        recallBestScore(i) = 1;
    else
        recallBestScore(i) = 0;
    end
end

for i = 1 : size(myStatEntry, 1)
    score_TO = myStatEntry(i, 9);
    score_VO = myStatEntry(i, 10);
    
    precisionScore(i) = score_TO * score_VO;
    if(precisionScore(i) >= threshold)
        precisionScore(i) = 1;
    else
        precisionScore(i) = 0;
    end
end
precision = sum(precisionScore) / currentRetrievedSize;
recall = sum(recallBestScore) / relevantSize;
