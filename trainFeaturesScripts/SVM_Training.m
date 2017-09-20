clear;
clc;

%% Input variable
% featureFolder = Folder that contains the features
% dataFolder =  Folder that contains the data
% destFolder = Destination where to save trained SVM model
% 
% SelectDataset = 1 full scale  change the descriptor start end position
%                 2 for all the others
% startDescr = location where the descriptor start
% endDescr   = location where the descriptor ends
% dataSize   = number of timeseries in the dataset 
% trainingPercentage = what percentage of data we should use to train the SVM
% ClassIndexes Sart and end index for eleents of each class


featureFolder = ['D:\Test Traning\dataFeatures'];
dataFolder = ['D:\Test Traning\data'];
destFolder = ['D:\Test Traning\dataFeatures\SVMTrained\'];

SelectDataset= 1; % 1 means full scale ; 2 means hybrid or fix scale
startDescr =8;
endDescr = 135;
%saveFolder = '.';
dataSize = 184;
trainingPercentage = 0.6; 
% OBSERVATION: take 60% require to do multiple test  using the remaning 40%  to understand what is the best set to use for the query.


if(SelectDataset ==1)
    startDescr =11;
    endDescr = 138;
end

% MoCap data Class
ClassIndexes = [1, 15, 51, 81, 99, 118, 149, 179, 185];

% read all the features
AllFeatures = cell(dataSize, 1);
ProcessedAllFeatures = cell(dataSize, 1);
timeSeriesLength =zeros(1,dataSize);
for i = 1 : dataSize
    featurePath = [featureFolder,'/feature',num2str(i),'.mat'];
    AllFeatures{i} = load(featurePath); % feature is frame1 from cell structure
    dataPath = [dataFolder, '/', num2str(i), '.csv'];
    data = csvread(dataPath);
    timeSeriesLength(1,i) = size(data, 1);
end

labels =1:size(ClassIndexes,2)-1;
for queryID =1:184
    % Select index of the elements in each class
    training_Sets=[];
    for clusterID =1:8
            training_Sets{clusterID} = randomizeSet(queryID,ClassIndexes(clusterID),ClassIndexes(clusterID+1)-1, trainingPercentage );
    end
    for clusterID = 1:size(ClassIndexes,2)-1;
        'training query class' 
        %trainingIDX = randomizeSet(queryID,ClassIndexes(clusterID),ClassIndexes(clusterID+1)-1, trainingPercentage );
        trainingIDX  = [];
        ClassificationIDX= [];
        AllFeaturesClass =[];
        for i = 1: size(ClassIndexes, 2)-1
            if(i == clusterID) % my class
                trainingIDX = [trainingIDX,training_Sets{i}];
                AllFeaturesIN =[];
                for j =1 : size(training_Sets{i},2)
                    AllFeaturesIN = [AllFeaturesIN,AllFeatures{training_Sets{i}(j)}.frame1];
                end
                AllFeaturesClass =[AllFeaturesClass,AllFeaturesIN];
                ClassificationIDX= [ClassificationIDX;ones(size(AllFeaturesIN,2),1)];
            else % other class
                trainingIDX=[trainingIDX,training_Sets{i}];%[trainingSetIrrelevant,randomizeSet(queryID,Array(i),Array(i+1)-1, 0.6 )];
                AllFeaturesNO =[];
                for j =1 : size(training_Sets{i},2)
                    AllFeaturesNO = [AllFeaturesNO,AllFeatures{training_Sets{i}(j)}.frame1];
                end
                AllFeaturesClass =[AllFeaturesClass,AllFeaturesNO];
                ClassificationIDX= [ClassificationIDX;ones(size(AllFeaturesNO,2),1)*2];
            end
        end
        
    

        for OT =1: 3
            for OD = 1:3
                index_Of_Octave= (AllFeaturesClass(5,:)==OD & AllFeaturesClass(6,:)==OT )
                OctaveClassification=ClassificationIDX(index_Of_Octave,1);
                OctaveFeatures = AllFeaturesClass(:,index_Of_Octave);
                % Xilun Suggested function
                Mdl = fitcecoc(OctaveFeatures(startDescr:endDescr,:)',OctaveClassification);
                % From my reading  this should be fine
                SVMModel = fitcsvm(X,Y,'KernelFunction','linear','Standardize',true,'ClassNames',{'1','2'});
                
                if(exist(strcat(destFolder,num2str(queryID),'\'),'dir')==0)
                    mkdir(strcat(destFolder,num2str(queryID),'\'));
                end
               
                save([destFolder,num2str(queryID),'\','Class_',num2str(clusterID),'_OD_',num2str(OD),'_OT_',num2str(OT),'.mat'],'Mdl');
            end
        end
        
    end
end