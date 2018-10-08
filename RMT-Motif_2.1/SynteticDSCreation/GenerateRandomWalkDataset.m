clc;
clear;
RW_varaiteSize =13;%'BSONG' %27;%Energy %62; %ASL %62;%Mocap
RW_timelength  = 2500;
NormInterval=[zeros(RW_varaiteSize,1),ones(RW_varaiteSize,1)];
Dset='BirdSong';%'Energy';%'Mocap';%Bird Song %'ASL';%'data';%for Mocap
DestDataPath = ['D:\Motif_Results\Datasets\SynteticDataset\',Dset,'\RW_0_1\'];

numInstances= 10;
znorm=0; % 0 not znormalization; 1 do a znormalization
if(exist(DestDataPath,'dir')==0)
    mkdir(DestDataPath);
end
for idRW = 1:numInstances
    RW= random_walk_Mueen(RW_timelength,RW_varaiteSize);
    RW=NormalizeRandomWalk(RW,NormInterval,znorm);
    
    csvwrite([DestDataPath,'RW_',num2str(idRW),'.csv'],RW);
end

