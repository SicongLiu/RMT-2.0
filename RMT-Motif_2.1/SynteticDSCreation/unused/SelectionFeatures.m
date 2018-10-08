


FeaturePath = 'D:\Motif_Results\Datasets\Building_MultiStory\Features_RMT\';
             %'D:\Motif_Results\Datasets\Mocap\Features_RMT\';
DestDataPath = 'D:\Motif_Results\Datasets\SynteticDataset\Energy\';%Mocap\';
DepO=2;
DepT=2;
nummotifs=5;
TSCOnsidered=30;
AllTS= randi([1,100],1,TSCOnsidered);%randi([1,184],1,TSCOnsidered);
for numberofTS=1:TSCOnsidered
    TS_name = num2str(AllTS(numberofTS));
    
    savepath1 = [FeaturePath,TS_name,'/feature_',TS_name,'.mat'];
    savepath2 = [FeaturePath,TS_name,'/idm_',TS_name,'.mat'];
    savepath3 = [FeaturePath,TS_name,'/MetaData_',TS_name,'.mat'];
    load(savepath1);
    load(savepath2);
    load(savepath3);
    
    indexfeatureGroup = (frame1(6,:)==2 & frame1(5,:)==2);
    X=frame1(:,indexfeatureGroup);
    Check= sum(X(11:end,:)>eps);
    X(:,Check>=64)=[];
    [rows,colmn]= size(X);
    dpscale = csvread(strcat(FeaturePath,TS_name,'/DistancesDescriptor\DepdScale_IM_',TS_name,'_DepO_',num2str(DepO),'_TimeO_',num2str(DepT),'.csv'));
    dpscale(:,Check>=64)=[];
    Features=[];
    Dependency=[];
    for i=1:nummotifs
        random= randi([1,size(X,2)],1,1);
        A = X(:, random);
        B =dpscale(:,random);
        Features =[Features,A];
        Dependency= [Dependency,B];
        index = X(1,:)==A(1,1);
        
        dpscale(:,index) =[];
        X(:,index) =[];
        
    end
    
    if(exist([DestDataPath,'\FeaturesToInject\'],'dir')==0)
        mkdir([DestDataPath,'\FeaturesToInject\']);
    end
    
    csvwrite([DestDataPath,'\FeaturesToInject\','Depd',TS_name,'.csv'],Dependency);
    csvwrite([DestDataPath,'\FeaturesToInject\','Features',TS_name,'.csv'],Features);
end