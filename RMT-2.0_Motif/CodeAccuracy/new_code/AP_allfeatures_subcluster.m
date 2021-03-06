%% Accuracy best timeoverlapping
% clc; clear;
function  AP_allfeatures_subcluster(path,kindofinj,TEST,FeaturesRM,kindofCluster,measure,ClusterAlg,subfolderClusterLabel,DepO,DepT)
% %% Analize Results
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
Position_F_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\FeaturePosition_',TEST,'.csv']);%\',TEST,'
% Feature_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\FeaturesEmbedded_',TEST,'.csv']);
Dependency_Injected = csvread([path,kindofinj,'IndexEmbeddedFeatures\dpscale_',TEST,'.csv']);

%% read the clusters to check the motifs.
featurespath=[path,'Features_',FeaturesRM,'\',TEST,'\Distances',measure,'\',kindofCluster,'\SplitVariate\AP_VA\Cluster_AKmeans\'];
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
if(exist(strcat(path,'Features_',FeaturesRM,'\Accuracy\'),'dir')==0)%'\',TEST,
    mkdir(strcat(path,'Features_',FeaturesRM,'\Accuracy\'));%'\',TEST,
end
col_header={'Class','ID','Start','End','ClassInj','IDinj','StartInj','EndInj','Time_Score','dep_Overlapping'}; 
FileName=[path,'Features_',FeaturesRM,'\Accuracy\','AP_','DepO_',DepO,'_DepT_',DepT,'_',TEST,'.csv'];%'\',TEST,%'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'_',TEST,'.csv'];
xlswrite(FileName,FeatureClassCount,'AP_all_SubC','A2');
xlswrite(FileName,col_header,'AP_all_SubC','A1');


%   Position_F_Injected(:,2)=[];
% % [q,I] = sort(Position_F_Injected(:,2));
% % [q1, I_IntervFeat]= sort(ItervalFeatures(:,2));
% 
% % Position_F_Injected = Position_F_Injected(I,:);
% % Interv_Features_Cluster=Interv_Features_Cluster(I_IntervFeat,:);
% 
% FeatureClassCount=[];
% ActualName=[];
% NotFoundPosition=[0,-1,-1];
% for i=1: size(Interv_Features_Cluster,1)
%     IdentifiedTimePeriod=Interv_Features_Cluster(i,2): Interv_Features_Cluster(i,3);
%     IdentifiedTimePeriod = IdentifiedTimePeriod(IdentifiedTimePeriod>0 & IdentifiedTimePeriod<=size(data,2))
%     miss=0;
%     found=0;
%     MAXOverlapping=-1;
%     MAXVariateOverSimilarity=-1;
%     MAXVaraiteOverSim_MaximumDiv=-1;
%     MAXOverlappingIDX=-1;
%     
%     for j=1:size(Position_F_Injected,1)
%         InjectedTimePeriod = Position_F_Injected(j,2):Position_F_Injected(j,3);
%         InjectedTimePeriod =InjectedTimePeriod(InjectedTimePeriod>0 & InjectedTimePeriod<=size(data,2));
%         
%         newOverlapping= intersect(InjectedTimePeriod,IdentifiedTimePeriod);
%         DI=Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,1))>0,Position_F_Injected(j,1));
%         DC=DescriptorSortedbyCluster(DescriptorSortedbyCluster(:,i)>0,i);
%         if(size(newOverlapping,2) & (MAXOverlapping == -1))
%             MAXOverlapping=newOverlapping;
%             MAXOverlappingIDX=j;
%  
%             VariateOverSimilarity= size(intersect(DI,DC),1)/size(union(DI,DC),1);
% %             MAXVaraiteOverSim_MaximumDiv    = size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,1))>0,Position_F_Injected(j,1)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,1))>0,Position_F_Injected(j,1)),1);
% %             
% %             VariateOverSimilarity= size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 max(size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1),...
% %                 size(Dependencypruned(Dependencypruned(:,i)>0,i),1)                                                       );
%              MAXVariateOverSimilarity = VariateOverSimilarity;
% %             %% ActualName= Position_F_Injected(j,:);
%         elseif((size(newOverlapping,2) >= size(MAXOverlapping,2)))
%             VariateOverSimilarity= size(intersect(DI,DC),1)/size(union(DI,DC),1);
% %                 VariateOverSimilarity    =  size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 max(size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1),...
% %                 size(Dependencypruned(Dependencypruned(:,i)>0,i),1)                                                       );
%             if(VariateOverSimilarity >= MAXVariateOverSimilarity)
%                 MAXOverlapping=newOverlapping;
%                 MAXOverlappingIDX=j;
%                 MAXVariateOverSimilarity = VariateOverSimilarity;
%                 
% %                 MAXVaraiteOverSim_MaximumDiv= size(intersect(...
% %                     Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                     Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                     size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1);
%                 
%             end
%         end
%     end
%     
% %     NearInjectedFeaturePeriod= Position_F_Injected(MAXOverlappingIDX,3): Position_F_Injected(MAXOverlappingIDX,4);
% %     CandidateFeaturePeriod= IdentifiedTimePeriod;%ItervalFeatures(MAXOverlappingIDX,1): ItervalFeatures(MAXOverlappingIDX,2);
% %     Overlpping = intersect(CandidateFeaturePeriod,NearInjectedFeaturePeriod);
%     if(MAXOverlappingIDX~=-1)%if(size(MAXOverlapping,2)/max(size(InjectedTimePeriod,2),size(CandidateFeaturePeriod,2))> 0)
%         ActualName= Position_F_Injected(MAXOverlappingIDX,:);
%         found=found+1;
%     else
%         miss= miss+1;
%         ActualName=NotFoundPosition;
%     end    
% 
% 
%     ActualName= [
%                  Interv_Features_Cluster(i,1),...
%                  i,...
%                  Interv_Features_Cluster(i,2),...
%                  Interv_Features_Cluster(i,3),...
%                  ActualName,...
%                  MAXVariateOverSimilarity,...
%                  found];
%     FeatureClassCount=[FeatureClassCount;ActualName];
%     
% %                  MAXVaraiteOverSim_MaximumDiv,...
% end
% if(exist(strcat(path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\'),'dir')==0)
%     mkdir(strcat(path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\'));
% end
%     col_header={'Class','ID','Start','End','ClassInj','StartInj','EndInj','dep_Overlapping','found'}; 
% xlswrite([path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\','AP_',TEST,'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'.csv'],FeatureClassCount,'AP_all_SubC','A2');
% xlswrite([path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\','AP_',TEST,'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'.csv'],col_header,'AP_all_SubC','A1');
% % csvread([path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\','AP_all_SubC_',TEST,'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'.csv'],FeatureClassCount);
% 
% % %% Sort the Feature on the index of  the name of the specific feature.
% % [q,I] = sort(Position_F_Injected(:,2));
% % % [q1, I_IntervFeat]= sort(ItervalFeatures(:,2));
% % 
% % % Position_F_Injected = Position_F_Injected(I,:);
% % % Interv_Features_Cluster=Interv_Features_Cluster(I_IntervFeat,:);
% % 
% % FeatureClassCount=[];
% % ActualName=[];
% % NotFoundPosition=[0,-1,-1,-1];
% % for i=1: size(Interv_Features_Cluster,1)
% %     IdentifiedTimePeriod=Interv_Features_Cluster(i,2): Interv_Features_Cluster(i,3);
% %     miss=0;
% %     found=0;
% %     MAXOverlapping=-1;
% %     MAXVariateOverSimilarity=-1;
% %     MAXVaraiteOverSim_MaximumDiv=-1;
% %     MAXOverlappingIDX=-1;
% %     
% %     for j=1:size(Position_F_Injected,1)
% %         InjectedTimePeriod= Position_F_Injected(j,3):Position_F_Injected(j,4);
% %         newOverlapping= intersect(InjectedTimePeriod,IdentifiedTimePeriod);
% %         if(size(newOverlapping,2) & (MAXOverlapping == -1))
% %             MAXOverlapping=newOverlapping;
% %             MAXOverlappingIDX=j;
% %             MAXVaraiteOverSim_MaximumDiv    = size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1);
% %             
% %             VariateOverSimilarity= size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 max(size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1),...
% %                 size(Dependencypruned(Dependencypruned(:,i)>0,i),1)                                                       );
% %             MAXVariateOverSimilarity = VariateOverSimilarity;
% %             %% ActualName= Position_F_Injected(j,:);
% %         elseif((size(newOverlapping,2) >= size(MAXOverlapping,2)))
% %                 VariateOverSimilarity    =  size(intersect(...
% %                 Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                 Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                 max(size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1),...
% %                 size(Dependencypruned(Dependencypruned(:,i)>0,i),1)                                                       );
% %             if(VariateOverSimilarity >= MAXVariateOverSimilarity)
% %                 MAXOverlapping=newOverlapping;
% %                 MAXOverlappingIDX=j;
% %                 MAXVariateOverSimilarity = VariateOverSimilarity;
% %                 
% %                 MAXVaraiteOverSim_MaximumDiv= size(intersect(...
% %                     Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),...
% %                     Dependencypruned(Dependencypruned(:,i)>0,i)),1)/...
% %                     size(Dependency_Injected(Dependency_Injected(:,Position_F_Injected(j,2))>0,Position_F_Injected(j,2)),1);
% %                 
% %             end
% %         end
% %     end
% %     
% % %     NearInjectedFeaturePeriod= Position_F_Injected(MAXOverlappingIDX,3): Position_F_Injected(MAXOverlappingIDX,4);
% % %     CandidateFeaturePeriod= IdentifiedTimePeriod;%ItervalFeatures(MAXOverlappingIDX,1): ItervalFeatures(MAXOverlappingIDX,2);
% % %     Overlpping = intersect(CandidateFeaturePeriod,NearInjectedFeaturePeriod);
% %     if(MAXOverlappingIDX~=-1)%if(size(MAXOverlapping,2)/max(size(InjectedTimePeriod,2),size(CandidateFeaturePeriod,2))> 0)
% %         ActualName= Position_F_Injected(MAXOverlappingIDX,:);
% %         found=found+1;
% %     else
% %         miss= miss+1;
% %         ActualName=NotFoundPosition;
% %     end    
% % 
% %     ActualName= [ActualName,...
% %                  Interv_Features_Cluster(i,1),...
% %                  i,...
% %                  Interv_Features_Cluster(i,2),...
% %                  Interv_Features_Cluster(i,3),...
% %                  MAXVariateOverSimilarity,...
% %                  MAXVaraiteOverSim_MaximumDiv,...
% %                  found,miss];
% %     FeatureClassCount=[FeatureClassCount;ActualName];
% % end
% % if(exist(strcat(path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\subcluster\'),'dir')==0)
% %     mkdir(strcat(path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\subcluster\'));
% % end
% % xlswrite([path,'Features_',FeaturesRM,'\',TEST,'\Accuracy\subcluster\','AP_',TEST,'_AllFeatureFound_DepO_',DepO,'_DepT_',DepT,'.xls'],FeatureClassCount);
% 
