clear;
clc;
%% This file work for RMT motifs evaluation. It computes Precision and recall for each cluster  and combine all of them into a average value.

GroundTruthMappedPath='';
dataset_Path = '';
OctaveDepd=2;
OctaveTime=2;
load([datasetPath,'data\FeaturesToInject\allTSid.mat']);
algorithmType={'RMT','MSTAMP'};
strategy=[1,3,4,6,7,9];%[1,2,3,4,5,6,7,8,9];
Num_Motifs =[1,2,3];
Name_OriginalSeries = AllTS;
Permotif_num_instances =10;
RandomWalkPercentages=[0; 0.1;0.25;0.5;0.75;1];

timeOverlapThresholds = [0.1, 0.25, 0.5, 0.75, 1];
VariateThreshold = eps;


for strategyID = 1 : size(strategy,2)
    for motifID =1: Num_Motifs
        Presentation_Precision=[];
        Presentation_Recall =[];
        Presentation_Fscore =[];
        for randomwalkPercentID =1 : size(RandomWalkPercentages,2)
            %% iterate on the time overlapping threshold
            PrecisionTimeOverlapAggr = zeros(size(timeOverlapThresholds,1),Num_Motifs+1);
            RecallTimeOverlapAggr    = zeros(size(timeOverlapThresholds,1),Num_Motifs+1);
            FscoreTimeOverlapAggr    = zeros(size(timeOverlapThresholds,1),Num_Motifs+1);
            for timeoverlapthresholdID = 1: size(timeOverlapThresholds,1)
                %% the output file  consider the column as TimeSeriesID, PrecisionM1, PrecisionM2, ..., PrecisionM3; same happen for Recall.
                PrecisionAggregated = zeros (size(Name_OriginalSeries,2),motifID+2);
                RecallAggregated    = zeros (size(Name_OriginalSeries,2),motifID+2);
                FscoreAggregated    = zeros (size(Name_OriginalSeries,2),motifID+2);
                counter=0;
                for tsID =1 : size(Name_OriginalSeries,2)
                    for instanceID =1:10
                        
                        % load the file mapped with the groundtruth AP_DepO_2_DepT_2_Motif3_17_instance_1_0.1
                        FileMapped = csvread([GroundTruthMappedPath,'\AP_DepO_2_DepT_2_Motif',...
                            num2str(Num_Motifs),'_',num2str(tsID),'_instance',num2str(instanceID),'_',...
                            num2str(RandomWalkPercentages(randomwalkPercentID)),'.csv']);
                        
                        classID = unique(fileMapped(:,1)); %name of the clusters discovered
                        %% the output file  consider the column as ClusterID, PrecisionM1, PrecisionM2, ..., PrecisionM3; same happen for Recall.
                        precisionMatrix = zeros(size(classID, 1), motifID+1);
                        recallMatrix    = zeros(size(classID, 1), motifID+1);
                        FScoreMatrix    = zeros(size(classID, 1), motifID+1);
                        
                        for clusterID =1 :size(classID, 1)
                            % consider the elements in the cluster named classID(clusterID)
                            clusterElements = FileMapped(FileMapped(:,1)==classID(clusterID),:);
                            timeStart = clusterElements(:,3);
                            timeEnd   = clusterElements(:,4);
                            injectedTimeStart = statEntry(:, 7);
                            injectedTimeEnd = statEntry(:, 8);
                            
                            timeOverlap = statEntry(:, 9);
                            depdOverlap = statEntry(:, 10);
                            Cluster_i_size = size(clusterElements,1); %% number of elements present in the cluster
                            
                            [uniqueRows, firstIndex, membershipIndex] = unique( clusterElements(:,[7 8]), 'rows');
                            singleidentifiedinstances = size(uniqueRows, 1);
                            
                            
                            precisionCi = zeros(size(clusterElements,1),Num_Motifs);
                            RecallCi    = zeros(singleidentifiedinstances,Num_Motifs);
                            for i=1:size(clusterElements,1)
                                %                                 precisionScore(i) = score_TO * score_VO;
                                if (clusterElements(i,9) >=timeOverlapThresholds(timeOverlapThresholdsID) &  clusterElements(i,10)>= VariateThreshold)
                                    precisionCi (i,clusterElements(i,5))=1;
                                else
                                    precisionCi (i,clusterElements(i,5))=0;
                                end
                            end
                            for i = 1 : singleidentifiedinstances
                                resultIndex = find(membershipIndex(:) == i);
                                bestTO = max(clusterElements(resultIndex, 9)); %%max does not have any sense here
                                bestVO = max(clusterElements(resultIndex, 10));
                                
                                if(bestTO >= timeOverlapThreshold && bestVO >= VariateThreshold)
                                    RecallCi(i,clusterElements(resultIndex, 5)) = 1;
                                else
                                    RecallCi(i,clusterElements(resultIndex, 5)) = 0;
                                end
                            end
                            precisionMatrix(clusterID,1)=classID(clusterID);
                            precisionMatrix(clusterID,2:end)= sum(precisionCi)/Cluster_i_size;
                            recallMatrix(clusterID,1)=classID(clusterID);
                            recallMatrix(clusterID,2:end) = sum (RecallCi)/Permotif_num_instances;
                            FScoreMatrix(clusterID,1)=classID(clusterID);
                            FScoreMatrix(clusterID,2:end) = ...
                                (2*precisionMatrix(clusterID,2:end).*recallMatrix(clusterID,2:end))./(precisionMatrix(clusterID,2:end)+recallMatrix(clusterID,2:end));
                        end
                        %% save on file Precision Recall ed Fscore per cluster.
                        
                        %% compute aggregated precision  recall and fscore from them  averaging non 0 e non nan elements
                        counter =counter+1;
                        PrecisionAggregated(counter,1:2) = [Name_OriginalSeries(tsID) ,  instanceID];
                        RecallAggregated (counter,1:2)   = [Name_OriginalSeries(tsID) ,  instanceID];
                        FscoreAggregated (counter,1:2)   = [Name_OriginalSeries(tsID) ,  instanceID];
                        for i=1: Num_Motifs
                            precision_Mi = precisionMatrix(precisionMatrix(:,1+i)>0,1+i);
                            recall_Mi    = recallMatrix(recallMatrix(:,1+i)>0,1+i);
                            PrecisionAggregated(counter,2+i) = mean(precision_Mi);
                            RecallAggregated(counter,2+i)    = mean(recall_Mi);
                            FscoreAggregated(counter,2+i)    = (2 * PrecisionAggregated(counter,2+i)*RecallAggregated(counter,2+i))/(PrecisionAggregated(counter,2+i)+RecallAggregated(counter,2+i));
                        end
                    end
                    
                end
                %% save precision recall and fscore aggregated for experiment having a specific percentage of time overlapping
                PrecisionTimeOverlapAggr(timeoverlapthresholdID,1) = timeOverlapThresholds(timeoverlapthresholdID);
                RecallTimeOverlapAggr   (timeoverlapthresholdID,1) = timeOverlapThresholds(timeoverlapthresholdID);
                FscoreTimeOverlapAggr   (timeoverlapthresholdID,1) = timeOverlapThresholds(timeoverlapthresholdID);
                
                for i=1:Num_Motifs
                    precision_AllTi = PrecisionAggregated(PrecisionAggregated(:,2+i)>0,2+i);
                    recall_AllTi    = RecallAggregated(RecallAggregated(:,2+i)>0,2+i);
                    PrecisionTimeOverlapAggr(timeoverlapthresholdID,1+i) = mean(precision_AllTi);
                    RecallTimeOverlapAggr   (timeoverlapthresholdID,1+i) = mean(recall_AllTi);
                    FscoreTimeOverlapAggr   (timeoverlapthresholdID,1+i) = ...
                        (2 * PrecisionTimeOverlapAggr(timeoverlapthresholdID,1+i)*RecallTimeOverlapAggr(timeoverlapthresholdID,1+i))/...
                        (PrecisionTimeOverlapAggr(timeoverlapthresholdID,1+i)+RecallTimeOverlapAggr(timeoverlapthresholdID,1+i));
                end
            end
            %%save aggregated results multiple % of time overlapping
            Presentation_Precision{randomwalkPercentID}.RWscale=RandomWalkPercentages(randomwalkPercentID);
            Presentation_Recall {randomwalkPercentID}.RWscale=RandomWalkPercentages(randomwalkPercentID);
            Presentation_Fscore {randomwalkPercentID}.RWscale=RandomWalkPercentages(randomwalkPercentID);
            Presentation_Precision{randomwalkPercentID}.RWscale=PrecisionTimeOverlapAggr;
            Presentation_Recall {randomwalkPercentID}.RWscale=RecallTimeOverlapAggr;
            Presentation_Fscore {randomwalkPercentID}.RWscale=FscoreTimeOverlapAggr;
        end
        %% Save the Presentations.mat files  ior eventually compoise the files
    end
end