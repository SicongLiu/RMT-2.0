function [timeOverlap] = computeTimeOverlap(timeStart, timeEnd, injectedTimeStart, injectedTimeEnd)
% timeOverlap = zeros(size(timeStart, 1), 1);
minEnd = min(timeEnd, injectedTimeEnd);
maxStart = max(timeStart, injectedTimeStart);
minStart = min(timeStart, injectedTimeStart);
maxEnd = max(timeEnd, injectedTimeEnd);
previusdenominator= (maxEnd - minStart);
InjectedFeatureScope= injectedTimeEnd-injectedTimeStart;
timeOverlap = (minEnd - maxStart)./InjectedFeatureScope;
end

