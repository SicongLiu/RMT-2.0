function distance = MstampDfunction1(DataMatrix,mDepd,n_bit,centroidsIDX)

% third dimension: # of motif instances
distance = zeros(size(DataMatrix,3),size(centroidsIDX,3));
%%
% get the centroids centroids = DataMatrixO(:,:,centroidsIDX);
% the second iteration should be performed on the centroids
for i=1: size(DataMatrix,3)
    
    M1_D = mDepd{i};
    M1= DataMatrix(:,:,i);
    for j=1:size(centroidsIDX,2)
        M2_D = mDepd{centroidsIDX(j)};
        M2 = DataMatrix(:,:,centroidsIDX(j));
        I1= intersect(M1_D(M1_D>0),M2_D(M2_D>0));
        U1=union(M1_D(M1_D>0),M2_D(M2_D>0));
        if(size(I1,2)>0)
            if(size(I1,2)/size(U1,2)==1)
                [best_bit, dim] = get_bit_save(M1, M2, size(M1_D,2), n_bit);
            else
                zeropadding = zeros(size(M1,1),1);
                % add zero in teh timeseries where the variate are not identical;
                M11 = M1(:,I1);
                M22 = M2(:,I1);
                %add zerio in M11 where there are variates not in the
                %intersection but in M2 and add that variate in M22
                diffvariateM2_M1= setdiff(M2_D,I1);
                zeropadding = zeros(size(M2,1),size(diffvariateM2_M1,2));
                M11 = [M11,zeropadding];
                M22 = [M22,M2(:,diffvariateM2_M1)];
                %add zerio in M22 where there are variates not in the
                %intersection but in M1 and add that variate in M11
                diffvariateM1_M2= setdiff(M1_D,I1);
                zeropadding = zeros(size(M1,1),size(diffvariateM1_M2,2));
                M11 = [M11,M1(:,diffvariateM1_M2)];
                M22 = [M22,zeropadding];
                
                [~, kvariate] =size(M11);
                 [best_bit, dim] = get_bit_save(M11, M22, kvariate, n_bit);
            end
        else
%             M11=[];
%             M22=[];
%             diffvariateM2_M1= setdiff(M2_D,I1);
%             zeropadding = zeros(size(M2,1),size(diffvariateM2_M1,2));
%             M11 = [M11,zeropadding];
%             M22 = [M22,M2(:,diffvariateM2_M1)];
%             diffvariateM1_M2= setdiff(M1_D,I1);
%             zeropadding = zeros(size(M1,1),size(diffvariateM1_M2,2));
%             M11 = [M11,M1(:,diffvariateM1_M2)];
%             M22 = [M22,zeropadding]; 
%             [~, kvariate] =size(M11);
%             [best_bit, dim] = get_bit_save(M11, M22, kvariate, n_bit);
            best_bit =NaN;
            dim = [];
        end
        distance(i,j) = best_bit;
    end
end
% MaximumValue = max(distance(:));
% distance = distance;%/MaximumValue;

function [bit_sz, dim_id] = get_bit_save(motif_1, motif_2, n_dim, n_bit)
tot_dim = size(motif_1, 2);
sub_len = size(motif_1, 1);
[~, dim_id] = sort(sum(abs(motif_1 - motif_2), 1), 'ascend');
dim_id = dim_id(1:n_dim);
motif_diff = abs(motif_1(:, dim_id) - motif_2(:, dim_id));%motif_1(:, dim_id) - motif_2(:, dim_id)
n_val = length(unique(motif_diff));
bit_sz = n_dim * sub_len*log2(n_val)+ (n_val-1) * n_bit;
% bit_sz=sum(motif_diff(:))/(size(motif_diff,1)*size(motif_diff,2));

% n_val = length(unique(motif_diff));
%
% bit_sz = n_bit * (tot_dim * sub_len * 2 - n_dim * sub_len);
% bit_sz = bit_sz + n_dim * sub_len * log2(n_val) + n_val * n_bit;
