function [Cluster Codebook] = cvKmeans(X, K, stopIter, distFunction, verbose,TS,gss1,idm1,KmeansDescmetric)
    % cvKmeans - K-means clustering
    %
    % Synopsis
    %   [Cluster Codebook] = cvKmeans(X, K, [stopIter], [distFunc], [verbose])
    %
    % Description
    %   K-means clustering
    %
    % Inputs ([]s are optional)
    %   (matrix) X        D x N matrix representing feature vectors by columns
    %                     where D is the number of dimensions and N is the
    %                     number of vectors.
    %   (scalar) K        The number of clusters.
    %   (scalar) [stopIter = .05]
    %                     A scalar between [0, 1]. Stop iterations if the
    %                     improved rate is less than this threshold value.
    %   (func)   [distFunc = @cvEucdist]
    %                     A function handle for distance measure. The function
    %                     must have two arguments for matrix X and Y. See
    %                     cvEucdist.m (Euclidean distance) as a reference.
    %   (bool)   [verbose = false]
    %                     Show progress or not.
    %
    % Outputs ([]s are optional)
    %   (vector) Cluster  1 x N vector cntaining intergers indicating the
    %                     cluster indicies. Cluster(n) is the cluster id for
    %                     X(:,n).
    %   (matrix) Codebook D x K matrix representing cluster centroids (means)
    %                     or VQ codewords (codebook)
    %
    % Examples
    %   See also demo/cvKmeansDemo.m, cvKmeansDemoVQ.m, cvKmeansDemoClassifi.m
    %
    %   X = rand(2, 10); % 2-dimensional vectors
    %   [Cluster, Mu] = cvKmeans(X, 2);
    %   % Use kmeans.m in practice that equivalent codes are as
    %   [Cluster, Mu] = kmeans(X.', 2);
    %   Cluster = Cluster.'; Mu = Mu.';
    %   XCluster(:,:,1) = X(:, Cluster == 1);
    %
    % See also
    %   cvAutolabel, cvEucdist, kmeans (Statistics Toolbox)

    % Authors
    %   Naotoshi Seo <sonots(at)sonots.com>
    %
    % License
    %   The program is free to use for non-commercial academic purposes,
    %   but for course works, you must understand what is going inside to use.
    %   The program can be used, modified, or re-distributed for any purposes
    %   if you or one of your group understand codes (the one must come to
    %   court if court cases occur.) Please contact the authors if you are
    %   interested in using the program without meeting the above conditions.
    %
    % Changes
    %   04/01/2006  First Edition
    if ~exist('stopIter', 'var') || isempty(stopIter)
        stopIter = .05;
    end
    if ~exist('distFunc', 'var') || isempty(distFunc)
        %'not distance input'
        distFunc = @Distance_RMT_DESC;% @cvEucdist;
        %distFunc = @Distance_RMT_DESC_AMPL;
    end
    if ~exist('verbose', 'var') || isempty(verbose)
        verbose = false;
    end
    [D N] = size(X);
    if K > N,
        error('K must be less than or equal to the number of vectors N');
    end

    if isempty(KmeansDescmetric)
        'euclidean distance in kmeans'
        KmeansDescmetric='euclidean';
    end
    % Initial centroids
    % initialindex=sort(randsample(N, K));
    % Codebook = X(:, initialindex);%randsample(N, K));

    %% plus Select the first seed by sampling uniformly at random
    % Select the first seed by sampling uniformly at random
    % S = RandStream.getGlobalStream; % uses the random number stream S for random number generation
    % index = zeros(K,1);
    % [C(1,:), index(1)] = datasample(S,X',1);
    if (size(X,2)==1)
      initialindex=1;
      Codebook= X(:,initialindex);
    else
            P=X';
           % if isempty(S)
                S = RandStream.getGlobalStream;
           % end
                    index = zeros(K,1);
                   [C(1,:), index(1)] = datasample(S,P,1);

                    % Select the rest of the seeds by a probabilistic model
                    for ii = 2:K                   
                        %distanza=(distFunc(C(1:ii-1,:)',P','cosine'))';%'euclidean'))';%,
                        distanza=(distFunc(C(1:ii-1,:)',P',KmeansDescmetric,TS,gss1,idm1))';

                        sampleProbability = min(distanza,[],2);%distance));%,[],2);
                        %sampleProbability = max(distanza,[],2);%distance));%,[],2);
                        denominator = sum(sampleProbability);
                        if denominator==0 || isinf(denominator) || isnan(denominator)
                            C(ii:K,:) = datasample(S,P,K-ii+1,1,'Replace',false);
                            break;
                        end
                        sampleProbability = sampleProbability/denominator;

                        [C(ii,:), index(ii)] = datasample(S,P,1,1,'Replace',false,...
                            'Weights',sampleProbability);
                    end


      initialindex=index;
    end
    
    Codebook= X(:,initialindex);
    improvedRatio = Inf;
    distortion = Inf;
    iter = 0;
    numiteration =100;

    while true
        % Calculate euclidean distances between each sample and each centroid
        %d = distFunc(Codebook, X,'cosine');%'euclidean');%(Codebook, X); %distance(X(7:size(X,1),:),Codebook(7:size(X,1),:));%
        d=(distFunc(Codebook,X,KmeansDescmetric,TS,gss1,idm1));
   % iter
        % Assign each sample to the nearest codeword (centroid)
        [dataNearClusterDist, Cluster] = min(d, [], 1);
        %[dataNearClusterDist, Cluster] = max(d, [], 1);
        % distortion. If centroids are unchanged, distortion is also unchanged.
        % smaller distortion is better
        old_distortion = distortion;
        distortion = mean(dataNearClusterDist);

        % If no more improved, break;
        improvedRatio = 1 - (distortion / old_distortion);
        %improvedRatio = 1 - ( old_distortion/distortion); %Wrong
        if verbose
            fprintf('%d: improved ratio = %f\n', iter, improvedRatio);
        end
        iter = iter + 1;

        if improvedRatio <= stopIter, break, end;
        if numiteration == iter, break, end;

        % Renew Codebook
        for i=1:K
            % Get the id of samples which were clusterd into cluster i.
            idx = find(Cluster == i);
            % Calculate centroid of each cluter, and replace Codebook
            averageDesc= mean(X(11:size(X,1), idx),2);
            % vector to the minimum mean ditance.
            actdesc = X(11:size(X,1), idx);
            avdes = (ones(size(idx,2),1)*averageDesc')';
       %     [distmedianchk,minimochk]= min(sum(abs(actdesc-avdes)));%averageDesc)));
            %% perhaps we should use the same distance  than before :
            distlocdesc=pdist2(actdesc',averageDesc', KmeansDescmetric);
            %simDistDescr= 1./(distlocdesc+1);
            %[distmedian,minimo]= max(simDistDescr(:,1));%abs(actdesc-avdes)));%averageDesc)));
            [distmedian,minimo]= min(distlocdesc(:,1));%abs(actdesc-avdes)));%averageDesc)));
            assignment=X(:,idx(minimo));
            if (isempty(idx))
                if verbose
                    fprintf('%d: ERROR IDX EMPTY: %f\n', iter, i);
                end
            elseif (idx(minimo)==0 )
                if verbose
                    fprintf('%d: ERROR IDX == 0 : %f\n', iter, i);
                end
            else

    %         idx(minimo);
            Codebook(:, i) = assignment;%X(:,idx(minimo));
            end
        end
    end
end