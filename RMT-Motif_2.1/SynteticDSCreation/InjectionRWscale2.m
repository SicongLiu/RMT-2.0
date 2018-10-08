clear;
clc;

DatasetTouse='BirdSong';%'Energy';%'Mocap';% 
featuresToInjectPath=['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse,'\data\','\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\data\FeaturesToInject\'];%MOCAP
randomWalkPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse,'\data\','\RW_0_1\RW_'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\RW_0_1\RW_'];
% ['D:\Motif_Results\Datasets\SynteticDataset\data\RW_0_1\RW_'];
TimeSeriesPath = ['D:\Motif_Results\Datasets\',DatasetTouse,'\data\'];
%['D:\Motif_Results\Datasets\BirdSong\data\'];
%['D:\Motif_Results\Datasets\Mocap\data\'];

DestDataPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse,'\data'];

load([featuresToInjectPath,'allTSid.mat']);

NUM_VARIATE =13;%BirdSong  %27;%Energy;%62;%MoCap;%  13;%BirdSong  %

random_walk_instance = 10;
motif_instances = 10; % MotifInstances= 10;
RWlength = 2500;
originalTSIDArray=AllTS;
random_walk_scale=2;
for orgID =1:30%length(originalTSIDArray)%2
    originalTSID=originalTSIDArray(orgID)
    for pssMotID = 1:3
        id_test_name='Motif';
num_of_motif = pssMotID;
        testNAME = [id_test_name,num2str(num_of_motif)];%
        FeaturesToInject = csvread([featuresToInjectPath,'Features',num2str(originalTSID),'.csv']);%,'_',num2str(descr_non_zero_entry),'.csv']);
        DepdToInject = csvread([featuresToInjectPath,'depd',num2str(originalTSID),'.csv']);
        
        %% MOCAP BirdSong
        TSdata = csvread([TimeSeriesPath,num2str(originalTSID),'.csv'])';
        %% Energy
%                 TSdata = csvread([TimeSeriesPath,num2str(originalTSID),'.csv']);% remove ' for Energy;
        FeatureToInject= FeaturesToInject(:,1:num_of_motif);
        DepdToInject = DepdToInject(:,1:num_of_motif);
        for MotifId =1: num_of_motif
            timescope= FeatureToInject(4,MotifId)*3; % 29
            intervaltime=(round((FeatureToInject(2,MotifId)-timescope)) : (round((FeatureToInject(2,MotifId)+timescope+0))));
            MotifsSections{MotifId}.data = TSdata(:,intervaltime((intervaltime>0 & intervaltime<=size(TSdata,2))));
            MotifsSections{MotifId}.depd = DepdToInject(:,MotifId);
            MotifsSections{MotifId}.cols = size(MotifsSections{MotifId}.data,2);
        end
         TSNAMEFIX=testNAME;
        for i =1 : random_walk_instance
            testNAME = [TSNAMEFIX,'_',num2str(originalTSID),'_instance_',num2str(i)];
            PreviousInjectionPosition =csvread([DestDataPath,'\IndexEmbeddedFeatures\','FeaturePosition_',testNAME,'_',num2str(1),'.csv']);
            
            EachInstanceDependency=[];
            FeatPositions = zeros(motif_instances*num_of_motif,4);%NEW
            randomwalkData = csvread([randomWalkPath,num2str(i),'.csv']);
            NormInterval=[zeros(NUM_VARIATE,1),ones(NUM_VARIATE,1)];
            
            if random_walk_scale~=0
                NormInterval(:,1)= (min(TSdata')*random_walk_scale)';
                NormInterval(:,2)= (max(TSdata')*random_walk_scale)';
                randomwalkData= NormalizeRandomWalk(randomwalkData,NormInterval,0);
            end
            Motif1RW=randomwalkData;
            for motifInstances = 1: size(PreviousInjectionPosition,1)
                MotifID = PreviousInjectionPosition(motifInstances,1);
                M1 = imresize( MotifsSections{MotifID}.data,[size( MotifsSections{MotifID}.data,1), PreviousInjectionPosition(motifInstances,4)-PreviousInjectionPosition(motifInstances,3)+1]);
                scalingTime =size(M1,2);
                Motif1RW(MotifsSections{MotifID}.depd((MotifsSections{MotifID}.depd(:,1)>0),1),PreviousInjectionPosition(motifInstances,3):PreviousInjectionPosition(motifInstances,4))=...
                    M1(MotifsSections{MotifID}.depd(MotifsSections{MotifID}.depd(:,1)>0,1),:);
                FeatPositions(motifInstances,:)=[MotifID,motifInstances,PreviousInjectionPosition(motifInstances,3),PreviousInjectionPosition(motifInstances,4)];
                EachInstanceDependency=[EachInstanceDependency, MotifsSections{MotifID}.depd ];
            end
            if(exist([DestDataPath,'\IndexEmbeddedFeatures\'],'dir')==0)
                mkdir([DestDataPath,'\IndexEmbeddedFeatures\']);
            end
            csvwrite([DestDataPath,'\',testNAME,'_',num2str(random_walk_scale),'.csv'],Motif1RW);
            csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','FeaturePosition_',testNAME,'_',num2str(random_walk_scale),'.csv'],FeatPositions);%,testNAME,'\'
            csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','dpscale_',testNAME,'_',num2str(random_walk_scale),'.csv'],EachInstanceDependency);
            %               csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','ORGRW',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],randomwalkData);
            %               csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','Parameters_',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],[originalTSID;num_of_motif;motif_instances;i;random_walk_scale(rwscale)]);
        end
    end
    
    
end