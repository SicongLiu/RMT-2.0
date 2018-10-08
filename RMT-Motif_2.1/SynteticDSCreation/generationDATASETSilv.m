clc;
clear;
DatasetTouse='Energy';%'Mocap';% 'BirdSong';%
featuresToInjectPath=['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse,'\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\FeaturesToInject\'];
%['D:\Motif_Results\Datasets\SynteticDataset\data\FeaturesToInject\'];%MOCAP
randomWalkPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse,'\RW_0_1\RW_'];
%['D:\Motif_Results\Datasets\SynteticDataset\BSONG\RW_0_1\RW_'];
% ['D:\Motif_Results\Datasets\SynteticDataset\data\RW_0_1\RW_'];
TimeSeriesPath = ['D:\Motif_Results\Datasets\',DatasetTouse,'\data\'];
%['D:\Motif_Results\Datasets\BirdSong\data\'];
%['D:\Motif_Results\Datasets\Mocap\data\'];

DestDataPath = ['D:\Motif_Results\Datasets\SynteticDataset\',DatasetTouse];
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
for orgID =1:30%length(originalTSIDArray)%2
    originalTSID=originalTSIDArray(orgID)%85;%127;%[24,35,85,127];85;%24;%35;%
    %\data'; %for MOCAP
   
    for pssMotID = 1:1% 3%length(possibleMotifNUM)%4:4
        num_of_motif = possibleMotifNUM(pssMotID);%3; % NumOfMotifs = 1;

        
        
        % descr_non_zero_entry =  10;% 10;% percentage 10, 50
           
        id_test_name='Motif';
        % testNAME = ['100_Motif_',num2str(motif_instances),'_',num2str(num_of_motif)];
        testNAME = [id_test_name,num2str(num_of_motif)];%,'_',num2str(originalTSID)];%num2str(motif_instances),'_',num2str(num_of_motif)];
        
        % load  the features and the data
        FeaturesToInject = csvread([featuresToInjectPath,'Features',num2str(originalTSID),'.csv']);%,'_',num2str(descr_non_zero_entry),'.csv']);
        DepdToInject = csvread([featuresToInjectPath,'depd',num2str(originalTSID),'.csv']);%,'_',num2str(descr_non_zero_entry),'.csv']);
        
        %% MOCAP BirdSong
%         TSdata = csvread([TimeSeriesPath,num2str(originalTSID),'.csv'])';
        %% Energy
         TSdata = csvread([TimeSeriesPath,num2str(originalTSID),'.csv']);% remove ' for Energy;
        
        FeatureToInject= FeaturesToInject(:,1:num_of_motif);
        DepdToInject = DepdToInject(:,1:num_of_motif);
        MotifsSections=[];
        offSpace=0;
        for MotifId =1: num_of_motif
            timescope= FeatureToInject(4,MotifId)*3; % 29
            intervaltime=(round((FeatureToInject(2,MotifId)-timescope)) : (round((FeatureToInject(2,MotifId)+timescope+offSpace))));
            MotifsSections{MotifId}.data = TSdata(:,intervaltime((intervaltime>0 & intervaltime<=size(TSdata,2))));
            MotifsSections{MotifId}.depd = DepdToInject(:,MotifId);
            MotifsSections{MotifId}.cols = size(MotifsSections{MotifId}.data,2);
        end
        startInj=30;
        Step= floor( RWlength/(motif_instances*num_of_motif));
        startTime =zeros(1,motif_instances*num_of_motif);
        starterTime(1) = startInj ;
        LabelMotif = [];
        for i =1: num_of_motif
            LabelMotif=[LabelMotif,ones(1,motif_instances)*i];
        end
        LabelMotif = LabelMotif( randperm(length(LabelMotif))) ;
        pStep=0;
        for i=1:motif_instances*num_of_motif
            motifclmn = MotifsSections{LabelMotif(i)}.cols;
            starterTime (i)= randi([startInj+pStep,startInj+pStep+Step-motifclmn],1,1);
            pStep=pStep+Step;
        end
        % Counter =1;
        TSNAMEFIX=testNAME;
        for rwscale = 1 : size(random_walk_scale,2)
            for i =1 : random_walk_instance
                % read the 0-1 randomwalk
                
                testNAME = [TSNAMEFIX,'_',num2str(originalTSID),'_instance_',num2str(i)];
                
                
                EachInstanceDependency=[];
                randomwalkData = csvread([randomWalkPath,num2str(i),'.csv']);
                NormInterval=[zeros(NUM_VARIATE,1),ones(NUM_VARIATE,1)];
                
                if random_walk_scale(rwscale)~=0
                    NormInterval(:,1)= (min(TSdata')*random_walk_scale(rwscale))';
                    NormInterval(:,2)= (max(TSdata')*random_walk_scale(rwscale))';
                    randomwalkData= NormalizeRandomWalk(randomwalkData,NormInterval,0);
                end
                Motif1RW=randomwalkData;
                %             minvalueTS = min(TSdata');
                %             maxvalueTS = max(TSdata');
                %         Motif1RW = scaleRW(randomwalkData,maxvalueTS,minvalueTS,random_walk_scale(rwscale));
                
                FeatPositions = zeros(motif_instances*num_of_motif,4);%NEW
                idxMotifID(:)=ones(3,1);%NEW
                for motifInstance = 1: motif_instances*num_of_motif
                    MotifID=LabelMotif(motifInstance);
                    
                    
                    length_index = length_percentage(MotifID,idxMotifID(MotifID));
                    %  length_index =  mod(motifInstance, length(length_percentage));
                    idxMotifID(MotifID)=idxMotifID(MotifID)+1;
                    if(length_index == 0)
                        length_index = size(length_percentage, 2);
                    end
                    M1 = imresize( MotifsSections{MotifID}.data,[size( MotifsSections{MotifID}.data,1), size( MotifsSections{MotifID}.data,2)*length_index]);%length_percentage(length_index)]);
                    scalingTime =size(M1,2);
                    
                    Motif1RW(MotifsSections{MotifID}.depd((MotifsSections{MotifID}.depd(:,1)>0),1),starterTime(motifInstance):starterTime(motifInstance)+scalingTime-1) = ...
                        M1(MotifsSections{MotifID}.depd(MotifsSections{MotifID}.depd(:,1)>0,1),:);
                    
                    FeatPositions(motifInstance,:)=[MotifID,motifInstance,starterTime(motifInstance),starterTime(motifInstance)+scalingTime-1];
                    EachInstanceDependency=[EachInstanceDependency, MotifsSections{MotifID}.depd ];
                end
                
                if(exist([DestDataPath,'\IndexEmbeddedFeatures\'],'dir')==0)
                    mkdir([DestDataPath,'\IndexEmbeddedFeatures\']);
                end
                csvwrite([DestDataPath,'\',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],Motif1RW);
                csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','FeaturePosition_',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],FeatPositions);%,testNAME,'\'
                csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','dpscale_',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],EachInstanceDependency);
 %               csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','ORGRW',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],randomwalkData);
                csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','Parameters_',testNAME,'_',num2str(random_walk_scale(rwscale)),'.csv'],[originalTSID;num_of_motif;motif_instances;i;random_walk_scale(rwscale)]);
                %         Counter=Counter+1;
            end
            
            %     mkdir([DestDataPath,'\IndexEmbeddedFeatures\Mocap_test',num2str(name+6),'\']);
        end
    end
end