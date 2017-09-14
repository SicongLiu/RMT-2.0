% organize time series result into SVD, first use SVD on descriptors, then use relevant and irrelavant count
clear;
clc;

% classIndex = csvread('./classindex.csv');

featureFolder = ['D:\Test Traning\dataFeatures'];
dataFolder = ['D:\Test Traning\data'];
% saveFolder = '/Users/sicongliu/Desktop/features/MoCapUnionScale';
saveFolder = '.';
dataSize = 184;

% MoCap data
Array = [1, 15, 51, 81, 99, 118, 149, 179, 185];
% Array = [1, 15, 51, 81, 99, 118, 149, 179];
       % testing data PCA
        options = [];
        options.ReducedDim = 10;
% load all features
AllFeatures = cell(dataSize, 1);
% depdIndex, timeStart, timeEnd, timeOctave, depdOctave, 10-D descriptor
ProcessedAllFeatures = cell(dataSize, 1);
for i = 1 : dataSize
    featurePath = [featureFolder,'/feature',num2str(i),'.mat'];
    AllFeatures{i} = load(featurePath); % feature is frame1 from cell structure
    dataPath = [dataFolder, '/', num2str(i), '.csv'];
    data = csvread(dataPath);
    timeSeriesLength = size(data, 1);
    rangeFeatures = zeros(size(AllFeatures{i}.frame1, 2), 16);
    for j = 1 : size(AllFeatures{i}.frame1, 2)
        % time ranges from timeCenter - 1*sigmaTime to timeCenter + 1*sigmaTime
        timeStart = max(AllFeatures{i}.frame1(2, j) - AllFeatures{i}.frame1(4, j), 1);
        timeEnd = min(AllFeatures{i}.frame1(2, j) + AllFeatures{i}.frame1(4, j), timeSeriesLength);
        rangeFeatures(j, 4) = AllFeatures{i}.frame1(1, j); % Dependency center
        rangeFeatures(j, 3) = AllFeatures{i}.frame1(2, j); % Time center
        rangeFeatures(j, 5) = AllFeatures{i}.frame1(5, j); % Dep octave
        rangeFeatures(j, 6) = AllFeatures{i}.frame1(6, j); % Time octave
        rangeFeatures(j, 1) = timeStart;
        rangeFeatures(j, 2) = timeEnd;
    end
    ProcessedAllFeatures = rangeFeatures;
end

p = tic;
for clusterID = 1:8
    for queryID = Array(clusterID):Array(clusterID + 1) - 1
        fprintf('query ID: %d, clusterID: %d. \n', queryID, clusterID);
        testData=[];

        trainingSetRelevant = randomizeSet(queryID,Array(clusterID),Array(clusterID+1)-1, 0.6 );
        
        trainingSetIrrelevant =[];
        for i = 1: size(Array, 2)-1
            if(i == clusterID)
            else
                trainingSetIrrelevant=[trainingSetIrrelevant,randomizeSet(queryID,Array(i),Array(i+1)-1, 0.6 )]
%                 dataFromOtherCluster = Array(i):Array(i+1)-1;
%                 trainSize = floor(size(dataFromOtherCluster, 2)*0.6);
%                 tempData = dataFromOtherCluster(1 : trainSize);
%                 testData = [testData tempData];
            end
        end
        
        %% each cluster use 60% train 40%(the rest) for test
        training_Relevant_Features = [];
        trainingIrrelevantFeatures = [];
%         dataFromCurrentCluster = Array(clusterID):Array(clusterID+1)-1;
%         % currentClusterFileSize = size(dataFromCurrentCluster, 2);
%         
%         trainSize = floor(size(dataFromCurrentCluster, 2)*0.6);
%         % trainingData1 = dataFromCurrentCluster(2 : trainSize+1);
%         trainingDataStart = dataFromCurrentCluster(2);
%         
%         testData = testData';
%         trainingFeatures = [];
%         rangeFeatures = [];
%         
%         countTrainingTimeSeries = 1;
        % load training data
        % clusterID = 2;
        % queryID = 1;
       for i=1:size(trainingSetRelevant,2)
%         while(countTrainingTimeSeries <=trainSize)%for i = 1 : size(trainingData1, 2) % true data
%             if (countTrainingTimeSeries + Array(clusterID)-1)== queryID
%                 trainSize=trainSize+1;
%             else
                % dataElementIndex = trainingData1(i);
                
                % XsaveFolder1 = [featureFolder,'/feature',num2str(dataElementIndex),'.mat'];
                % load(XsaveFolder1);
                training_Relevant_Features = [training_Relevant_Features, AllFeatures{trainingSetRelevant(i)}.frame1];%countTrainingTimeSeries + Array(clusterID)-1}.frame1];

%             end
%             countTrainingTimeSeries = countTrainingTimeSeries+1;
       end
       TrainingRelevant_rangeFeatures = ComposeFeatures(training_Relevant_Features,timeSeriesLength);
        
        
        for i=1:size(trainingSetIrrelevant,2)
%         while(countTrainingTimeSeries <=trainSize)%for i = 1 : size(trainingData1, 2) % true data
%             if (countTrainingTimeSeries + Array(clusterID)-1)== queryID
%                 trainSize=trainSize+1;
%             else
                % dataElementIndex = trainingData1(i);
                
                % XsaveFolder1 = [featureFolder,'/feature',num2str(dataElementIndex),'.mat'];
                % load(XsaveFolder1);
                trainingIrrelevantFeatures = [trainingIrrelevantFeatures, AllFeatures{trainingSetIrrelevant(i)}.frame1];%countTrainingTimeSeries + Array(clusterID)-1}.frame1];

%             end
%             countTrainingTimeSeries = countTrainingTimeSeries+1;
        end
       
        TrainingIrrelevant_rangeFeatures = ComposeFeatures(trainingIrrelevantFeatures,timeSeriesLength);
        
        
        
%   %      rawFeatures = [ featureDepd'  trainedVector featureTime' featureDepdOctave' featureTimeOctave'];
% %         [C, Xia, ic]= unique(rawFeatures(:, end-3), 'rows'); % ia is the remaining column
% %         uniqueFeatures = (rawFeatures(Xia, :));
        %% if paired start from 4
        [C,Xia,ic] = unique(TrainingRelevant_rangeFeatures(4:end,:)','rows');
        UniqueRelevantFeatures_Silv = TrainingRelevant_rangeFeatures(:,Xia);
        [C,Xia,ic] = unique(TrainingIrrelevant_rangeFeatures(4:end,:)','rows');
        UniqueIrrelevantFeatures_Silv = TrainingIrrelevant_rangeFeatures(:,Xia);
        NumRelevantUnion = size(UniqueRelevantFeatures_Silv,2);
        %% if unpaired start from 5
% %         descriptorRange = zeros(2, size(trainedVector, 2));
% %         descriptorRange(1,:) = min(uniqueFeatures(:,5:end));
% %         descriptorRange(2,:) = max(uniqueFeatures(:,5:end));
        
        descriptorRange_Silv = zeros(2,options.ReducedDim);
        descriptorRange_Silv(1,:) = min([UniqueRelevantFeatures_Silv(7:end,:)' ; UniqueIrrelevantFeatures_Silv(7:end,:)']);
        descriptorRange_Silv(2,:) = max([UniqueRelevantFeatures_Silv(7:end,:)' ; UniqueIrrelevantFeatures_Silv(7:end,:)']);
        
        % cluster descriptors on training data
        
        resolution = 2;
        % assume there would be duplicate here
        % rawFeatures(:, 5:end) = clusterDescrs(trainedVector, descriptorRange, resolution);
% %         rawFeatures(:, 2:end-3) = clusterDescrs(trainedVector, descriptorRange, resolution);
        supportVar = clusterDescrs(TrainingRelevant_rangeFeatures(7:16,:)', descriptorRange_Silv, resolution);
        TrainingRelevant_rangeFeatures(7:16,:) =supportVar';
        supportVar = clusterDescrs(TrainingIrrelevant_rangeFeatures(7:16,:)', descriptorRange_Silv, resolution);
        TrainingIrrelevant_rangeFeatures(7:16,:) =supportVar';
        % update raw feature
        % uniqueFeatures(:, 5:end) = clusterDescrs(uniqueFeatures(:, 5:end), descriptorRange, resolution);

% %         uniqueFeatures(:, 2:end-3) = clusterDescrs(uniqueFeatures(:, 5:end), descriptorRange, resolution);
%         supportVar = clusterDescrs(UniqueFeatures_Silv(7:end,:)', descriptorRange_Silv, resolution);
%         UniqueFeatures_Silv(7:end,:) = supportVar';
        supportVar = clusterDescrs(UniqueRelevantFeatures_Silv(7:end,:)', descriptorRange_Silv, resolution);
        UniqueRelevantFeatures_Silv(7:end,:) = supportVar';
        supportVar = clusterDescrs(UniqueIrrelevantFeatures_Silv(7:end,:)', descriptorRange_Silv, resolution);
        UniqueIrrelevantFeatures_Silv(7:end,:) = supportVar';
%         % unique again UniqueRelevantFeatures_Silv
%         [C, Xia, ic]= unique(uniqueFeatures(:, end-3), 'rows'); % ia is the remaining column
%         uniqueFeatures = (uniqueFeatures(Xia, :));

        %% if paired start from 4 unpaired start from 5
%         [C, Xia, ic]=unique(UniqueFeatures_Silv(4:end,:)', 'rows');
%         UniqueFeatures_Silv = UniqueFeatures_Silv(:,Xia);
        [C, Xia, ic]=unique(UniqueRelevantFeatures_Silv(4:end,:)', 'rows');
        UniqueRelevantFeatures_Silv = UniqueRelevantFeatures_Silv(:,Xia);
        NumRelevantUnion = size(UniqueRelevantFeatures_Silv,2);
        
        UnionTrainingFeatures_Silv= [UniqueRelevantFeatures_Silv,UniqueIrrelevantFeatures_Silv];
        [C, Xia, ic]=unique(UnionTrainingFeatures_Silv(4:end,:)', 'rows');
        UnionTrainingFeatures_Silv = UnionTrainingFeatures_Silv(:,Xia);
        

        % load data to compute weight
        TrainingQuery_RelevantFeatures = [];
        TrainingQuery_IrrelevantFeatures = [];
        TrainingSetQuery_RelevantFeatures  = randomizeSet(queryID,Array(clusterID),Array(clusterID+1)-1, 0.6 );
        
        TrainingSetQuery_IrrelevantFeatures =[];
        for i = 1: size(Array, 2)-1
            if(i == clusterID)
            else
                TrainingSetQuery_IrrelevantFeatures =[TrainingSetQuery_IrrelevantFeatures,randomizeSet(queryID,Array(i),Array(i+1)-1, 0.6 )]
            end
        end
        %% read query set Relevant
        for i=1:size(TrainingSetQuery_RelevantFeatures,2)
            TrainingQuery_RelevantFeatures = [TrainingQuery_RelevantFeatures, AllFeatures{TrainingSetQuery_RelevantFeatures(i)}.frame1];
        end
        %% read irrelevant object
        for i=1:size(TrainingSetQuery_IrrelevantFeatures,2)
                TrainingQuery_IrrelevantFeatures = [TrainingQuery_IrrelevantFeatures, AllFeatures{trainingSetIrrelevant(i)}.frame1];
        end
        
        TrainingQuery_RelevantFeatures_range = ComposeFeatures(TrainingQuery_RelevantFeatures,timeSeriesLength);
        TrainingQuery_IrrelevantFeatures_range = ComposeFeatures(TrainingQuery_IrrelevantFeatures,timeSeriesLength);
        
        supportVar = clusterDescrs(TrainingQuery_RelevantFeatures_range(7:end,:)', descriptorRange_Silv, resolution);
        TrainingQuery_RelevantFeatures_range(7:end,:) = supportVar';
        supportVar = clusterDescrs(TrainingQuery_IrrelevantFeatures_range(7:end,:)', descriptorRange_Silv, resolution);
        TrainingQuery_IrrelevantFeatures_range(7:end,:) = supportVar';
%         for i = 1 : size(testData, 1)
%             dataElementIndex = testData(i);
%             testFeatures = [testFeatures AllFeatures{dataElementIndex}.frame1];
%         end
%         
%         featureDepdCenter = testFeatures(1, :);
%         featureTimeCenter = testFeatures(2, :);
%         testFeatureTimeOctave = testFeatures(6, :);
%         testFeatureDepdOctave = testFeatures(5, :);
%         testFeatureDescriptor = testFeatures(8:135, :)';
%         
%         % traing SVD on testing data
%         % SVD on test data descriptors
%         
%  
%         row=0;
%         
%         [trainedVector1, trainValues] = PCA(testFeatureDescriptor',options);
%         % testFeatureDescriptor = testFeatureDescriptor*trainedVector;
%         testFeatureDescriptor = trainedVector1;
%         % testing data clustering
%         testFeatureDescriptor = clusterDescrs(testFeatureDescriptor, descriptorRange, resolution);
%         
%          XappCount = zeros(size(uniqueFeatures, 2), 2);
          XappCount = zeros(size(UnionTrainingFeatures_Silv, 2), 2);
%         rawTestFeatures =[featureDepdCenter' featureTimeCenter' testFeatureDepdOctave' testFeatureTimeOctave'  testFeatureDescriptor];
        
        % using testing and training to compute relevance feedback
        for i = 1 : size(XappCount, 1)
            % Xtrain = uniqueFeatures(i,:);
            Xtrain = UnionTrainingFeatures_Silv(:,i)';
            
            % need to modify the look-up function
            
            % compute the frequency of a training vector appears in the
            % training set
            tt = featureLookUp_Silv(TrainingQuery_RelevantFeatures_range, Xtrain);
%             tt = find(all(bsxfun(@eq, rawFeatures, Xtrain), 2));
             XappCount(i, 1) = size(tt, 1);
            
            % compute the frequency of a training vector appears in the
            % testing set
            tt = featureLookUp_Silv(TrainingQuery_IrrelevantFeatures_range, Xtrain);
            %tt = find(all(bsxfun(@eq, rawTestFeatures, Xtrain), 2));
            XappCount(i, 2) = size(tt, 1);
        end
        % compute score, no need to sort
        Relevance = size(TrainingQuery_RelevantFeatures_range,2);
%         Relevance = floor(size(dataFromCurrentCluster, 2)*0.6); % original training size
%         InRelevance = size(testData, 1);
        InRelevance = size (TrainingQuery_IrrelevantFeatures_range,2);
        
        featureImportance = relevanceFeedback(XappCount, Relevance, InRelevance);
        % relevance feedback done
        
        csvwrite([saveFolder,'/importance',num2str(queryID), '_', num2str(clusterID), '.csv'], featureImportance);
        csvwrite([saveFolder,'/uniqueFeature',num2str(queryID), '_', num2str(clusterID), '.csv'], uniqueFeatures);
        
        % save project matrix
        csvwrite([saveFolder,'/projectMatrix',num2str(queryID), '_', num2str(clusterID), '.csv'], trainedVector);
        
        % save projected descr range
        csvwrite([saveFolder,'/descrRange', num2str(queryID), '_', num2str(clusterID), '.csv'], descriptorRange);
        
        csvwrite([saveFolder,'/testObj', num2str(queryID), '_', num2str(clusterID), '.csv'], testData);
        csvwrite([saveFolder,'/trainObj', num2str(queryID), '_', num2str(clusterID), '.csv'], trainingData1);
        csvwrite([saveFolder,'/training', num2str(queryID), '_', num2str(clusterID), '.csv'], trainingData1);
    end
end
time = toc(p);
csvwrite([saveFolder,'/trainingTime.csv'], time);
fprintf('All done, \n');