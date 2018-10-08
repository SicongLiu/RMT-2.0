function [Cluster,Centroid,SUMD, d] = KmedoidsRMT(Features,startK,  verbose)


stopIter = .05;

Centroid=[];
SUMD=[];
d=[];
if ~exist('verbose', 'var') || isempty(verbose)
    verbose = false;
end

[M count] = size(Features);
if startK > count,
    error('K must be less than or equal to the number of vectors N');
end

Dist = pdist2(Features(11:end,:)',Features(11:end,:)');% MstampDfunction1(DiscreteDataMatrix,mDepd,n_bit,1:size(DiscreteDataMatrix,3));

% Dist = MstampDfunction(DiscreteDataMatrix,mDepd,n_bit,DiscreteDataMatrix);

MaximumValue = nanmax(Dist(:));%max(Dist(:));
MinimumDistance = min(Dist(:));
% 0-1 normalization of the space
Dist(isnan(Dist))=inf;
Dist= Dist/MaximumValue;%-MinimumDistance)/(MaximumValue-MinimumDistance);

improvedRatio = Inf;
distortion = Inf;
iter = 0;
numiteration =100;
idxcentroid = randperm(size(Features,2),1);%startK);% randi([1 size(DataMatrix,3)],1,startK)


% only one motif found
if (size(Features,2) == 1)    
    initialindex = 1;
    Codebook = Features(:,initialindex);%DiscreteDataMatrix(:,:,initialindex);
else

    P=Features(11:end,:);

    S = RandStream.getGlobalStream;
    idxcentroid = zeros(1,startK);

    [Discrete_Centroids(:,1), idxcentroid(1)] = datasample(S,P,1,2);
%     Discrete_Centroids(:,:,1) = Centroids(1,:,:);
    % Select the rest of the seeds by a probabilistic model
    for ii = 2 : startK
        % return the distance between all the features and all the centroids
%% Candan Distance        
        distances_to_centroids = pdist2(Features(11:end,:)',Discrete_Centroids(:,ii-1)');%MstampDfunction1(DiscreteDataMatrix, mDepd, n_bit, idxcentroid(1:ii-1));
        distances_to_centroids= distances_to_centroids/MaximumValue;%
        distances_to_centroids(isnan(distances_to_centroids))=1; % impose the infinite distance to be 1 as 1 is the maximum distance
%%  Silv distance       
%         distances_to_centroids = MstampDfunction(DiscreteDataMatrix, mDepd, n_bit, Discrete_Centroids);

               % row-wise min
        sampleProbability = min(distances_to_centroids, [], 2);%distance));%,[],2);

        
        denominator = sum(sampleProbability);

        % if datasamples & distance computations process failed, redo everything simply using datasamples function
        if denominator == 0 || isinf(denominator) || isnan(denominator)
            
            % no duplicate return values from 'datasample'
            [Discrete_Centroids(:, ii : startK),idxcentroid(ii : startK)] = datasample(S, P, startK - ii + 1, 2, 'Replace', false);

            break;
        end
        

        [Discrete_Centroids(:,ii), idxcentroid(ii)] = datasample(S,P,1,2,'Replace',false,...
            'Weights',sampleProbability);

    end
    initialindex = idxcentroid;
end

while true
    % Assign each sample to the nearest codeword (centroid)
%% Silv measure    
%     d=MstampDfunction(DiscreteDataMatrix,mDepd,n_bit,Discrete_Centroids);
%% Candan measure
    d=pdist2(Features(11:end,:)',Features(11:end,idxcentroid)');%MstampDfunction1(DiscreteDataMatrix,mDepd,n_bit,idxcentroid);
    
    % 0-1 normalization of the  distances
    d= d/MaximumValue;%(d - MinimumDistance) /(MaximumValue-MinimumDistance);
    d(isnan(d))=1;% changed to 1 thus 1 is the maximum distance in the space
    
    [dataNearClusterDist, Cluster] = min(d', [], 1);
    
    old_distortion = distortion;
    distortion = mean(dataNearClusterDist);
    
    % If no more improved, break;
    improvedRatio = 1 - (distortion / old_distortion);
    
    if verbose
        fprintf('%d: improved ratio = %f\n', iter, improvedRatio);
    end
    iter = iter + 1;
    
    if improvedRatio <= stopIter, break, end;
    if numiteration == iter, break, end;
    
    % Renew Codebook
    for i=1:startK
        idx = find(Cluster == i);
        SUMD(i) = sum(dataNearClusterDist(idx));
        RealIndex = idx;
        %             1:size(DataMatrix,3);%do not need
        %             RealIndex = RealIndex(idx); % do not need
        
        Local_Centroid =  mean(Features(11:end,idx)');
%         AllRealsequncesC = DataMatrix(:,:,idx);
%         AllQuantizedSeqC = DiscreteDataMatrix(:,:,idx);
%         AllCdepd = [];
%         averagealllTS = sum(AllRealsequncesC,3)/size(AllRealsequncesC,3);
%         split_pt = get_desc_split_pt(n_bit);
%         disctrretizeaveragealllTS = discretization(averagealllTS, split_pt);
%         for j=1: size(RealIndex,2)
%             AllCdepd{j} = mDepd{RealIndex(j)};
%         end

        localDistances = pdist2(Features(11:end,idx)',Local_Centroid);%MstampDfunction1(AllQuantizedSeqC,AllCdepd,n_bit,1:size(AllQuantizedSeqC,3));
         localDistances= localDistances/MaximumValue;%
         localDistances(isnan(localDistances))=1;% 
        [~,newCentroidID] = min(localDistances);
%% silv measure
%         localDistances = MstampDfunction(AllQuantizedSeqC,AllCdepd,n_bit,disctrretizeaveragealllTS)/MaximumValue;%;
%         [~,newCentroidID] = min(localDistances);

        idxcentroid(i)=idx(newCentroidID);
        Discrete_Centroids(:,i) = Features(11:end,idx(newCentroidID));%AllQuantizedSeqC(:,:,newCentroidID);
        Centroid(:,i) = Discrete_Centroids(:,i);%AllRealsequncesC(:,:,newCentroidID);
    end

    
end


end