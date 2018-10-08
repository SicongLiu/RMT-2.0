clear;
clc;
GroundTruthFilePath = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/GroundTruthMocap/FeaturePosition_Motif'];

% MatrixProfileFilePath = ['/Users/sicongliu/Desktop/MyMotif/EnergyComputeAccuracy/AccuracyMstamp'];
MatrixProfileFilePath = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/Accuracy'];

% RMTMotifFilePath = ['/Users/sicongliu/Desktop/MyMotif/EnergyComputeAccuracy/AccuracyRMT'];
RMTMotifFilePath = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/AccuracyMotif2_3'];

savePathRMT = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/Result_RMT_Motif'];
savePathMatrixProfile = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/Result_MStamp_Motif'];

weighted = 0;

% iterate file to for upload
testCaseIndex = 1 : 10;
% TS_index = [17, 20, 33, 37, 38, 40, 52, 59, 61, 69, 71, 81, 83, 86, 91, 92, 100, 104, 113, 115, 121, 130, 132, 133, 138, 141, 142, 143, 148, 151]; % MoCap Dataset
%% From Silv 
%load([datasetPath,'data\FeaturesToInject\allTSid.mat']); % this file contains the original TS Names
% TS_index = AllTS;
TS_index = [17]; % MoCap Dataset

% strategy = [1 : 9];
% strategy = [1, 3, 4, 6, 7, 9];
strategy = [3];
% num_of_motif = [1:3];
num_of_motif = [2:3];
% amp_scale = [0, 0.1, 0.25, 0.5, 0.75, 1]; % 0.5 0.75 0 1
amp_scale = [0.1, 1]; % 0.5 0.75 0 1



MatrixProfileEntropy = [];
RMTMotifEntropy = [];

timeOverlapThresholds = [0.1, 0.25, 0.5, 0.75, 1];
for i = 1 : size(num_of_motif, 2)
    for ss = 1 : size(strategy, 2)
        for m = 1 : size(amp_scale, 2)
            for tt = 1 : size(timeOverlapThresholds, 2)
                for kk = 1 : size(algorithm_type, 2)
                    current_iteration_precision = cell(size(TS_index, 2) * size(testCaseIndex, 2), 1);
                    current_iteration_recall = cell(size(TS_index, 2) * size(testCaseIndex, 2), 1);
                    current_iteration_FScore = cell(size(TS_index, 2) * size(testCaseIndex, 2), 1);
                    
                    index_count = 1; % keep track of same motif but different number of instances
                    for j = 1 : size(TS_index, 2)
                        for k = 1 : size(testCaseIndex, 2)
                            fprintf('Num of motif: %d, Strategy: %d, TS index: %d, instance: %d, amp scale: %f, timeOverlapThreshold: %f .\n', num_of_motif(i), strategy(ss), TS_index(j), testCaseIndex(k), amp_scale(m), timeOverlapThresholds(tt));
                            GroundTruthFile = [GroundTruthFilePath, num2str(num_of_motif(i)), '_', num2str(TS_index(j)), '_instance_', num2str(testCaseIndex(i)), '_', num2str(amp_scale(m)), '.csv'];
                            
                            MatrixProfileFile = [MatrixProfileFilePath, '/Motif', num2str(num_of_motif(i)), '_', num2str(TS_index(j)), '_instance_', num2str(testCaseIndex(k)), '_', num2str(amp_scale(m)), '.csv'];
                            
                            % RMTMotifFile = [RMTMotifFilePath, num2str(num_of_motif(i)), '/Strategy_', num2str(strategy(ss)), '/AP_DepO_2_DepT_2_Motif', num2str(num_of_motif(i)), '_', num2str(TS_index(j)), '_instance_', num2str(testCaseIndex(k)), '_', num2str(amp_scale(m)), '.csv'];
                            RMTMotifFile = [RMTMotifFilePath, '/Strategy_', num2str(strategy(ss)), '/AP_DepO_2_DepT_2_Motif', num2str(num_of_motif(i)), '_', num2str(TS_index(j)), '_instance_', num2str(testCaseIndex(k)), '_', num2str(amp_scale(m)), '.csv'];
                            
                            threshold = eps; % if it is non-zero
                            timeOverlapThreshold = timeOverlapThresholds(tt);
                            %% From Silv Are this "windowSize" for the  filenames of MStamp???? if yes move outside the for
                            % windowSize = 32; % BirdSong configuration
                            windowSize = 58; % Energy & MoCap dataset configuration 
                            if(weighted == 1)
                                % algorithmType = 'MatrixProfile';
                                % [currentMatrixProfileEntropy, precisionMatrixMatrixProfile, recallMatrixMatrixProfile, FScoreMatrixMatrixProfile] = motifEvaluationWeighted(GroundTruthFile, MatrixProfileFile, algorithmType, windowSize);
                                % algorithmType = 'RMT';
                                % [currentRMTMotifEntropy, precisionMatrixRMT, recallMatrixRMT, FScoreMatrixRMT] = motifEvaluationWeighted(GroundTruthFile, RMTMotifFile, algorithmType, windowSize);
                                
                                % algorithmType = 'RME';
                                % [currentRMEMotifEntropy, precisionMatrixRME, recallMatrixRME, FScoreMatrixRME] = motifEvaluationWeighted(GroundTruthFile, RMEMotifFile, algorithmType, windowSize);
                            else
                                algorithmType = algorithm_type(kk);
                                [currentRMTMotifEntropy, precisionMatrixRMT, recallMatrixRMT, FScoreMatrixRMT, total_index_RMT] = motifEvaluation(GroundTruthFile, RMTMotifFile, algorithmType, windowSize, threshold, timeOverlapThreshold);
                                
                            end
                            
                            % MatrixProfileEntropy = [MatrixProfileEntropy ; currentMatrixProfileEntropy];
                            RMTMotifEntropy = [RMTMotifEntropy ; currentRMTMotifEntropy];
                            RMTsharedFolder = [savePathRMT, num2str(num_of_motif(i)), '/Strategy_', num2str(strategy(ss)), '/amp_scale_', num2str(amp_scale(m)), '_TO_', num2str(timeOverlapThreshold)];
                           
                            if(exist(RMTsharedFolder,'dir')==0)
                                mkdir(RMTsharedFolder);
                            end
                            
                            savePathRMTPrecision = [RMTsharedFolder, '/RMTPrecision_', num2str(index_count), '.csv'];
                            savePathRMTRecall = [RMTsharedFolder, '/RMTRecall_', num2str(index_count), '.csv'];
                            savePathRMTFScore = [RMTsharedFolder, '/RMTFScore_', num2str(index_count), '.csv'];
                            savePathRemainIndex = [RMTsharedFolder, '/RemainIndex', num2str(index_count), '.csv'];
                            csvwrite(savePathRMTPrecision, precisionMatrix);
                            csvwrite(savePathRMTRecall, recallMatrix);
                            csvwrite(savePathRMTFScore, FScoreMatrix);
                            csvwrite(savePathRemainIndex, total_index);
                            
                            current_iteration_precision{index_count} = precisionMatrix;
                            current_iteration_recall{index_count} = recallMatrix;
                            current_iteration_FScore{index_count} = FScoreMatrix;
                            
                            index_count = index_count + 1;
                        end
                    end
                end
                
                cur_strategy = strategy(ss);
                cur_num_of_motif = num_of_motif(i);
                fprintf('Aggregating... \n');
                % able to aggregate the precision and recall
                % information here
                for kk = 1 : size(algorithm_type, 2)
                    cur_algorithm_type = algorithm_type(kk);
                    sharedFolder = ['/Users/sliu104/Desktop/MyMotif/Silvestro_Sep_18_MoCap/Result_', cur_algorithm_type, '_Motif', num2str(cur_num_of_motif), '/Strategy_', num2str(cur_strategy), '/amp_scale_', num2str(amp_scale(aa)), '_TO_', num2str(timeOverlapThreshold)];
                    precision_file_path = [sharedFolder, '/', cur_algorithm_type, 'Precision_'];
                    recall_file_path = [sharedFolder, '/', cur_algorithm_type, 'Recall_'];
                    FScore_file_path = [sharedFolder, '/', cur_algorithm_type, 'FScore_'];
                    aggregated_precision_file = [precision_file_path, 'aggregated.csv'];
                    aggregated_recall_file = [recall_file_path, 'aggregated.csv'];
                    aggregated_FScore_file = [FScore_file_path, 'aggregated.csv'];
                    
                    aggregated_precision = zeros(index_count, cur_num_of_motif+1+1);
                    aggregated_recall = zeros(index_count, cur_num_of_motif+1+1);
                    aggregated_FScore = zeros(index_count, cur_num_of_motif+1+1);
                    
                    for ii = 1 : index_count
                        precision_matrix = current_iteration_precision{ii};
                        recall_matrix = current_iteration_recall{ii};
                        FScore_matrix = current_iteration_FScore{ii};
                        
                        new_precision_matrix = zeros(size(precision_matrix, 1) + 1, size(precision_matrix, 2) + 1);
                        new_recall_matrix = zeros(size(recall_matrix, 1) + 1, size(recall_matrix, 2) + 1);
                        new_FScore_matrix = zeros(size(FScore_matrix, 1) + 1, size(FScore_matrix, 2) + 1);
                        
                        num_output_class = size(precision_matrix, 1);
                        num_of_class = size(precision_matrix, 2);
                        
                        % compute row-wise average -- for checking purpose
                        for jj = 1 : num_output_class
                            new_precision_matrix(jj, 1 : size(precision_matrix, 2)) = precision_matrix(jj, :);
                            if(sum(isnan(precision_matrix(jj, :)) > 0))
                                my_precision = max(precision_matrix(jj, :));
                            else
                                my_precision = mean(precision_matrix(jj, :));
                            end
                            new_precision_matrix(jj, size(new_precision_matrix, 2)) = my_precision;
                            
                            new_recall_matrix(jj, 1 : size(recall_matrix, 2)) = recall_matrix(jj, :);
                            if(sum(isnan(recall_matrix(jj, :)) > 0))
                                my_recall = max(recall_matrix(jj, :));
                            else
                                my_recall = mean(recall_matrix(jj, :));
                            end
                            new_recall_matrix(jj, size(new_recall_matrix, 2)) = my_recall;
                            
                            new_FScore_matrix(jj, 1 : size(FScore_matrix, 2)) = FScore_matrix(jj, :);
                            if(sum(isnan(FScore_matrix(jj, :)) > 0))
                                my_FScore = max(FScore_matrix(jj, :));
                            else
                                my_FScore = mean(FScore_matrix(jj, :));
                            end
                            new_FScore_matrix(jj, size(new_FScore_matrix, 2)) = my_FScore;
                        end
                        
                        % compute column-wise average -- real average stats
                        temp_matrix = new_precision_matrix(1 : end - 1, :);
                        for jj = 1 : size(new_precision_matrix, 2)
                            nan_index = isnan(temp_matrix(:, jj));
                            number_index = find(nan_index ~= 1);
                            temp_array = nonzeros(temp_matrix(number_index, jj));
                            if (size(temp_array,1)==0)%% the case thaqt in one experiment   we do not find any cluster about motif i
                                new_precision_matrix(size(new_precision_matrix, 1), jj)=0;
                            else
                                new_precision_matrix(size(new_precision_matrix, 1), jj) = sum(temp_array) / (size(temp_array, 1)) ;
                            end
                        end
                        
                        temp_matrix = new_recall_matrix(1 : end - 1, :);
                        for jj = 1 : size(new_recall_matrix, 2)
                            nan_index = isnan(temp_matrix(:, jj));
                            number_index = find(nan_index ~= 1);
                            temp_array = nonzeros(temp_matrix(number_index, jj));
                            if (size(temp_array,1)==0) %% the case thaqt in one experiment   we do not find any cluster about motif i
                                new_recall_matrix(size(new_recall_matrix, 1), jj) = 0;
                            else
                                new_recall_matrix(size(new_recall_matrix, 1), jj) = sum(temp_array) / (size(temp_array, 1)) ;
                            end
                        end
                        
                        temp_matrix = new_FScore_matrix(1 : end - 1, :);
                        for jj = 1 : size(new_FScore_matrix, 2)
                            nan_index = isnan(temp_matrix(:, jj));
                            number_index = find(nan_index ~= 1);
                            temp_array = nonzeros(temp_matrix(number_index, jj));
                            if (size(temp_array,1)==0) %% the case that in one experiment   we do not find any cluster about motif i
                                new_FScore_matrix(size(new_FScore_matrix, 1), jj) = 0;
                            else
                                new_FScore_matrix(size(new_FScore_matrix, 1), jj) = sum(temp_array) / (size(temp_array, 1)) ;
                            end
                        end
                        
                        aggregated_precision(ii, 1) = ii;
                        aggregated_recall(ii, 1) = ii;
                        aggregated_FScore(ii, 1) = ii;
                        
                        aggregated_precision(ii, 2 : end) = precision_matrix(size(new_precision_matrix, 1), :);
                        aggregated_recall(ii, 2 : end) = recall_matrix(size(new_recall_matrix, 1), :);
                        aggregated_FScore(ii, 2 : end) = FScore_matrix(size(new_FScore_matrix, 1), :);
                    end
                    
                    csvwrite(aggregated_precision_file, aggregated_precision);
                    csvwrite(aggregated_recall_file, aggregated_recall);
                    csvwrite(aggregated_FScore_file, aggregated_FScore);
                end
                clear current_iteration_precision current_iteration_recall current_iteration_FScore
            end
        end
    end
end

fprintf('All done .\n');