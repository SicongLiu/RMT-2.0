%%
% Chin-Chia Michael Yeh
%
% C.-C. M. Yeh, N. Kavantzas, and E. Keogh, "Matrix Profile VI: Meaningful
% Multidimensional Motif Discovery," IEEE ICDM 2017.
% https://sites.google.com/view/mstamp/
% http://www.cs.ucr.edu/~eamonn/MatrixProfile.html
%
close all;
clear
clc

saveMotifImages=0;
% load('toy_data.mat');

%% compute the multidimensional matrix profile
% here we provided three variation of the mSTAMP algorithm
% The script will only run when only one of the alternatives is uncomment

%% alternative 1.a: the basic version
%
datasetPath= 'D:\Motif_Results\Datasets\SynteticDataset\Energy\';
%'D:\Motif_Results\Datasets\SynteticDataset\Energy\';%Mocap\';%Building_MultiStory\';%BSONG\';
%'D:\Motif_Results\Datasets\BirdSong\';
%'D:\Motif_Results\Datasets\Mocap\';%'D:\Motif_Results\Datasets\SynteticDataset\';%
ImageSavingPath='D:\Motif_Results\Datasets\SynteticDataset\Energy\MStamp\';
%'D:\Motif_Results\Datasets\SynteticDataset\Energy\MStamp\';%Mocap\MStamp\';%Building_MultiStory\MStampB\';%BSONG\MStampB\';
%'D:\Motif_Results\Datasets\BirdSong\MStampB\';
%'D:\Motif_Results\Datasets\Mocap\MStampB\';%'D:\Motif_Results\Datasets\SynteticDataset\MStamp\';%
load([datasetPath,'data\FeaturesToInject\allTSid.mat']);
Name_OriginalSeries = AllTS;%[1,3,6,7];%ENERGY %[23,35,86,111];% MOCap Motif10[64,70,80,147];BirdSong %[35,85,127,24];%Mocap
%for pip=2:4
% RW =csvread('D:\Motif_Results\Datasets\SynteticDataset\data\RW_0_1\RW_1.csv');
% for NAME =23:154 %100:105%71:72%39:39%%46:57%34:45%34:39
percent=[0; 0.1;0.25;0.5;0.75;1];% 0.1;0.5;0.75;1];
% for percentid=1:size(percent,1)
for prcentid=1:size(percent,2)
    percentagerandomwalk=percent(prcentid);
    for numMotifInjected =1:3%10:10%3
        for pip=1:30
            for NAME = 1:10
                MotifBag_mstamp=[];
                %      try
                FeaturesRM='MStamp';
                sublenght= 58;%76;%77;%ENERGY 32;%Bsong %58;%MOCAP 29;%   %[29,58];77;%12;%
                
                %           TEST=[NAME]
                TEST=['Motif',num2str(numMotifInjected),'_',num2str(Name_OriginalSeries(pip)),'_instance_',num2str(NAME),'_',num2str(percentagerandomwalk)]
                
                TS_name=num2str(TEST);
                data=csvread([datasetPath,'data\',TS_name,'.csv'])';%csvread('D:\Motif_Results\Datasets\SynteticDataset\data\Mocap_test1.csv');
                data(isnan(data))=0;
                data(1,:)=0;
                data(end,:)=1;
                % data1= csvread('D:\Motif_Results\Datasets\SynteticDataset\data\RandomWalks\RandomWalk_1.csv')';
                %        data(:,[34,46]) = RW([34,46],1:size(data,1))';
                %                data(end,[34,46]) =1;
                %       data(1,[34,46]) = 1;%data1(:,[34,46]);
                %      data(end,[34,46]) = 1;
                %     data = (data - mean(data)) ...
                %                                 / std(data, 1);
                %     data=data';
                
                Time=[];
                pro_mul=[];
                pro_idx=[];
                motif_idx=[];
                motif_dim=[];
                MotifBag=[];
                %     for j= 1:2
                
                %         sub_len=sublenght(j);
                sub_len=sublenght;
                must_dim = [];
                exc_dim =[];%[34,46]; %[];%[];%% for mocap we have o exclude flat timeseries
                % if big portion of the timeseries is flat we have perhaps to exclude that variates
                
                if(exist([ImageSavingPath,TS_name,'\Lenght_',num2str(sub_len),'\'],'dir')==0)
                    mkdir([ImageSavingPath,TS_name,'\Lenght_',num2str(sub_len),'\']);
                end
                datasave= [ImageSavingPath,TS_name,'\'];
                tic;
                [pro_mul, pro_idx] = ...
                    mstamp(data, sub_len, must_dim, exc_dim);
                TIME(1)= toc;
                %             pro_mul = pro_mul(:, 1:end-length(exc_dim));
                %             pro_idx = pro_idx(:, 1:end-length(exc_dim));
                save([datasave,'mstampStep1_',TS_name,'.mat'],'pro_mul','pro_idx','sub_len','data','TIME');
                
                %% alternative 1.b: the inclusion
                % in the toy data, the first dimension only consist of random walk.
                % Forcing the algorithm to consider the first dimension worsen the result.
                
                % must_dim = [1];
                % exc_dim = [];
                % [pro_mul, pro_idx] = ...
                %     mstamp(data, sub_len, must_dim, exc_dim);
                
                %% alternative 1.c: the exclusion
                % We can also do exclusion. By blacklist one of the dimension that contains
                % meaningful motif, we no longer can find a meaningful 2-dimensional motif.
                % However, the MDL-based unconstrained search method will correctly provide
                % us the 1-dimensional motif
                
                % must_dim = [];
                % exc_dim = [3];
                % [pro_mul, pro_idx] = ...
                %     mstamp(data, sub_len, must_dim, exc_dim);
                % pro_mul = pro_mul(:, 1:2);
                % pro_idx = pro_idx(:, 1:2);
                % data = data(:, 1:2);
                
                %% alternative 2: using Parallel Computing Toolbox
                
                % n_work = 4;
                % [pro_mul, pro_idx] = ...
                %     mstamp_par(data, sub_len, n_work);
                
                %% alternative 3: using the anytime version stop at 10%
                % the guided search is able to find the motif mostly
                % however, the MDL-based method's output is less stable due to both method
                % are approximated method
                
                % pct_stop = 0.1;
                % [pro_mul, pro_idx] = mstamp_any(data, sub_len, pct_stop);
                
                
                %% guided search for 2-dimensional motif
                % n_dim = 2; % we want the top 2-dimensional motif
                % [motif_idx, motif_dim] = guide_serach(...
                %     data, sub_len, pro_mul, pro_idx, n_dim);
                % plot_motif_on_data(data, sub_len, motif_idx, motif_dim);
                
                
                %% extract motif using the MDL-based unconstrained search method
                n_bit = 4; % number of bit for discretization
                k = inf;%2; % number of motif to retrieve
                
                tic
                [motif_idx, motif_dim] = unconstrain_search(...
                    data, sub_len, pro_mul, pro_idx, n_bit, k);%,2);
                %         plot_motif_on_data(data, sub_len, motif_idx, motif_dim);
                TIME(2)=toc;
                save([datasave,'mstampStep2_',TS_name,'.mat'],'motif_idx', 'motif_dim','TIME');
                %% bag of motifs using MDL unconstrained search
                tic;
                %      try
                [allStartingMotifs,allMotifDepd] = unifyAllInstances (motif_idx,motif_dim,pro_idx);
                MotifBag_mstamp = adaptiveKmedoids(data,allStartingMotifs,allMotifDepd,sub_len,n_bit,0.02);%0.003);%data,motif_idx,motif_dim,sub_len,n_bit, k,pro_idx);
                %         MotifBag_mstamp = search_Instances(data,motif_idx,motif_dim,sub_len,n_bit, k,pro_idx);
                TIME(3)=toc;
                MotifBag=MotifBag_mstamp;
                %        catch
                %        end
                
                %      try
                if(saveMotifImages==1)
                    for i=1:size(MotifBag,2)
                        figure1 = plot_RMTmotif_on_data(data', MotifBag{i}.startIdx, MotifBag{i}.depd,MotifBag{i}.Tscope);
                        %plot_motif_on_data(data, sub_len, MotifBag{i}.idx, MotifBag{i}.depd);
                        
                        filename=[ImageSavingPath,TS_name,'\Lenght_',num2str(sub_len),'\TS_',TS_name,'BoM_',num2str(i),'.eps'];
                        saveas(figure1,filename,'epsc');
                    end
                    close all;
                    
                end
                %        catch
                %            ['problem: ', TS_name]
                %        end
                %         for i=1:size(MotifBag,2)
                %             % apply matrix profile for the motif found
                %             [pro_mul, pro_idx] = ...
                %             mstamp(data, sub_len, must_dim, exc_dim);
                %             % scan in all the matrtix profile for the motif to find all the minimum till the end of the  timeseries
                %         end
                
                save ([datasave,'Motif_output_',TS_name,'Lenght_',num2str(sub_len),'.mat'],'pro_mul','pro_idx','motif_dim','motif_idx','MotifBag_mstamp');
                
                %col_header={'MSTAMP_32'};
                %rowHeader ={'MSTAMP';'FindMotifInstance';'AKmedoids'};
                csvwrite([datasave,'Time_',TS_name,'BoM_',num2str(i),'Lenght_',num2str(sub_len),'.csv'],TIME');
                %xlswrite([datasave,'Time_',TS_name,'BoM_',num2str(i),'Lenght_',num2str(sub_len),'.xls'],TIME','TIME','B2');
%                 xlswrite([datasave,'Time_',TS_name,'BoM_',num2str(i),'Lenght_',num2str(sub_len),'.xls'],rowHeader,'TIME','A2');
%                 xlswrite([datasave,'Time_',TS_name,'BoM_',num2str(i),'Lenght_',num2str(sub_len),'.xls'],col_header,'TIME','B1');
                clc;
                %      catch
                %      end
            end
        end
    end
end
