%%

% X: feature list  of centroids
% Y: features list
% kind:
%         'euclidean'   - Euclidean distance (default)
%         'seuclidean'  - Standardized Euclidean distance. Each coordinate
%                         difference between rows in X is scaled by dividing
%                         by the corresponding element of the standard
%                         deviation S=NANSTD(X). To specify another value for
%                         S, use D=pdist(X,'seuclidean',S).
%         'cityblock'   - City Block distance
%         'minkowski'   - Minkowski distance. The default exponent is 2. To
%                         specify a different exponent, use
%                         D = pdist(X,'minkowski',P), where the exponent P is
%                         a scalar positive value.
%         'chebychev'   - Chebychev distance (maximum coordinate difference)
%         'mahalanobis' - Mahalanobis distance, using the sample covariance
%                         of X as computed by NANCOV. To compute the distance
%                         with a different covariance, use
%                         D =  pdist(X,'mahalanobis',C), where the matrix C
%                         is symmetric and positive definite.
%         'cosine'      - One minus the cosine of the included angle
%                         between observations (treated as vectors)
%         'correlation' - One minus the sample linear correlation between
%                         observations (treated as sequences of values).
%         'spearman'    - One minus the sample Spearman's rank correlation
%                         between observations (treated as sequences of values).
%         'hamming'     - Hamming distance, percentage of coordinates
%                         that differ
%         'jaccard'     - One minus the Jaccard coefficient, the
%                         percentage of nonzero coordinates that differ
%         function      - A distance function specified using @, for
%                         example @DISTFUN.

function d= Distance_RMT_DESC_AMPL(X, Y, kind,TS,gss1,idm1)
    
    Xamp1 = amplitudediff(TS,Y,gss1,idm1);
    XAMPCentr=amplitudediff(TS,X,gss1,idm1);
    
    if ~exist('Y', 'var') || isempty(Y)
        U = ones(size(X, 1), 1);
        d = abs(X'.^2*U).'; 
        return;
    end
    distDescriptors= zeros(size(X,2),size(Y,2));
    centroid=X(11:size(Y,1),:);
    descriptor=Y(11:size(Y,1),:);
    Score1 = 1./(ones(size(X,2),size(Y,2))+pdist2(centroid',descriptor',kind));
    Score2= zeros(size(X,2),size(Y,2));
    %distDescriptors = pdist2(centroid',descriptor',kind);
    
    %distDescriptors= zeros(size(X,2),size(Y,2));
    for i=1 : size(X,2)
        for j=1:size(Y,2)
     %       centroid=X(7:size(Y,1),i);
     %       descriptor=Y(7:size(Y,1),j);
     %       Score1 = 1/(1+pdist([centroid';descriptor'],kind));
             normDiv=XAMPCentr(i)+Xamp1(j);
             if (normDiv==0)
                 normDiv=1;
             end
         
            NormDist=(XAMPCentr(i)-Xamp1(j))/(normDiv);
            Score2(i,j) =  1/(1+abs(NormDist));
            
        end
    end
    distDescriptors= ones(size(X,2),size(Y,2)) - (Score1.*Score2);%pdist([centroid';descriptor'],kind);
    d= distDescriptors;
end