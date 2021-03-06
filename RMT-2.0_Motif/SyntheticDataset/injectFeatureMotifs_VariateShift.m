clc;
clear;
Mocap=1; %flag to consider the  flat variates of mocap
% pick a multi-variate feature
% cut off time sigma, inject as a multi-scale features, options for
% different variate groups injections as well

% FeaturePath = 'D:\Motif_Results\Datasets\Mocap\Features_RMT\1_euclid\';
current_OS = 'Mac'; % windows
if (strcmp(current_OS, 'windows') == 1)
    delimiter = '\';
else
    delimiter = '/';
end

TimeSeriesIndex = 2;
TS_name = num2str(TimeSeriesIndex);

% TEST = ['Mocap_test7', TS_name];
TEST_1 = ['Energy_Building', num2str(1)];
TEST_2 = ['Energy_Building', num2str(2)];

% FeaturePath = 'D:\Motif_Results\Datasets\Mocap\Features_RMT';
FeaturePath = '/Users/sliu104/Desktop/EnergyTestData/RMT';
FeaturePath = [FeaturePath, delimiter, num2str(TimeSeriesIndex), delimiter];
% DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\data';
% DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\data';
DestDataPath = ['/Users/sliu104/Desktop/EnergyTestData/InjectedFeatures_', num2str(TimeSeriesIndex)];

motifInjectionOption = 'Random'; % 'RoundRobin'
kindofBasicTS = 'randomWalk'; %'Sinusoidal';%'flat';%
if(strcmp(kindofBasicTS, 'flat') == 1)
    KindOfDataset = 'FlatTS_MultiFeatureDiffClusters\';
elseif(strcmp(kindofBasicTS, 'Sinusoidal') == 1)
    KindOfDataset = 'CosineTS_MultiFeatureDiffClusters\';%
elseif(strcmp(kindofBasicTS, 'randomWalk') == 1)
    KindOfDataset = 'RandomWalkTS_MultiFeatureDiffClusters\';%
end

% two values below not 1 or 0 at the same
multiScaleFeatureInjection = 0; % 0;
differentVariateGroupInjection = 1; % 0

sinFreq = 1;

% pick features from higher octaves
DepdO = 2; % octave depd
TimeO = 2; % octave time

NumInstances = 10; % inject into 10 locations
dpscale = [];
frame1 = [];

% read the depd involved for the corresponding features
% dpscale = csvread(strcat(FeaturePath, 'DistancesDescriptor\DepdScale_IM_', TS_name, '_DepO_', num2str(DepdO), '_TimeO_', num2str(TimeO), '.csv'));
dpscale = csvread(strcat(FeaturePath, 'DistancesDescriptor', delimiter, 'DepdScale_IM_', TS_name, '_DepO_', num2str(DepdO), '_TimeO_', num2str(TimeO), '.csv'));

savepath1 = [FeaturePath, 'feature_', TS_name, '.mat'];
savepath2 = [FeaturePath, 'idm_', TS_name, '.mat'];
savepath3 = [FeaturePath, 'MetaData_', TS_name, '.mat'];
load(savepath1);
load(savepath2);
load(savepath3);

% load metadata graph
metadataPath = [FeaturePath, 'idm_', num2str(TimeSeriesIndex), '.mat'];
idm = load(metadataPath);
idm = idm.idm1;

% So far only use features from higher octaves
indexfeatureGroup = (frame1(6,:) == TimeO & frame1(5,:) == DepdO);
featuresOfInterest = frame1(:, indexfeatureGroup);

[rows, columns] = size(featuresOfInterest);

% put time lengths and different variates check
% if they share the same variate or length keep looping

timeLengthFlag = 1;
variateFlag = 1;

% datarows : variates
% datacoln : time stamps
[datarows, datacoln] = size(data);

if(strcmp(kindofBasicTS, 'randomWalk') == 1)
    % rndWalks1 : 0 - 1
    % rndWalks2 : scaled range
    % both same size as original data
    time_stamps_scale = 0.01;
    [rndWalks1,rndWalks2] = rndWalkGenerationbigSize(size(data,1), floor(size(data, 2) * time_stamps_scale), data);
end

origRW1 = rndWalks1;
origRW2 = rndWalks2;
if Mocap==1 % silv consider the flat variate of mocap
    rndWalks2([34,46],:)=rndWalks1([34,46],:);
end
origRW2 = rndWalks2;
% FeatPositions: class label, time center of original features, time start, time end
FeatPositions = zeros(NumInstances, 4);

% avoid injecting features in the same position
Step = floor(size(rndWalks1, 2) / NumInstances); 

% count the injection location
pStep = 0; 
dpscale_injected=[];
if(multiScaleFeatureInjection == 1)
    % pick different locations, same group of variate for injection
    sameVariateGroup = 1;
    
    cutOffRate = 0.5;
    % pick features of different time scales
    [patternFeature, patternVariates] = pickLargestTimeSimgaFeaturesCutOff(featuresOfInterest, dpscale, cutOffRate);
    [rndWalks, FeatPositions, injectedVariates] = featureInject(patternFeature, patternVariates, sameVariateGroup, NumInstances, rndWalks, FeatPositions, data, idm, DepdO);
end

if(differentVariateGroupInjection == 1)
    % pick different locations, different group of variates for injection
    sameVariateGroup = 0;
    
    % pick feature that covers the smallest portion of variates
    [patternFeature, patternVariates] = pickSmallestVariateCoverageFeatures(featuresOfInterest, dpscale);
    [rndWalks1, FeatPositions1, injectedVariates1] = featureInject(patternFeature, patternVariates, sameVariateGroup, NumInstances, rndWalks1, FeatPositions, data, idm, DepdO);
    
    [rndWalks2, FeatPositions2, injectedVariates2] = featureInject(patternFeature, patternVariates, sameVariateGroup, NumInstances, rndWalks2, FeatPositions, data, idm, DepdO);
    dpscale_injected=[dpscale_injected,patternVariates];
end

if(exist([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter],'dir')==0)
    mkdir([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter]);
end
if(exist([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter],'dir')==0)
    mkdir([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter]);
end
csvwrite([DestDataPath, delimiter, TEST_1,'.csv'],rndWalks1);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, 'rndData_',TEST_1,'.csv'],origRW1);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'FeaturePosition_',TEST_1,'.csv'],FeatPositions1);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'dpscale_',TEST_1,'.csv'],dpscale_injected);%patternVariates);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'injectedDpscale_',TEST_1,'.csv'], injectedVariates1);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'FeaturesEmbedded_',TEST_1,'.csv'],patternFeature);

csvwrite([DestDataPath, delimiter, TEST_2,'.csv'],rndWalks2);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, 'rndData_',TEST_2,'.csv'],origRW2);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter, 'FeaturePosition_',TEST_2,'.csv'],FeatPositions2);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter, 'dpscale_',TEST_2,'.csv'],dpscale_injected);%patternVariates);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter, 'injectedDpscale_',TEST_2,'.csv'], injectedVariates2);
csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_2, delimiter, 'FeaturesEmbedded_',TEST_2,'.csv'],patternFeature);

fprintf('Manual injection done .\n');