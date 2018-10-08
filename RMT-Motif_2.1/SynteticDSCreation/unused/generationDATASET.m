clc;
clear;

% featuresToInjectPath=['/Users/sliu104/Desktop/Features_To_Inject/'];
% randomWalkPath =  ['/Users/sliu104/Desktop/RandomWalks_Generated/RandomWalk_'];
% TimeSeriesPath = ['/Users/sliu104/Desktop/TS_Data/'];
% DestDataPath = '/Users/sliu104/Desktop/RandomWalks_Injection_Generated';

featuresToInjectPath=['D:\Motif_Results\Datasets\SynteticDataset\data\FeaturesToInject\'];
randomWalkPath =  ['D:\Motif_Results\Datasets\SynteticDataset\data\RandomWalks\RandomWalk_'];
TimeSeriesPath = ['D:\Motif_Results\Datasets\Mocap\data\'];
DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\data';


num_of_motif = 1; % NumOfMotifs = 1;
motif_instances = 10; % MotifInstances= 10;
random_walk_instance = 10;

length_percentage = [1,0.75,0.5];%0.5;% length_percentage =
RWlength = 2500;
random_walk_scale = [0.1,0.5,0.75,1];%0.1;% randomWalkScale =

descr_non_zero_entry = 50;%10;% %  percentage 10, 50

% name used for output
testNAME = ['MotifVariateSync',num2str(num_of_motif)];

% load  the features and the data
FeaturesToInject = csvread([featuresToInjectPath,'Features',num2str(originalTSID),'_',num2str(descr_non_zero_entry),'.csv']);
DepdToInject = csvread([featuresToInjectPath,'depd',num2str(originalTSID),'_',num2str(descr_non_zero_entry),'.csv']);
TSdata = csvread([TimeSeriesPath,num2str(originalTSID),'.csv'])';


FeatureToInject= FeaturesToInject(:,1:num_of_motif);
DepdToInject = DepdToInject(:,1:num_of_motif);
MotifsSections=[];
offSpace=0;

for MotifId =1: num_of_motif
    timescope= FeatureToInject(4,MotifId)*3;
    intervaltime=(round((FeatureToInject(2,MotifId)-timescope)) : (round((FeatureToInject(2,MotifId)+timescope+offSpace))));
    MotifsSections{MotifId}.data = TSdata(:,intervaltime((intervaltime>0 & intervaltime<=size(TSdata,2))));
    MotifsSections{MotifId}.depd = DepdToInject(:,MotifId);
    MotifsSections{MotifId}.cols = size(MotifsSections{MotifId}.data,2);
end

% load idm graph clustering information
metadataPath = [featuresToInjectPath, 'idm.mat'];
idm = load(metadataPath);
idm = idm.idm1;

startInj=15;
Step= floor(RWlength/(motif_instances*num_of_motif));
startTime =zeros(1,motif_instances*num_of_motif);
starterTime(1) = startInj ;
LabelMotif = [];

% inject the same motif at the same position if more than one motif injected
for i =1: num_of_motif
    LabelMotif=[LabelMotif,ones(1,motif_instances)*i];
end
LabelMotif = LabelMotif( randperm(length(LabelMotif))) ;

pStep=0;
% total number of motifs to be injected
for i=1:motif_instances * num_of_motif
    motifclmn = MotifsSections{LabelMotif(i)}.cols;
    starterTime (i)= randi([startInj+pStep,startInj+pStep+Step-motifclmn],1,1);
    pStep=pStep+Step;
end
Counter =1;
TSNAMEFIX=testNAME;

% for rwscale = 1 : size(random_walk_scale,2)
for i = 1 : random_walk_instance
    % read the 0-1 randomwalk
    testNAME = [TSNAMEFIX,'_',num2str(originalTSID),'_instance_',num2str(Counter)];
    EachInstanceDependency=[];
    randomwalkData = csvread([randomWalkPath,num2str(i),'.csv']);
    %             minvalueTS = min(TSdata');
    %             maxvalueTS = max(TSdata');
    %             Motif1RW = scaleRW(randomwalkData,maxvalueTS,minvalueTS,random_walk_scale(rwscale));
    Motif1RW = randomwalkData;
    FeatPositions = zeros(motif_instances * num_of_motif,4);
    
    % do the job
    for motifInstance = 1: motif_instances * num_of_motif
        MotifID = LabelMotif(motifInstance);
        length_index = mod(motifInstance, length(length_percentage)); % round robin manner if more than one motifs to be injected
        if(length_index == 0)
            length_index = size(length_percentage, 2);
        end
        M1 = imresize( MotifsSections{MotifID}.data,[size( MotifsSections{MotifID}.data,1), size( MotifsSections{MotifID}.data,2)*length_percentage(length_index)]);
        scalingTime =size(M1,2);
        
        % shift motif variate group
        current_variate_group = MotifsSections{MotifID}.depd(:,1);
        Depd_O = 2;
        
        nonZeropatternDepdScale = current_variate_group(current_variate_group ~= 0);
        variate_groups = computeVariateGroup(nonZeropatternDepdScale, idm, Depd_O, current_variate_group);
        
        % round robin to pick variate group
        length_index = mod(motifInstance, length(length_percentage)); % round robin manner if more than one motifs to be injected
        if(length_index == 0)
            length_index = size(length_percentage, 2);
        end
        variate_group_index = mod(motifInstance, motif_instances * num_of_motif);
        if(variate_group_index == 0)
            variate_group_index = size(variate_groups, 2);
        end
        variate_group_for_injection = variate_groups(:, variate_group_index);
        
        Motif1RW(variate_group_for_injection, starterTime(motifInstance) : starterTime(motifInstance) + scalingTime - 1) = ...
            M1(MotifsSections{MotifID}.depd(current_variate_group > 0, 1),:);
        
        FeatPositions(motifInstance,:) = [ MotifID,motifInstance, starterTime(motifInstance), starterTime(motifInstance)+scalingTime-1 ];
        EachInstanceDependency = [ EachInstanceDependency, variate_group_for_injection ];
    end
    if(exist([DestDataPath,'/IndexEmbeddedFeatures/'],'dir')==0)
        mkdir([DestDataPath,'/IndexEmbeddedFeatures/']);
    end
    csvwrite([DestDataPath,'/',testNAME,'.csv'],Motif1RW);
    csvwrite([DestDataPath,'/IndexEmbeddedFeatures/','FeaturePosition_',testNAME,'.csv'],FeatPositions);%,testNAME,'\'
    csvwrite([DestDataPath,'/IndexEmbeddedFeatures/','dpscale_',testNAME,'.csv'],EachInstanceDependency);
    csvwrite([DestDataPath,'/IndexEmbeddedFeatures/','Parameters_',testNAME,'.csv'],[originalTSID;num_of_motif;motif_instances;i;]);%random_walk_scale(rwscale)]);
    Counter=Counter+1;
    
%     if(exist([DestDataPath,'\IndexEmbeddedFeatures\'],'dir')==0)
%         mkdir([DestDataPath,'\IndexEmbeddedFeatures\']);
%     end
%     csvwrite([DestDataPath,'\',testNAME,'.csv'],Motif1RW);
%     csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','FeaturePosition_',testNAME,'.csv'],FeatPositions);%,testNAME,'\'
%     csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','dpscale_',testNAME,'.csv'],EachInstanceDependency);
%     csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','Parameters_',testNAME,'.csv'],[originalTSID;num_of_motif;motif_instances;i;]);%random_walk_scale(rwscale)]);
%     Counter=Counter+1;
end

fprintf('Feature injection done .\n');