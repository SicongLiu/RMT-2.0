% cvKmeansDemo - Demo of cvKmeans.m
function cvKmeansDemo
imagepath= 'D:\MOTIF Discovery\Dataset\Image Texture\original images\';
specificimagepath= 'blockchess\';%'imcreated2\';
imagename='dataChess_reord';
prox_image='proximity_red_reord.csv';
rel_image='rel_red_reord.csv';

saveFeaturesPath=[imagepath,specificimagepath,'Features\'];
     
    savepath1 = [saveFeaturesPath,'feature_',imagename,'.mat'];
    savepath2 = [saveFeaturesPath,'idm_',imagename,'.mat'];
    savepath3 = [saveFeaturesPath,'MetaData_',imagename,'.mat'];   
     load(savepath1);
     load(savepath2);
     load(savepath3);
     
     % Split the features into groups on the baseof the  sigma-time and
     % sigma-dependency
       sigmadep1 = frame1(4,1);
       sigmatime = frame1(5,1);
       structureFinal=[];
       sameSigmaStruct=[];
       
       sigmaforeachblock=[sigmadep1;sigmatime];
       startpos=1;
       endpos=[];
       for i= 1: size(frame1,2)
            actFrame= frame1(:,i);
           if(sigmadep1==actFrame(4,1) && sigmatime==actFrame(5,1))
               sameSigmaStruct=[sameSigmaStruct,actFrame];
               if (i == size(frame1,2))
                   endpos=i;
                   %sigmaforeachblock =[sigmaforeachblock,[sigmadep1;sigmatime]];
                   structureFinal=[structureFinal,[startpos;endpos]];%struct(strcat('groupsFeatures',num2str(k)),sameSigmaStruct)];
                   startpos=i;
               end
           else
               endpos=i-1;
               sigmadep1 = actFrame(4,1);
               sigmatime = actFrame(5,1);
               sigmaforeachblock =[sigmaforeachblock,[sigmadep1;sigmatime]];
               structureFinal=[structureFinal,[startpos;endpos]];%struct(strcat('groupsFeatures',num2str(k)),sameSigmaStruct)];
               startpos=i;
               sameSigmaStruct=actFrame;
           end
       end
    numgroups=size(structureFinal,2);
     for p=1:numgroups       
          indexfeatureGroup =  structureFinal(:,p);
          X=frame1(:,indexfeatureGroup(1):indexfeatureGroup(2));
          
     
% X =[ 3     2     2     2     1    -3    -2    -2    -2    -1
%     2     3     2     1     2    -2    -3    -2    -1    -2 ];
[C, mu] = cvKmeans(X, 30);%@Distance_RMT_DESC);
% C
% mu

% plot data
clusterLabel = unique(C);
nCluster     = length(clusterLabel);
plotLabel = {'r+', 'b+'};
for i=1:nCluster
    A = X(:, C == clusterLabel(i));
    plot( A(2, :),A(1, :), plotLabel{2});
    hold on;
end

% plot centroids
plotLabel = {'ro', 'bo'};
for i=1:nCluster
    plot( mu(2, i),mu(1, i), plotLabel{1});
    hold on;
end
legend('cluster 1: data','cluster 2: data', 'cluster 1: centroid', ...
    'cluster 2: centroid', 'Location', 'SouthEast');
title('K means clustering');
end