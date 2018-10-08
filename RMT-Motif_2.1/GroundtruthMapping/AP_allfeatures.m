%% Accuracy best timeoverlapping
% clc; clear;
function AP_allfeatures(path,kindofinj,TEST,FeaturesRM,kindofCluster,measure,ClusterAlg,StrategyClustering,DepO,DepT)
%% Analize Results
% path='D:\Motif_Results\Datasets\SynteticDataset\';
% kindofinj='data\';%'CosineTS_MultiFeatureDiffClusters\';%'MultiFeatureDiffClusters\';
% TEST = 'test1';
% 
% FeaturesRM ='RMT';%'RME';%
% kindofCluster='Cluster_AKmeans';%'ClusterMatlab';%'ClusterKmedoids';%
% measure='Descriptor';
% ClusterAlg = 'ClusterMatlab';
% subfolderClusterLabel='Clusterlabel\ClusterLabel_';
% DepO=num2str(2);
% DepT=num2str(2);


%% data injected and groundtruth
data = csvread([path,kindofinj,TEST,'.csv']);%csvread([path,kindofinj,'Embeddedfeature.csv']);
Position_F_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\FeaturePosition_',TEST,'.csv']);%TEST,
% Feature_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\FeaturesEmbedded_',TEST,'.csv']);
Dependency_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\dpscale_',TEST,'.csv']);%\',TEST,'

%% read the clusters to check the motifs.
featurespath=[path,'Features_',FeaturesRM,'\',TEST,'\Distances',measure,'\',ClusterAlg,'\AP\',kindofCluster,'\'];
% load([featurespath,'datacluster_',TEST,'_DepO_',DepO,'_DepT_',DepT,'.mat'])
% load([path,kindofinj,'Features\',TEST,'\DistancesDescriptors\',kindofCluster,measure,'\afterPruning\',ClusterAlg,'\datacluster_1_DepO_',DepO,'_DepT_',DepT,'.mat']);

Dependencypruned = csvread([featurespath,'\PrunedDepScaleFeatures_IM_',TEST,'_DepO_',DepO,'_DepT_',DepT,'.csv']);
Featurepruned    = csvread([featurespath,'\PrunedFeatures_IM_',TEST,'_DepO_',DepO,'_DepT_',DepT,'.csv']);
Clusterpruned = csvread([featurespath,'\PrunedCluster_IM_',TEST,'_DepO_',DepO,'_DepT_',DepT,'.csv']);
Centroidpruned = csvread([featurespath,'\Centroids_IM_',TEST,'_DepO_',DepO,'_DepT_',DepT,'.csv']);

%% Check to with cluster each feature refers
Interv_Features_Cluster=[];
clusterLabel = unique(Clusterpruned);
nCluster     = length(clusterLabel);
FeatureSortedbyCluster=[];
DescriptorSortedbyCluster=[];
for i=1: nCluster
    F = Featurepruned(:, Clusterpruned == clusterLabel(i));
    D = Dependencypruned(:, Clusterpruned == clusterLabel(i));
    timescopeF= F(4,:)*3;
    for iii=1: size(F,2)
        Interv_Features_Cluster=[Interv_Features_Cluster;[clusterLabel(i),round(F(2,iii)-timescopeF(iii)) , round(F(2,iii)+timescopeF(iii))]];
    end 
    FeatureSortedbyCluster=[FeatureSortedbyCluster,F];
    DescriptorSortedbyCluster=[DescriptorSortedbyCluster,D];
end


%% Sort the Feature on the index of  the name of the specific feature.
FeatureClassCount=[];
for i=1: size(Interv_Features_Cluster,1)
    IdentifiedTimePeriod=Interv_Features_Cluster(i,2): Interv_Features_Cluster(i,3);
    IdentifiedTimePeriod = IdentifiedTimePeriod(IdentifiedTimePeriod>0 & IdentifiedTimePeriod<=size(data,2));
    
    MotifInstanceIdentification=[Interv_Features_Cluster(i,1),i,IdentifiedTimePeriod(1),IdentifiedTimePeriod(end)];
        TimeScore =0; 
        Varaitescore =-1; 
        InjectedIDentifcation=[0,0,0,0,TimeScore,Varaitescore];

    for j=1:size(Position_F_Injected,1)
         DI=Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2));
         DC=DescriptorSortedbyCluster(DescriptorSortedbyCluster(:,i)>0,i);
         TimeOverlapping=computeTimeOverlap(IdentifiedTimePeriod(1),IdentifiedTimePeriod(end),Position_F_Injected(j,3),Position_F_Injected(j,4));
         variateOverlapping = size(intersect(DI,DC),1)/size(DI,1);%(union(DI,DC),1);
         if(TimeOverlapping >0 & variateOverlapping >0)
              % condition to modify the score
              if (TimeOverlapping *variateOverlapping > TimeScore*Varaitescore)
                  TimeScore=TimeOverlapping;
                  Varaitescore= variateOverlapping;
                InjectedIDentifcation=[Position_F_Injected(j,1),Position_F_Injected(j,2),Position_F_Injected(j,3),Position_F_Injected(j,4),TimeScore,Varaitescore];
              end
          end 
    end
FeatureClassCount=[FeatureClassCount;[MotifInstanceIdentification,InjectedIDentifcation]];  
end
if(exist(strcat(path,'Features_',FeaturesRM,'\Accuracy\Strategy_',num2str(StrategyClustering),'\'),'dir')==0)%'\',TEST,
    mkdir(strcat(path,'Features_',FeaturesRM,'\Accuracy\Strategy_',num2str(StrategyClustering),'\'));%'\',TEST,
end
% col_header={'Class','ID','Start','End','ClassInj','IDinj','StartInj','EndInj','Time_Score','dep_Overlapping'}; 
FileName=[path,'Features_',FeaturesRM,'\Accuracy\Strategy_',num2str(StrategyClustering),'\','AP_','DepO_',DepO,'_DepT_',DepT,'_',TEST,'.csv'];%'\',TEST,%'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'_',TEST,'.csv'];
csvwrite(FileName,FeatureClassCount);

%  xlswrite(FileName,FeatureClassCount,'AP_all_SubC','A2');
%  xlswrite(FileName,col_header,'AP_all_SubC','A1');
end
