clc;
clear;
DataType='Energy'; 
% DataType='Mocap';
% DataType='BirdSong';

featuresToInjectPath=['D:\Motif_Results\Datasets\SynteticDataset\',DataType,'\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\data\FeaturesToInject\'];%MOCAP
randomWalkPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DataType,'\RW_0_1\RW_'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\RW_0_1\RW_'];
% ['D:\Motif_Results\Datasets\SynteticDataset\data\RW_0_1\RW_'];
TimeSeriesPath = ['D:\Motif_Results\Datasets\',DataType,'\data\'];
%['D:\Motif_Results\Datasets\BirdSong\data\'];
%['D:\Motif_Results\Datasets\Mocap\data\'];

DestDataPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DataType];
%\BSONG';
NUM_VARIATE =27;%Energy;% 62;%MoCap;% 13;%BirdSong  %
random_walk_instance = 10;
motif_instances = 10; % MotifInstances= 10;
RWlength = 2500;
random_walk_scale = [0,0.1,0.25,0.5,0.75,1,2];%0.1;% randomWalkScale =
possibleMotifNUM=[1,2,3,10];%AllTS;%
length_percentage_1 = [1,0.75,0.5,1,0.75,0.5,1,0.75,0.5,1,0.75,0.5];%[1,0.75,0.5];
length_percentage=[];
for pssMotID =1:1%3
  randid= randperm(motif_instances);
  length_percentage=[length_percentage;length_percentage_1(randid)];
end
%                      0.75,0.5,1;
%                      1,0.5,0.75];%0.5;% length_percentage =
%originalTSIDArray=[23,35,86,111];%[1,3,6,7];%Energy %[64,70,80,147];%BirdSong; %[85,24,35,127];%Mocap
load([featuresToInjectPath,'allTSid.mat']);
originalTSIDArray=AllTS;









number_of_files = 10;

% only one option from below will work
pick_small_feature = 1;
pick_large_feature = 0;
pick_random_feature = 0;

current_OS = 'Mac'; % windows
if (strcmp(current_OS, 'windows') == 1)
    delimiter = '\';
else
    delimiter = '/';
end

TimeSeriesIndex = 1;
TS_name = num2str(TimeSeriesIndex);
% Data_Type = ['Energy_Building']; % MoCap
Data_Type = ['MoCap']; % MoCap

% FeaturePath = 'D:\Motif_Results\Datasets\Mocap\Features_RMT';
% DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\data';
if(strcmp(Data_Type, 'Energy_Building') == 1)
    FeaturePath = '/Users/sliu104/Desktop/EnergyTestData/RMT';
    DestDataPath = ['/Users/sliu104/Desktop/EnergyTestData/InjectedFeatures_', num2str(TimeSeriesIndex)];
else
    FeaturePath = '/Users/sliu104/Desktop/MoCapTestData/RMT';
    DestDataPath = ['/Users/sliu104/Desktop/MoCapTestData/InjectedFeatures_', num2str(TimeSeriesIndex)];
end

random_walk_path = ['/Users/sliu104/Desktop/RandomWalks_Generated/'];
FeaturePath = [FeaturePath, delimiter, num2str(TimeSeriesIndex), delimiter];

% pick features from higher octaves
DepdO = 2; % octave depd
TimeO = 2; % octave time

NumInstances = 10; % inject into 10 locations
frame1 = [];

% read the depd involved for the corresponding features
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

for nn = 1 : number_of_files
    TEST_1 = [Data_Type, num2str(nn)];
    
    % read randomwalk here
    % [rndWalks1,rndWalks2] = rndWalkGenerationbigSize(size(data,1), floor(size(data, 2) * time_stamps_scale), data);
    
    random_walk_file = [random_walk_path, 'RandomWalk_', num2str(nn), '.csv'];
    rndWalks1 = csvread(random_walk_file);
    
    % FeatPositions: class label, time center of original features, time start, time end
    FeatPositions = zeros(NumInstances, 4);
    
    % avoid injecting features in the same position
    Step = floor(size(rndWalks1, 2) / NumInstances);
    
    % count the injection location
    pStep = 0;
    
    % read features for injection
    % pick different locations, different group of variates for injection
    sameVariateGroup = 0;
    
    % pick feature that covers the smallest portion of variates
    if(pick_small_feature == 1)
        [patternFeature, patternVariates] = pickSmallestVariateCoverageFeatures(featuresOfInterest, dpscale);
    end
    
    if(pick_large_feature == 1)
        [patternFeature, patternVariates] = pickLargestVariateCoverageFeatures(featuresOfInterest, dpscale);
    end
    
    if(pick_random_feature == 1)
        [patternFeature, patternVariates] = pickRandomVariateCoverageFeatures(featuresOfInterest, dpscale);
    end
    [rndWalks1, FeatPositions1, injectedVariates1] = featureInject(patternFeature, patternVariates, sameVariateGroup, NumInstances, rndWalks1, FeatPositions, data, idm, DepdO);
    % dpscale_injected = [ dpscale_injected, patternVariates];
    
    if(exist([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter], 'dir')==0)
        mkdir([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter]);
    end
    
    csvwrite([DestDataPath, delimiter, TEST_1,'.csv'], rndWalks1);
    csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'FeaturePosition_', TEST_1, '.csv'], FeatPositions1);
    csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'dpscale_', TEST_1, '.csv'], injectedVariates1);
    % csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'injectedDpscale_', TEST_1, '.csv'], injectedVariates1);
    csvwrite([DestDataPath, delimiter, 'IndexEmbeddedFeatures', delimiter, TEST_1, delimiter, 'FeaturesEmbedded_', TEST_1, '.csv'], patternFeature);
end

fprintf('Manual injection done .\n');