function [Centroid,Clusterfeatures,ClusterSymbols,ClusterDep] = clusteronInportance(features,D,dpscale,Thresh,numCluster)
     

           Centroid=[];
           Clusterfeatures=[];
           A= D<Thresh;
           ClusterSymbols=[];
           k=1;
           numC=0;
           ClusterDep=[];
           while size(A,2)>0 & numC < numCluster
               importance = sum(A,2);
               [val,idx]=max(importance);
               Centroid = [Centroid,features(:,idx)];
               Clusterfeatures = [Clusterfeatures,features(:,A(:,idx))];
               ClusterDep = [ClusterDep,dpscale(:,A(:,idx))];
               Symbols =ones(1,size(features(:,A(:,idx)),2))*k;
               ClusterSymbols=[ClusterSymbols,Symbols];
               features(:,A(idx,:))=[];
               A1=A;
               A1(:,A(idx,:))=[];
               A1(A(idx,:),:)=[];             
               A=A1;
               k=k+1;
               numC=numC+1;
           end
           
end