function quantizedMatrix = singlevariateQuantization(Matrice)
quantizedMatrix = zeros(size(Matrice));

m=min(Matrice(:));
M=max(Matrice(:));
quantizedMatrix =round((Matrice - m) * (255 / (M-m)));
% for i= 1: size(Matrice,2)
%     quantizedMatrix(:,i)=round((Matrice(:,i) - m(i)) * (255 / (M(i)-m(i))));
% end
end