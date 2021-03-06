function timeforcleaning =  EliminateOutboiudaryInstances(TEST, imagepath,specificimagepath,imagename,typeofCluster,K_valuesCalc,prunewith,distanceUsed ,FeaturesRM,cleanfeatures,NumWindows,saveMotifImages )

    saveFeaturesPath=[imagepath,specificimagepath,'Features_',FeaturesRM,'\',cleanfeatures,TEST,'\'];
    savepath1 = [saveFeaturesPath,'feature_',imagename,'.mat'];
    savepath2 = [saveFeaturesPath,'idm_',imagename,'.mat'];
    savepath3 = [saveFeaturesPath,'MetaData_',imagename,'.mat'];   
     ClusterPath = [saveFeaturesPath,'Distances',distanceUsed,'\Cluster_',K_valuesCalc,'\SplitVariate'];%'\',distanceUsed,'\',typeofCluster,
    ImageSavingPath=[ClusterPath,'\AP_VA'];%\imageMotifs\',imagename];
%     ImageSavingPath=[saveFeaturesPath,'DistancesDescriptors\Cluster_',K_valuesCalc,'\',distanceUsed,'\AP_Kmeans\'];%,prunewith,'\imageMotifs\'];
     PrunedClusterPath = [ClusterPath,'\AP_VA\',typeofCluster];
% PrunedClusterPath=[saveFeaturesPath,'DistancesDescriptors\Cluster_',K_valuesCalc,'\',distanceUsed,'\AP_Kmeans\',typeofCluster];
%     ClusterPath = [saveFeaturesPath,'DistancesDescriptors\Cluster_',K_valuesCalc,'\',distanceUsed,'\',typeofCluster];
    load(savepath1);
    load(savepath2);
    load(savepath3);
    timeforcleaning=[];
    FinalPath = strcat(PrunedClusterPath,prunewith);
    for k=1:DeOctTime
       for j=1:DeOctDepd
           
       % iterate on motif bags
       % for each motif bag read the timeseries section 
       % for each timeseries represent it as a PAA
       % compute the euclidean distance between the subsections
       
           load (strcat(PrunedClusterPath,'\Motif_',imagename,'_DepO_',num2str(j),'_DepT_',num2str(k),'.mat'));
           
           numMotif = size(MotifBag,2);
           MotifOK=[];
           Contator=1;
           dependency =[];
           prunedFeaturesCluster = [];
           prunedCluster = [];
           tic;
           for motifID =1 :numMotif
%                motifID
%                if motifID == 70
%                    '70'
%                end
               startIndex = MotifBag{motifID}.startIdx;
               TSSections=[];
               for iterator=1:size(MotifBag{motifID}.startIdx,1)
                  depd =  MotifBag{motifID}.depd{iterator};
                  timescope =  MotifBag{motifID}.Tscope{iterator};
                  TSSections(:,:,iterator) = representation(data,startIndex(iterator),depd,timescope,NumWindows);
               end
%                [D,bestvariate]= DistancesTS(TSSections,NumWindows,MotifBag{motifID}.depd);
%                counts = sum(D <=eps);
%                SurvivedMotifInstances = counts>2;
                D= DistancesTS_MP(TSSections,NumWindows,MotifBag{motifID}.depd);
               if sum(SurvivedMotifInstances)>0
                   IDX = 1:size(counts,2);
                   IDX = IDX(SurvivedMotifInstances);
                   MotifOK{Contator}.startIdx=startIndex(SurvivedMotifInstances);
                   MotifBag{Contator}.features = MotifBag{motifID}.features(:,SurvivedMotifInstances);
                   for  variateMotifs = 1:size(IDX,2)
                       MotifOK{Contator}.depd{variateMotifs}   =  MotifBag{motifID}.depd{IDX(variateMotifs)};%bestvariate{IDX(variateMotifs)};%
                       MotifOK{Contator}.Tscope{variateMotifs} = MotifBag{motifID}.Tscope{IDX(variateMotifs)};
                       
                   end
                   if(saveMotifImages==1)
                      if(exist([FinalPath,'\octaveT_',num2str(k),'_octaveD_',num2str(j)],'dir')==0)
                        mkdir([FinalPath,'\octaveT_',num2str(k),'_octaveD_',num2str(j),'\']);
                      end 
                      figure1 = plot_RMTmotif_on_data(data, MotifOK{Contator}.startIdx, MotifOK{Contator}.depd,MotifOK{Contator}.Tscope);
                      filename=[FinalPath,'\octaveT_',num2str(k),'_octaveD_',num2str(j),'\TS_',imagename,'_octT_',num2str(k),'_octD_',num2str(j),'_M_',num2str(Contator),'.eps'];%'.jpg'];
                      saveas(figure1,filename,'epsc');
                   end
                   
                   prunedFeaturesCluster=[prunedFeaturesCluster,MotifBag{Contator}.features];
            %      prunedDepScale = [prunedDepScale,B1];
                   prunedsymbols = ones(1,size(MotifBag{Contator}.features,2))*Contator;
                   prunedCluster=[prunedCluster,prunedsymbols];
                   
                   Contator=Contator+1;
               end


           end
           timeforcleaning = [timeforcleaning,toc];
           MotifBag= MotifOK;
           save(strcat(FinalPath,'\Motif_',imagename,'_DepO_',num2str(j),'_DepT_',num2str(k),'.mat'),'MotifBag');
           
           close all;
           
       end

    end

end