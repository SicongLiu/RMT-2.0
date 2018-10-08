close all;
clc;
clear;
LocM1 =[0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0
    ];

LocM2=[0	1	1	0	0	0	0	0	0	0	0	0
    1	0	0	0	0	0	0	0	0	0	0	0
    1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	1	1	0	0	0	0	0	0
    0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	1	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	1	1
    0	0	0	0	0	0	0	0	0	1	0	0
    0	0	0	0	0	0	0	0	0	1	0	0];
LocM3=[];
IDM1=1:27;
IDM2= [1,2,3,1,2,3,4,5,6,7,8,9,4,5,6,4,5,6,7,8,9,10,11,12,10,11,12];
IDM3=[];

idm2{1} = IDM1;
idm2{2} = IDM2;
idm2{3} = IDM3;



DatasetInject=2;  % 1 Energy 2 syntethic Energy
SubDSPath='data\';%'FlatTS_MultiFeatureDiffClusters\';%'CosineTS_MultiFeatureDiffClusters\';%'MultiFeatureDiffClusters\';
datasetPath= 'D:\Motif_Results\Datasets\Energy\';
if (DatasetInject==2)
    datasetPath= 'D:\Motif_Results\Datasets\SynteticDataset\Energy\';
end
load([datasetPath,'data\FeaturesToInject\allTSid.mat']);
subfolderPath= '';%'Z_A_Temp_C\';%
FeaturesRM ='RMT';
% Flag to abilitate portions of code
CreateRelation = 0;%1;
FeatureExtractionFlag = 1;%1;% 1; % 1 do it others  skip
createDependencyScale = 1;%1;
%% clustering abilitation
Cluster =  1;%1;%

justSubCluster=0; % in the case of strategy 3  we can do just  subclusteringt
%% Parameter for kmeans: distance measure to use
kmeans_Descmetric='euclidean';%'cosine';%'cityblock';%
distanceUsed='Descriptor';% use just descriptors to  cluster
% the algorithm of clustering to use

%

%% cluster pruning and printing of the  motifs
pruneCluster = 1;%0 % execute  the pruning using #prunewith removing the  outbound features in each  cluster
prunewith='Descriptor';% use this strategy to prune  the outbound features ina  cluster

%% printing functionality
saveMotifBP = 0; % show the clusters before pruning
saveMotifAP = 0; % show the clusters after  pruning

savecaracteristics = 1;
% showOriginalImage = 0;

%% Parameters
Num_SyntSeries=10; % num of instances of one motif
Name_OriginalSeries = AllTS;
%[23,35,86,111];% MOCap Motif10 %[1,3,6,7];%ENERGY %[85,35,127,24];MOCAP % name of the original  series from with we  got the  motif instances to inject


%% sift parameters
% x - variate
% y - time
% oframes - octaves
% sigmad - sigma dependency (variate)
% sigmat - sigma time (time)
% pricur - principle curvature
USER_OT_targhet=2;
USER_OD_targhet=2;

DeOctTime = USER_OT_targhet;
DeOctDepd = USER_OD_targhet;
DeLevelTime = 4;%6;
DeLevelDepd = 4;%6;
DeSigmaDepd = 0.5;%
DeSigmaTime = 1.6*2^(1/DeLevelTime);%
DeGaussianThres = 0.1;%
if DatasetInject == 1 % Energy Building
    DeSigmaDepd = 0.5;%0.6;%0.5;%0.4;%
    DeSigmaTime = 4*sqrt(2)/2;%1.6*2^(1/DeLevelTime)*2;%4*sqrt(2);%1.6*2^(1/DeLevelTime);%4*sqrt(2);%2*1.6*2^(1/DeLevelTime);%  8;%4*sqrt(2);%1.2*2^(1/DeLevelTime);%
    DeGaussianThres = 0.3;%0.3;%0.1;%0.4;%1;%0.6;%2;%6; % TRESHOLD with the normalization of hte distance matrix should be  between 0 and 1
elseif DatasetInject == 2 % MoCap
    DeSigmaDepd = 0.5;%1.6*2^(1/(DeLevelTime));%0.3;%0.4;%0.6;%0.5;%0.4;%
    DeSigmaTime = 4*sqrt(2)/2;%
    DeGaussianThres = 0.1;%
end
thresh = 0.04 / DeLevelTime / 2 ;%0.04;%
DeSpatialBins = 4; %NUMBER OF BINs
r= 10; %5 threshould variates
percent=[0; 0.1;0.25;0.5;0.75;1;2];

strategy=[1,3,4,6,7,9];%[1,2,3,4,5,6,7,8,9];
for strID =1:size(strategy,2)%9%1:6
    StrategyClustering= strategy(strID)%2;%1;%3;%
    % 1 - create cluster of feature for the very same  varaites then  in each cluster do  adaptive kmeans on descriptors
    % 2 - create cluster of feature  on similar variates using Adaptive Kmeans then  for each cluster use adaptive kmeans on descriptors
    % 3 - old approach do clustering  then subclustering
    if(StrategyClustering > 1)
        FeatureExtractionFlag=0;
        createDependencyScale=0;
    end
    kindOfClustring= 'AKmeans';
    if StrategyClustering >3
        kindOfClustring= 'DBScan';%
    end
    for percentid=7:7%1:size(percent,1)
        percentagerandomwalk=percent(percentid)%0; %0.1;%0.5;%0.75;%
        
        for MOTIFNUMber =1:3
            for pip=1:30   %TSnames
                for NAME = 1:Num_SyntSeries
                    Time4Clustering=0;%zeros(1,4);
                    TIMEFOROCTAVE=0;%zeros(1,4);
                    TimeComputationDepdScale =0;% zeros(1,4);
                    TimeforPruningClustering =0;%zeros(1,4);
                    TimeforPruningSubClustering=0;%zeros(1,4);
                    timeforSubclustering=0;
                    TEST=['Motif',num2str(MOTIFNUMber),'_',num2str(Name_OriginalSeries(pip)),'_instance_',num2str(NAME),'_',num2str(percentagerandomwalk)];%TEST = ['Energy_test',num2str(NAME)];
                    %TEST=['Motif',num2str(MOTIFNUMber),'_',num2str(Name_OriginalSeries(pip)),'_instance_',num2str(NAME),'_',num2str(percentagerandomwalk)];
                    
                    
                    %                     %% read location matrix
                                         TS_name=TEST;
                    %                     distanceVaraiteTS=[];
                    %                     if DatasetInject == 1 %Energy
                    %                         distanceVaraiteTS=[datasetPath,'HopMatrix_multistory_aggregate.csv'];%'HopMatrix_multistory.csv'];
                    %                     elseif DatasetInject == 2 % MoCap
                    %                         distanceVaraiteTS=[datasetPath,'LocationMatrixMocap.csv'];%
                    %                     end
                    %                     % read coordinates
                    %                     coordinates=[];
                    %                     if DatasetInject == 1 %Energy
                    %                         coordinates=csvread(strcat(datasetPath,'location\LocationSensor_aggregate.csv'));
                    %                     elseif DatasetInject == 2 % MoCap
                    %                         coordinates=csvread(strcat(datasetPath,'location\LocationMatrixMocap.csv'));%
                    %                     end
                    %                     RELATION=coordinates;
                    
                    data = csvread([datasetPath,SubDSPath,TS_name,'.csv']);%double(imread([imagepath,specificimagepath,imagename,'.jpg']));%
                    
                    %% Features Extraction
                    if(FeatureExtractionFlag==1)
                        saveFeaturesPath=[datasetPath,subfolderPath,'Features_',FeaturesRM,'\',TS_name,'\'];%,EntropyPruningFolder];
                        if(exist(saveFeaturesPath,'dir')==0)
                            mkdir(saveFeaturesPath);
                            mkdir([saveFeaturesPath,'GaussianSmoothing\']);
                        end
                        sBoundary=1;
                        eBoundary=size(data',1);
                        frames1=[];
                        descr1=[];
                        gss1=[];
                        dogss1=[];
                        depd1=[];
                        idm1=[];
                        time=[];
                        timee=[];
                        timeDescr=[];
                        p=tic;
                        if(strcmp(FeaturesRM,'RMT')) % we can add other  features methods
                            [frames1,descr1,gss1,dogss1,depd1,idm1, time, timee, timeDescr] = ...
                                sift_gaussianSmooth_BirdSong(data',...
                                LocM1 ,LocM2,LocM3,IDM1, IDM2, IDM3, DeOctTime, DeOctDepd,...
                                DeLevelTime, DeLevelDepd, DeSigmaTime ,DeSigmaDepd,...
                                DeSpatialBins, DeGaussianThres, r, sBoundary, eBoundary);
                            %% Genuine code
                            %                [frames1,descr1,gss1,dogss1,depd1,idm1, time, timee, timeDescr] = sift_gaussianSmooth_Silv(data',RELATION, DeOctTime, DeOctDepd,...
                            %                                 DeLevelTime, DeLevelDepd, DeSigmaTime ,DeSigmaDepd,...
                            %                                 DeSpatialBins, DeGaussianThres, r, sBoundary, eBoundary);
                        end
                        while(size(frames1,2)==0)
                            frames1 = zeros(4,1);
                            descr2 = zeros(128,1);
                        end
                        frame1 = [frames1;descr1];
                        if( isnan(sum(descr1(:))))
                            TS_name
                            nanIDX=  isnan(sum(descr1));
                            frame1(:,nanIDX)  = [];
                            descr1(:,nanIDX)  = [];
                            frames1(:,nanIDX) = [];
                        end
                        frame1(7,:) = [];
                        feature = frame1;
                        TIMEFOROCTAVE=toc(p);
                        savepath1 = [saveFeaturesPath,'feature_',TS_name,'.mat'];
                        savepath2 = [saveFeaturesPath,'idm_',TS_name,'.mat'];
                        savepath3 = [saveFeaturesPath,'MetaData_',TS_name,'.mat'];
                        savepath5 = [saveFeaturesPath,'GaussianSmoothing/DepdMatrix_',TS_name,'.mat'];
                        
                        savepath6 = [saveFeaturesPath,'/ComparisonTime_',TS_name,'.csv'];
                        savepath7 = [saveFeaturesPath,'/ScaleTime_',TS_name,'.csv'];
                        savepath8 = [saveFeaturesPath,'/DescrTime_',TS_name,'.csv'];
                        
                        save(savepath1,'data', 'gss1', 'frame1','depd1');
                        save(savepath2,'idm1');
                        save(savepath3,'DeOctTime', 'DeOctDepd', 'DeSigmaTime','DeSigmaDepd', 'DeLevelTime','DeLevelDepd', 'DeGaussianThres', 'DeSpatialBins', 'r', 'descr1' );
                        save(savepath5, 'depd1');
                    end
                    %% create dependency
                    if(createDependencyScale==1)
                        saveFeaturesPath=[datasetPath,subfolderPath,'Features_',FeaturesRM,'\',TEST,'\'];
                        %% read the features
                        savepath1 = [saveFeaturesPath,'feature_',TS_name,'.mat'];
                        savepath2 = [saveFeaturesPath,'idm_',TS_name,'.mat'];
                        savepath3 = [saveFeaturesPath,'MetaData_',TS_name,'.mat'];
                        saveCSVDepd= strcat(saveFeaturesPath,'Distances',distanceUsed,'\DepdScale_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv');
                        savevectorDepd = strcat(saveFeaturesPath,'Distances',distanceUsed,'\DepdScopeVector_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv');
                        %             TimeComputationDepdScale(USER_OT_targhet+USER_OD_targhet-1) = Crete_saveDepdScale(savepath1,savepath2,savepath3,USER_OT_targhet,USER_OD_targhet,saveCSVDepd,savevectorDepd,strcat(saveFeaturesPath,'Distances',distanceUsed,'\'));
                        TimeComputationDepdScale = Crete_saveDepdScale(savepath1,savepath2,savepath3,USER_OT_targhet,USER_OD_targhet,saveCSVDepd,savevectorDepd,strcat(saveFeaturesPath,'Distances',distanceUsed,'\'));
                    end
                    
                    if (Cluster==1 | justSubCluster==1)
                        %% read the  features
                        saveFeaturesPath=[datasetPath,subfolderPath,'Features_',FeaturesRM,'\',TS_name,'\'];
                        savepath1 = [saveFeaturesPath,'feature_',TS_name,'.mat'];
                        savepath2 = [saveFeaturesPath,'idm_',TS_name,'.mat'];
                        savepath3 = [saveFeaturesPath,'MetaData_',TS_name,'.mat'];
                        
                        load(savepath1);
                        load(savepath2);
                        load(savepath3);
                        indexfeatureGroup = (frame1(6,:)==USER_OT_targhet & frame1(5,:)==USER_OD_targhet);
                        X=frame1(:,indexfeatureGroup);
                        DepdScopeVector=csvread(strcat(saveFeaturesPath,'Distances',distanceUsed,'\DepdScopeVector_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv'));
                        tic
                        if (StrategyClustering == 1 | StrategyClustering == 4| StrategyClustering == 7) %% we are interested into  same dependency scope
                            possibleset= unique(X(1,:));
                            AlltheCluster=[];
                            Allthefeatures=[];
                            Centroids =[];
                            allclusterid=0;
                            for classidlabel= 1:size(possibleset,2) % for each set of varaites  create a cluster
                                idactfeatures= frame1(1,:)==possibleset(classidlabel);
                                ActFeatures = X(:,idactfeatures);
                                if(strcmp(kindOfClustring,'AKmeans')==1)
                                    if(size(ActFeatures,2)<=2)
                                        C=ones(size(ActFeatures,2),1)+allclusterid;
                                        mu=ActFeatures(11:end,1)';
                                    else
                                        [C,mu,inertia,tryK,startK]= adaptiveKmeans(ActFeatures,2,0.02,1,'sqeuclidean');
                                    end
                                elseif(strcmp(kindOfClustring,'DBScan')==1) % strategy==4
                                    if(size(ActFeatures,2)<=2)
                                        C=ones(size(ActFeatures,2),1)+allclusterid;
                                        mu=ActFeatures(11:end,1)';
                                    else
                                        C=[];
                                        varType=[];
                                        if StrategyClustering == 4
                                            [C, varType] = dbscan(ActFeatures(11:end,:)',2,'euclidean',0.5);
                                        elseif StrategyClustering ==7
                                            [C, varType] = dbscan(ActFeatures(11:end,:)',2,'euclidean');
                                        end
                                        C=C+1;
                                        labels = unique(C);
                                        mu=zeros(size(labels,1),128);
                                        for clusterlabels=1:size(labels,1);
                                            mu(clusterlabels,:)= mean(ActFeatures(11:end,C==labels(clusterlabels))');
                                        end
                                    end
                                end
                                Allthefeatures=[Allthefeatures,ActFeatures];
                                Centroids=[Centroids;mu];
                                AlltheCluster=[AlltheCluster;C+allclusterid];
                                allclusterid=max(AlltheCluster);
                            end
                            C=AlltheCluster;
                            mu=Centroids;
                            X=Allthefeatures;
                        elseif(StrategyClustering == 2 | StrategyClustering == 5 | StrategyClustering == 8) %% we are interested  into croup of feature on similar variates then we apply  a clustering to get  this groups
                            % we first use the depdscopevector to cluster  the features
                            % with similar depepndency scope  hten we use the
                            % descriptor to cluster on the base of the time property
                            [depd_Cluster,mu,inertia,tryK,startK]= adaptiveKmeansDependency(DepdScopeVector,2,0.02,1,'hamming');
                            possibleset= unique(depd_Cluster);
                            AlltheCluster=[];
                            Allthefeatures=[];
                            Centroids =[];
                            allclusterid=0;
                            for classidlabel= 1:size(possibleset,1) % for each set of varaites  create a cluster on descriptors
                                idactfeatures= depd_Cluster == possibleset(classidlabel);
                                ActFeatures = X(:,idactfeatures);
                                if(strcmp(kindOfClustring,'AKmeans')==1)
                                    if(size(ActFeatures,2)<=2)
                                        C=ones(size(ActFeatures,2),1)+allclusterid;
                                        mu=ActFeatures(11:end,1)';
                                    else
                                        [C,mu,inertia,tryK,startK]= adaptiveKmeans(ActFeatures,2,0.02,1,'sqeuclidean');
                                    end
                                elseif(strcmp(kindOfClustring,'DBScan')==1) % strategy==5
                                    if(size(ActFeatures,2)<=2)
                                        C=ones(size(ActFeatures,2),1)+allclusterid;
                                        mu=ActFeatures(11:end,1)';
                                    else
                                        C=[];
                                        varType=[];
                                        if StrategyClustering == 5
                                            [C, varType] = dbscan(ActFeatures(11:end,:)',2,'euclidean',0.5);
                                        elseif StrategyClustering == 8
                                            [C, varType] = dbscan(ActFeatures(11:end,:)',2,'euclidean');
                                        end
                                        C=C+1;
                                        labels = unique(C);
                                        mu=zeros(size(labels,1),128);
                                        for clusterlabels=1:size(labels,1);
                                            mu(clusterlabels,:)= mean(ActFeatures(11:end,C==labels(clusterlabels))');
                                        end
                                    end
                                end
                                Allthefeatures=[Allthefeatures,ActFeatures];
                                Centroids=[Centroids;mu];
                                AlltheCluster=[AlltheCluster;C+allclusterid];
                                allclusterid=max(AlltheCluster);
                            end
                            C=AlltheCluster;
                            mu=Centroids;
                            X=Allthefeatures;
                            
                        elseif((StrategyClustering == 3 | StrategyClustering == 6 | StrategyClustering == 9) & justSubCluster==0)% classic strategy  we cluster all the features
                            if(strcmp(kindOfClustring,'AKmeans')==1)
                                [C,mu,inertia,tryK,startK]= adaptiveKmeans(X,3,0.02,2,'sqeuclidean');%'cosine');%4th parameter will fix the step to 2 as default 0.02
                            elseif(strcmp(kindOfClustring,'DBScan')==1) % strategy==6
                                C=[];
                                varType=[];
                                if StrategyClustering==6
                                    [C, varType] = dbscan(X(11:end,:)', 2,'euclidean',0.5);
                                elseif StrategyClustering==9
                                    [C, varType] = dbscan(X(11:end,:)', 2,'euclidean');
                                end
                                C=C+1;
                                labels = unique(C);
                                mu=zeros(size(labels,1),128);
                                for clusterlabels=1:size(labels,1);
                                    mu(clusterlabels,:)= mean(X(11:end,C==labels(clusterlabels))');
                                end
                            end
                        end
                        Time4Clustering=toc;
                        % if (StrategyClustering ~= 3 | (StrategyClustering == 3 & justSubCluster==0))
                        if(exist(strcat(saveFeaturesPath,'Distances',distanceUsed,'\ClusterStrategy_',num2str(StrategyClustering),'\'),'dir')==0)
                            mkdir(strcat(saveFeaturesPath,'Distances',distanceUsed,'\ClusterStrategy_',num2str(StrategyClustering),'\'));
                        end
                        csvwrite(strcat(saveFeaturesPath,'Distances',distanceUsed,'\ClusterStrategy_',num2str(StrategyClustering),'\Cluster_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv'),C);
                        csvwrite(strcat(saveFeaturesPath,'Distances',distanceUsed,'\ClusterStrategy_',num2str(StrategyClustering),'\Centroids_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv'),mu);
                        csvwrite(strcat(saveFeaturesPath,'Distances',distanceUsed,'\ClusterStrategy_',num2str(StrategyClustering),'\Features_IM_',TS_name,'_DepO_',num2str(USER_OD_targhet),'_TimeO_',num2str(USER_OT_targhet),'.csv'),X);
                        % end
                        
                        if (StrategyClustering == 3 | StrategyClustering == 6| StrategyClustering == 9)
                            saveFeaturesPath=[datasetPath,subfolderPath,'Features_',FeaturesRM,'\',TS_name,'\'];
                            depdOverLapThreshold = 1;
                            timeforSubclustering = subCluster_Varaites(saveFeaturesPath,TS_name,num2str(StrategyClustering),distanceUsed,depdOverLapThreshold,USER_OT_targhet,USER_OD_targhet);
                        end
                        
                    end
                    
                    if(pruneCluster==1)
                        if (StrategyClustering == 3 |StrategyClustering == 6|StrategyClustering == 9 )
                            TimeforPruningClustering = KmeansPruning(TS_name,datasetPath,subfolderPath,TS_name,kindOfClustring,num2str(StrategyClustering),prunewith,distanceUsed ,FeaturesRM,USER_OT_targhet,USER_OD_targhet,saveMotifAP);%1);
                            TimeforPruningSubClustering = VariateAllinedKmeansPruning(TS_name,datasetPath,subfolderPath,TS_name,kindOfClustring,num2str(StrategyClustering),prunewith,distanceUsed ,FeaturesRM,USER_OT_targhet,USER_OD_targhet,saveMotifAP);
                            %(TS_name,datasetPath,subfolderPath,TS_name,kindOfClustring,num2str(StrategyClustering),prunewith,distanceUsed ,DictionarySize,histTSImage,FeaturesRM,cleanfeatures,saveMotifAP);%1);
                        else
                            TimeforPruningClustering = KmeansPruning(TS_name,datasetPath,subfolderPath,TS_name,kindOfClustring,num2str(StrategyClustering),prunewith,distanceUsed ,FeaturesRM,USER_OT_targhet,USER_OD_targhet,saveMotifAP);
                        end
                    end
                    
                    if(savecaracteristics==1)
                        saveFeaturesPath=[datasetPath,subfolderPath,'Features_',FeaturesRM,'\',TS_name,'\'];
                        savepath1 = [saveFeaturesPath,'feature_',TS_name,'.mat'];
                        savepath2 = [saveFeaturesPath,'idm_',TS_name,'.mat'];
                        savepath3 = [saveFeaturesPath,'MetaData_',TS_name,'.mat'];
                        load(savepath1);
                        load(savepath2);
                        load(savepath3);
                        a=[];
                        k=USER_OT_targhet;
                        j=USER_OD_targhet;
                        %             for k=1:DeOctTime
                        %                 for j=1:DeOctDepd
                        indexfeatureGroup = (frame1(6,:)==k & frame1(5,:)==j);
                        X=frame1(:,indexfeatureGroup);
                        SizeFeaturesforImages=[k,j,size(X,2)];
                        %                 end
                        %             end
                        %             SizeFeaturesforImages=[SizeFeaturesforImages;a];
                        csvwrite(strcat(saveFeaturesPath,'NumFeatures.csv'),SizeFeaturesforImages);
%                         xlswrite(strcat(saveFeaturesPath,'NumFeatures.xls'),SizeFeaturesforImages);
                        
%                         col_header={char(strcat('OT',num2str(USER_OT_targhet),'_OD',num2str(USER_OD_targhet)))};%{'OT1_OD1','OT1_OD2','OT2_OD1','OT2_OD2'};
%                         rowHeader ={'FeatureEstraction';'ComputationDepdScale';'Clustering';'VaraiteAllineament';'PruningStandarDev_V_allined';'PruningStandarDev_Clusters'};
csvwrite(strcat(saveFeaturesPath,'Strategy_',num2str(StrategyClustering),'_TIME1.csv'),[TIMEFOROCTAVE;TimeComputationDepdScale;Time4Clustering;timeforSubclustering;TimeforPruningSubClustering;TimeforPruningClustering]);
%xlswrite(strcat(saveFeaturesPath,'Strategy_',num2str(StrategyClustering),'_TIME1.xls'),[TIMEFOROCTAVE;TimeComputationDepdScale;Time4Clustering;timeforSubclustering;TimeforPruningSubClustering;TimeforPruningClustering],'TIME','B2');
%                         xlswrite(strcat(saveFeaturesPath,'Strategy_',num2str(StrategyClustering),'_TIME1.xls'),rowHeader,'TIME','A2');
%                         xlswrite(strcat(saveFeaturesPath,'Strategy_',num2str(StrategyClustering),'_TIME1.xls'),col_header,'TIME','B1');
                    end
                    
%                     pause(1)
%                     clear('a','ActFeatures','allclusterid','AlltheCluster','AllthefeaturesAllTS','C','Centroids','data','depd1','DepdScopeVector','descr1','frame1','gss1','idm1','idactfeatures',...
%                         'indexfeaturesGroup','mu','possibleset','rowHeader','X','AlltheCluster','Allthefeatures','col_header')
%                     
                end
            end
        end
    end
end
