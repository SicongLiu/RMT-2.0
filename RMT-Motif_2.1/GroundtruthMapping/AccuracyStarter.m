clc; clear;
warning off;
% path='D:\Motif_Results\Datasets\SynteticDataset\Mocap\';
 path='D:\Motif_Results\Datasets\SynteticDataset\Energy\';%BirdSong\';
%path ='F:\Motif_Results\Datasets\SynteticDataset\Mocap\'

dataLocation='data\';
load([path,'data\FeaturesToInject\allTSid.mat']);
Num_SyntSeries=10; % num of instances of one motif
PossibleMotifInjected = [1,2,3,10];
for idmotInj =2:3% size(PossibleMotifInjected,2)-1
    motifinjected = num2str(PossibleMotifInjected(idmotInj));
%     Name_OriginalSeries = [23,35,86,111];% MOCap Motif10%
    Name_OriginalSeries = AllTS;%[1,3,6,7];%ENERGY [64,70,80,147];Bsong%[85,35,127,24];Mocap % name of the original  series from with we  got the  motif instances to inject
    percent=[0; 0.1;0.25;0.5;0.75;1];
    for percentid=1:6%1:size(percent,1)
        percentagerandomwalk=percent(percentid);
        % percentagerandomwalk=0.75;%1;%0; %0.1;%0.5;%
        strategy=[1,3,4,6,7,9];%[1,2,3,4,5,6,7,8,9];
        DepO =2;
        DepT =2;
        for strID =1:size(strategy,2)%9%5:6%4:6%4:6%1:size(strategy,2)
            StrategyClustering= strategy(strID);%3;%2;%
            
            for pip=1:30%size(Name_OriginalSeries,2)
                for NAME = 1:Num_SyntSeries
                    
                    TEST=['Motif',motifinjected,'_',num2str(Name_OriginalSeries(pip)),'_instance_',num2str(NAME),'_',num2str(percentagerandomwalk)];
                    %            ['Motif1_',num2str(pippo(pip)),'_instance_',num2str(NAME)]  %['MoCap',num2str(NAME)]
                    
                    FeaturesRM ='RMT';%'RMT';%
                    kindOfClustring= 'AKmeans'; % the algorithm of clustering to use
                    if StrategyClustering >3
                        kindOfClustring= 'DBScan';%
                    end
                    distanceUsed='Descriptor';% use just descriptors to  cluster
                    ClusterAlg = ['ClusterStrategy_',num2str(StrategyClustering)];
                    subfolderClusterLabel='Clusterlabel\ClusterLabel_';
                    
    %                
                    if (StrategyClustering==3 | StrategyClustering==6| StrategyClustering==9)
                        AP_allfeatures_subcluster(path,dataLocation,TEST,FeaturesRM,kindOfClustring,distanceUsed,ClusterAlg,StrategyClustering,num2str(DepO),num2str(DepT));
                    else
                        AP_allfeatures(path,dataLocation,TEST,FeaturesRM,kindOfClustring,distanceUsed,ClusterAlg,StrategyClustering,num2str(DepO),num2str(DepT));
                    end
                    %         for AfterPruning =0:1
                    %             for subcluster=0:1
                    %                 Distortion_Clusters(path,kindofinj,TEST,FeaturesRM,kindofCluster,measure,ClusterAlg,subfolderClusterLabel,num2str(DepO),num2str(DepT),AfterPruning,subcluster);
                    %             end
                    %         end
                    
                    %             end
                    %         end
                end
            end
        end
    end
end