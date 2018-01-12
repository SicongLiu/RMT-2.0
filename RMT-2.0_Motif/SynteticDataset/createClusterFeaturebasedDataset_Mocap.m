
FeaturePath = 'D:\Motif_Results\Datasets\Mocap\Features_RMT\1\';
kindofBasicTS='randomWalk';%'Sinusoidal';%'flat';%
if(strcmp(kindofBasicTS,'flat')==1)
    KindOfDataset='FlatTS_MultiFeatureDiffClusters\';
elseif(strcmp(kindofBasicTS,'Sinusoidal')==1)
    KindOfDataset = 'CosineTS_MultiFeatureDiffClusters\';%
elseif(strcmp(kindofBasicTS,'randomWalk')==1)
    KindOfDataset = 'RandomWalkTS_MultiFeatureDiffClusters\';%
end
DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\data';
DestLocationPath = 'D:\Motif_Results\Datasets\SynteticDataset\location';
sinFreq=1;
TEST = 'Mocap_test6';

TS_name = num2str(1);

DepO=2;
DepT=2;
offSpace=0;

nummotifs = 2;
numfeaturestoInject = 2;
%numFeatureforClass=2;%1;
NumInstances=10;
dpscale=[];
frame1=[];


    savepath1 = [FeaturePath,'feature_',TS_name,'.mat'];
    savepath2 = [FeaturePath,'idm_',TS_name,'.mat'];
    savepath3 = [FeaturePath,'MetaData_',TS_name,'.mat'];
    load(savepath1);
    load(savepath2);
    load(savepath3);
    
%% get some features k
indexfeatureGroup = (frame1(6,:)==2 & frame1(5,:)==2);
X=frame1(:,indexfeatureGroup);
[rows,colmn]= size(X);
random= randi([1,colmn],1,nummotifs);

dpscale = csvread(strcat(FeaturePath,'DistancesDescriptor\DepdScale_IM_',TS_name,'_DepO_',num2str(DepO),'_TimeO_',num2str(DepT),'.csv'));

MotifsFeatures=[];
motifdpscale=[];

for ii=1:nummotifs
    A = X(:, random(ii));
    B =dpscale(:,random(ii));
    MotifsFeatures=[MotifsFeatures,A];
    motifdpscale= [motifdpscale,B];
end

[datarows,datacoln]= size(data);
[rows,colmn]= size(MotifsFeatures);
A = MotifsFeatures;
B = motifdpscale;
timescope= A(4,:)*3;%+offSpace;
timeSignal= round(max(2*timescope)*NumInstances+50*NumInstances);


if(strcmp(kindofBasicTS,'randomWalk')==1)
%      rndWalks= rndWalkGeneration(size(data,1),size(data,2)); %%geerate random walk z-normalized
    [rndWalks0_1,rndWalks1] = rndWalkGenerationbigSize(size(data,1),timeSignal,data);%size(data,2),data);
end


origRW1  = rndWalks0_1;%rndWalks1;%rndWalks0_1;%
rndWalks = rndWalks0_1;%rndWalks1;%rndWalks0_1;%

FeatPositions=zeros(NumInstances,4);
Step= floor(datacoln /NumInstances);
pStep=0;

for ii =1:NumInstances
    
    i= randi([1,size(A,2)],1,1);
    intervaltime=(round((A(2,i)-timescope(i))) : (round((A(2,i)+timescope(i)))));
    motifData = data(:,intervaltime((intervaltime>0 & intervaltime<=size(data,2))));
    [~,motifclmn]=size(motifData);
    
    starter = randi([pStep,pStep+Step-motifclmn],1,1);
    FeatPositions(ii,:)=[i,A(2,i),starter,starter+motifclmn-1];
    if (offSpace ~=0)
        intervaltime=(round((A(2,i)-timescope(i)-offSpace)) : (round((A(2,i)+timescope(i)+offSpace))));
        motifData = data(:,intervaltime((intervaltime>0 & intervaltime<=size(data,2))));       
        [~,motifclmn]=size(motifData);
        starter = randi([pStep,pStep+Step-motifclmn],1,1);
    end
    if(strcmp(kindofBasicTS,'randomWalk')==1 | strcmp(kindofBasicTS,'flat')==1)
        M=motifData;   
%% this rescale the motif to inject into a lower size
        ScaleValues= randi([1,12],1,1);
        M= imresize(M,[size(M,1), (motifclmn-ScaleValues)]);
        [~,motifclmn]=size(M);

%% this scale the starting point avoiding picks        
%         NotFIDXvariate=1:62;
%         M(NotFIDXvariate(B(:,i)==0),:)=M(NotFIDXvariate(B(:,i)==0),:)+ rndWalks0_1(NotFIDXvariate(B(:,i)==0),starter:starter+motifclmn-1);
%         valueRND  = rndWalks(:,starter);
%         valueM = M(:,1);
%         scaleValues = valueM - valueRND;
% 
%         for variateiterate = 1: length(valueM);
%             M(variateiterate,:) = M(variateiterate,:)-scaleValues(variateiterate);
%         end
%        rndWalks(:,starter:starter+motifclmn-1) = M(:,:);

%% Injection with pick
    rndWalks(B((B(:,i)>0),i),starter:starter+motifclmn-1) = M(B(B(:,i)>0,i),:);%motifData(B(B(:,i)>0,i),:);
    
    elseif(strcmp(kindofBasicTS,'Sinusoidal')==1)       
       rndWalks(B((B(:,i)>0),i),starter:starter+motifclmn-1)  = motifData(B(B(:,i)>0,i),:);       
    end
    pStep=pStep+Step;
end

 if(exist([DestDataPath,'\IndexEmbeddedFeatures\',TEST,'\'],'dir')==0)
    mkdir([DestDataPath,'\IndexEmbeddedFeatures\',TEST,'\']);
 end    
csvwrite([DestDataPath,'\',TEST,'.csv'],rndWalks);
csvwrite([DestDataPath,'\IndexEmbeddedFeatures\','rndData_',TEST,'.csv'],origRW1);
csvwrite([DestDataPath,'\IndexEmbeddedFeatures\',TEST,'\','FeaturePosition_',TEST,'.csv'],FeatPositions);
csvwrite([DestDataPath,'\IndexEmbeddedFeatures\',TEST,'\','dpscale_',TEST,'.csv'],B);
csvwrite([DestDataPath,'\IndexEmbeddedFeatures\',TEST,'\','FeaturesEmbedded_',TEST,'.csv'],A);
