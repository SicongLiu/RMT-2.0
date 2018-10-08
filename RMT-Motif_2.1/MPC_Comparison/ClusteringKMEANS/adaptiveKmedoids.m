function [MotifBag_mstamp] = adaptiveKmedoids(data,allMotif,allMotifDepd,sub_len,n_bit,saturation)

    startK = 3;
    if (size(allMotif,1)<=startK)
        i=1;
            MotifBag_mstamp{i}.startIdx = allMotif;
            for iterator=1:size(allMotifDepd,2)
                MotifBag_mstamp{i}.depd{iterator}=allMotifDepd{iterator};
                MotifBag_mstamp{i}.Tscope{iterator}= sub_len;%allMotif(MotifIDX(iterator))+
            end
        
    else
    Step =2;
    split_pt = get_desc_split_pt(n_bit);
    %% Discretize the timeseries sections
    DataMatrix = [];
    DiscreteDataMatrix=[];
    for i = 1: size(allMotif,1)
        motif_1= data(allMotif(i):allMotif(i) + sub_len - 1, :);
        DiscreteDataMatrix(:,:,i)= discretization(motif_1, split_pt);
        DataMatrix(:,:,i)=motif_1;
    end

    inertia=[];   
    tryK=[];
    itr=1;
   isFound=false;
   while(~isFound)
% if(startK >= size(allMotifDepd,2)/2)
%     startK=floor(size(allMotifDepd,2)/2)-1;
%     isFound=true;
% end

try
    [C,mu,meanKmeans, D]=KmedoidsMStamp(DiscreteDataMatrix,allMotifDepd,startK,false,n_bit,DataMatrix);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    startK=startK-Step;
    [C,mu,meanKmeans, D]=KmedoidsMStamp(DiscreteDataMatrix,allMotifDepd,startK,false,n_bit,DataMatrix);
    isFound=true;
end
% labels of Clusters
    labels= unique(C);
    D1 =zeros (size(D));

    NumofIntancesforClusters=zeros(1,startK);
    for i=1:length(labels)
        D1(C==i,i)=D(C==i,i);    % save just the instances of the distances from  each centroid
        NumofIntancesforClusters(1,i)=sum(C==i);
        
    end
    
      SUMD1 = sum(D1);
      MeanD1 = SUMD1./NumofIntancesforClusters;
      MeanD2 = sum(SUMD1)/sum(NumofIntancesforClusters);
      MeasureToUse=mean(MeanD2);
%% computeinertia
       if(itr==1)
         inertia=[inertia,MeasureToUse];
         tryK=[tryK,startK];
         startK=startK+Step;
        if startK>=size(allMotifDepd,2)
            isFound=true;
        end
       else
         inertia=[inertia,MeasureToUse];
         tryK=[tryK,startK];
         error = abs(inertia(itr) - inertia(itr-1));
%            error = abs(inertia(itr) - inertia(itr-1))/inertia(itr-1);
            if error<=saturation || startK >= (size(DataMatrix,3)-2) || inertia(itr)<=saturation
%             eva = evalclusters(features1(11:end,:)',evaluation,'CalinskiHarabasz');
                isFound=true;
                startK=startK-Step; 
            end
        startK=startK+Step;
        if startK>size(allMotifDepd,2)
            isFound=true;
        end
       end
       if(~isFound)
         itr=itr+1;
       end
    end
MotifBag_mstamp=[];

for i=1:startK
IDX = C==i;
MotifIDX = 1:size (allMotif,1);
MotifBag_mstamp{i}.startIdx = allMotif(IDX);
MotifIDX = MotifIDX(IDX);
    for iterator=1:size(MotifIDX,2)
        MotifBag_mstamp{i}.depd{iterator}=allMotifDepd{MotifIDX(iterator)};
        MotifBag_mstamp{i}.Tscope{iterator}= sub_len;%allMotif(MotifIDX(iterator))+
    end

end

 end
        
function disc = discretization(motif, split_pt)
    for i = 1:size(motif, 2)
        motif(:, i) = (motif(:, i) - mean(motif(:, i))) / ...
            std(motif(:, i), 1);
    end
    disc = zeros(size(motif));
    for i = 1:length(split_pt)
        disc(motif < split_pt(i) & disc == 0) = i;
    end
    disc(disc == 0) = length(split_pt) + 1;


function split_pt = get_desc_split_pt(n_bit)
    split_pt = norminv((1:(2^n_bit)-1)/(2^n_bit), 0, 1);