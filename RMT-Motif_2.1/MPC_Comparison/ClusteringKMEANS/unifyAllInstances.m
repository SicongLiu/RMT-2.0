function [allmotif,allmotifdepd] = unifyAllInstances (motif_idx,motif_dim,pro_idx)
count=1;
allmotif=[];
allmotifdepd=[];
for i = 1: size(motif_idx,1)
    allmotif=[allmotif;motif_idx(i)];
    allmotifdepd{count}=motif_dim{i};
    count=count+1;
    mappedid=pro_idx(motif_idx(i),size(motif_dim{i},2));
    if(size(intersect(mappedid,motif_idx),1)==1)
            if(size(motif_idx,1)==1)
            allmotif=[allmotif;mappedid];
            allmotifdepd{count}=motif_dim{i};
            count=count+1;
            end
    else
        allmotif=[allmotif;mappedid];
        allmotifdepd{count}=motif_dim{i};
        count=count+1;
    end
    
end
    [~ ,IDX]= sort(allmotif);
    allmotif=allmotif(IDX);
    allmotifdepd1{1}= allmotifdepd{IDX(1)};
    allmotif1(1)=allmotif(1);
    index=2;
    for i=2: size(IDX,1)
        if(allmotif(i)==allmotif(i-1))
            temp1=sort(allmotifdepd{IDX(i)});
            temp1=padarray(temp1', 62-length(temp1),0,'post')';
            temp2=sort(allmotifdepd{IDX(i-1)});
            temp2=padarray(temp2', 62-length(temp2),0,'post')';
            if(sum(abs(temp1-temp2))~=0)
                allmotifdepd1{index}= allmotifdepd{IDX(i)};
                allmotif1(index)=allmotif(i);
                index+1;
            else
%                 allmotif(i)=-1;
            end
        else
            allmotifdepd1{index}= allmotifdepd{IDX(i)};
            allmotif1(index)=allmotif(i);
           index=index+1;
        end
    end
    allmotif=allmotif1';
    allmotifdepd=allmotifdepd1;
end