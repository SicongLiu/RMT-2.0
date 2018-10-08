function distance = MstampDfunction(DataMatrix,mDepd,n_bit,centroidsIDX)

% third dimension: # of motif instances
distance = zeros(size(DataMatrix,3),size(centroidsIDX,3));
%%
% get the centroids centroids = DataMatrixO(:,:,centroidsIDX);
% the second iteration should be performed on the centroids
for i=1: size(DataMatrix,3)
    M1= DataMatrix(:,:,i);
    M1_D = mDepd{i};
    for j=1:size(centroidsIDX,3)
        M2 = centroidsIDX(:,:,j);
        [best_bit, dim] = get_bit_save(M1, M2, size(M1_D,2), n_bit);
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
bit_sz=sum(motif_diff(:))/(size(motif_diff,1)*size(motif_diff,2));
% n_val = length(unique(motif_diff));
%
% bit_sz = n_bit * (tot_dim * sub_len * 2 - n_dim * sub_len);
% bit_sz = bit_sz + n_dim * sub_len * log2(n_val) + n_val * n_bit;
