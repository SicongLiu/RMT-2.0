clear;
clc;

pathSource = 'D:\Motif_Results\Datasets\SynteticDataset\Mocap\Features_RMT\AccuracyMotif2_3\';
strategy = 3;
num_Motif =2;
percent=[0; 0.1;0.25;0.5;0.75;1];
datasetPath= 'D:\Motif_Results\Datasets\SynteticDataset\Mocap\';
load([datasetPath,'data\FeaturesToInject\allTSid.mat']);
Name_OriginalSeries = AllTS;
destFolder = ['Strategy_',num2str(strategy),'_Check\']
mkdir([pathSource ,destFolder]);
for percentID =2:size(percent,1)
    for Ts_id =1: 30%size(Name_OriginalSeries,1)
        for instanceID=1:10
            pathtoread = [pathSource,'Strategy_',num2str(strategy),'\AP_DepO_2_DepT_2_Motif',num2str(num_Motif),'_',...
                num2str(Name_OriginalSeries(Ts_id)),'_instance_',num2str(instanceID),'_',num2str(percent(percentID)),'.csv'];
            inputfile = csvread(pathtoread);
            
            Motif2Torename = inputfile(:,5)==2;
            Motif1Torename = inputfile(:,5)==1;
            outputfile=inputfile;
            outputfile(:,5) = Motif2Torename + (Motif1Torename*2);
            csvwrite([pathSource ,destFolder,'AP_DepO_2_DepT_2_Motif',num2str(num_Motif),'_',...
                num2str(Name_OriginalSeries(Ts_id)),'_instance_',num2str(instanceID),'_',num2str(percent(percentID)),'.csv'],outputfile);
        end
    end
end