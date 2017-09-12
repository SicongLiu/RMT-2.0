close all;
clc;
clear;

PATH_dataset ='D:\BirdSong\data\';
%PATH_coordinates='D:\Mocap _ RMT2\Location matrix\';
saveFeaturesPath='D:\BirdSong\Features\';
%% sift parameters
% x - variate
% y - time
% oframes - octaves
% sigmad - sigma dependency (variate)
% sigmat - sigma time (time)
% pricur - principle curvature
DeOctTime = 2;
DeOctDepd = 2;
DeLevelTime = 4;%6;%
DeLevelDepd = 4;%6;%
DeSigmaDepd = 0.4;%0.4;%0.6;%0.4;%0.5;%
DeSigmaTime = 3.2298;%4*sqrt(2);%1.6*2^(1/(DeLevelTime));%(1.6*2^(1/DeLevelTime))/2;%1.6*2^(1/(DeLevelTime));%
%4*sqrt(2);%2.5*2^(1/DeLevelTime);%1.6*2^(1/DeLevelTime);%4*sqrt(2);%2*1.6*2^(1/DeLevelTime);%  8;%4*sqrt(2);%1.2*2^(1/DeLevelTime);%
thresh = 0.04 / (DeLevelTime) / 2 ;%0.04;%
DeGaussianThres = 6;%0.1;%0.001;%0.7;%0.3;%1;%0.6;%2;%6; % TRESHOLD with the normalization of hte distance matrix should be  between 0 and 1
DeSpatialBins = 4; %NUMBER OF BINs
r= 10; %5 threshould variates

% manually create location matrix
%% set up location matrix
IDM1 = [1:13];
IDM2 = [1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7];
IDM3 = [1, 2, 2, 3, 3, 4];
idm2{1} = IDM1;
idm2{2} = IDM2;
idm2{3} = IDM2;
%%% first octave location matrix
LocM1 = zeros(13, 13);
for i = 1 : 13
    LocM1(i, i) = 1;
    if(i == 1)
        LocM1(i, i+1) = 1;
        LocM1(i+1, i) = 1;
    elseif(i == 13)
        LocM1(i, i-1) = 1;
        LocM1(i-1, i) = 1;
    else
        LocM1(i-1, i) = 1;
        LocM1(i+1, i) = 1;
        LocM1(i, i-1) = 1;
        LocM1(i, i+1) = 1;
    end
end
LocM1 = LocM1 - eye([13 13]);

%%% second octave location matrix
LocM2 = zeros(7, 7);
for i = 1 : 7
    LocM2(i, i) = 1;
    if(i == 1)
        LocM2(i, i+1) = 1;
        LocM2(i+1, i) = 1;
    elseif(i == 7)
        LocM2(i, i-1) = 1;
        LocM2(i-1, i) = 1;
    else
        LocM2(i-1, i) = 1;
        LocM2(i+1, i) = 1;
        LocM2(i, i-1) = 1;
        LocM2(i, i+1) = 1;
    end
end
LocM2 = LocM2 - eye([7 7]);


featureExtractionGaussian = zeros(1, 154);
for TEST =1:154
    TS_name=num2str(TEST)
    data = csvread ([PATH_dataset,num2str(TEST),'.csv']);%
    data(isnan(data))=0;
%     coordinates=csvread(strcat(PATH_coordinates,'LocationMatrixMocap.csv'))';
    p = tic;
    sBoundary=1;
    eBoundary=size(data,1);
     [frames1,descr1,gss1,dogss1,depd1,idm1, time, timee, timeDescr] = sift_gaussianSmooth_BirdSong(data,...
         LocM1 ,LocM2,IDM1, IDM2, DeOctTime, DeOctDepd,...
        DeLevelTime, DeLevelDepd, DeSigmaTime ,DeSigmaDepd,...
        DeSpatialBins, DeGaussianThres, r, sBoundary, eBoundary);
%     [frames1,descr1,gss1,dogss1,depd1,idm1, time, timee, timeDescr] = sift_gaussianSmooth_Silv(data,coordinates', DeOctTime, DeOctDepd,...
%         DeLevelTime, DeLevelDepd, DeSigmaTime ,DeSigmaDepd,...
%         DeSpatialBins, DeGaussianThres, r, sBoundary, eBoundary);
     
    while(size(frames1,2)==0)
        frames1 = zeros(4,1);
        descr2 = zeros(128,1);
    end
    frame1 = [frames1;descr1];
    
    feature = frame1;
    
    featureExtractionGaussian(1, TEST) = featureExtractionGaussian(1, TEST) + toc(p);
    
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
    
    csvwrite(savepath5, time);
    csvwrite(savepath6, timee);
    csvwrite(savepath7, timeDescr);
    
    
    clear frames1 descr1 gss1 dogss1 depd1 idm1 data;
end