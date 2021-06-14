function [ imgs ] = read( size )

imgs=[];
for i=1:5
    n_en=['data/',num2str(i),'.jpg'];
    imgs(:,:,i)=imresize(rgb2gray(imread(n_en)),[size,size]);
end


end

