function MotifBag = search_Instances(data,motif_idx,motif_dim,sub_len,n_bit, k,pro_idx)
MotifInstances=[];
allmotif=[];
allmotifdepd=[];
count=1;
for i = 1: size(motif_idx,1)
    allmotif=[allmotif;motif_idx(i)];
    allmotifdepd{count}=motif_dim{i};
    count=count+1;
    mappedid=pro_idx(motif_idx(i),size(motif_dim{i},2));
    if(size(intersect(mappedid,motif_idx),1)==1)
    else
        allmotif=[allmotif;mappedid];
        allmotifdepd{count}=motif_dim{i};
        count=count+1;
    end
end
MotifBag=[];
[nmotif]=size(allmotif,1);
tot_dim = size(data, 2);
base_bit = n_bit * tot_dim * sub_len * 2;

count=1;
labels=zeros(1,size(allmotif,1));
for i= 1:size(allmotif,1)%while(size(allmotifIdxquery,1)~=0)%
    queryMotif_depd=allmotifdepd{i};
    queryMotif_idx =allmotif(i);
    MotifBagidx=[];
    for j= 1:nmotif
        scorevariate= size(intersect(queryMotif_depd,allmotifdepd{j}),2)/size(union(queryMotif_depd,allmotifdepd{j}),2);
        if(scorevariate==1)
            %check if the motifs can be aggregated in the same motif bag
            idx_2=allmotif(j);
             
            motif_1 = data(queryMotif_idx:queryMotif_idx + sub_len - 1, :);
            motif_2 = data(idx_2:idx_2 + sub_len - 1, :);
            [best_bit, dim] = get_bit_save(motif_1, motif_2, size(queryMotif_depd,2), n_bit);
            if best_bit <= base_bit
                %% add this motif in the same motif bag
                if(labels(j)==0)
                    labels(j)=count;
                end

            else
               %% do not add 
            end    
        end
%         if (j>=nmotif)

%         end
    end
    count=count+1;
%     MotifBag{count}.idx=MotifBagidx;
%     MotifBag{count}.depd=queryMotif_depd;
%     count=count+1;
end

C= unique(labels);

for i=1:size(C,2)
    MotifBag{i}.idx=allmotif(labels==C(i));
    for j=1:size(MotifBag{i}.idx,1)
        MotifBag{i}.depd{j}=allmotifdepd{C(i)};
    end
end

function [bit_sz, dim_id] = get_bit_save(motif_1, motif_2, n_dim, n_bit)
tot_dim = size(motif_1, 2);
sub_len = size(motif_1, 1);
split_pt = get_desc_split_pt(n_bit);
disc_1 = discretization(motif_1, split_pt);
disc_2 = discretization(motif_2, split_pt);

[~, dim_id] = sort(sum(abs(disc_1 - disc_2), 1), 'ascend');
dim_id = dim_id(1:n_dim);
motif_diff = disc_1(:, dim_id) - disc_2(:, dim_id);
n_val = length(unique(motif_diff));

bit_sz = n_bit * (tot_dim * sub_len * 2 - n_dim * sub_len);
bit_sz = bit_sz + n_dim * sub_len * log2(n_val) + n_val * n_bit;


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