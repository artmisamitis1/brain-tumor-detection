clc;
clear;
close all;

img_no=1;     % number of image in dataset to run
img_size=100; % size of image read (based on images 170 is maximum)
FCM_Csize=10; % size of CFM cluster(6-10 is good)
GA_Psize=20;  % GA population size(15-25 is good)
GA_Miter=3;   % GA max epoch(3-20 is good)
GA_mu=0.2;    % GA mutation factor
Morph_SD=5;   % denoise factor


FCM_o=FCM;
GA_o=GA;

c=[];
mu=[];
p=[];

disp('reading images.');
[ imgs ]=read( img_size );

[ c ]=FCM_o.init(imgs(:,:,img_no),FCM_Csize);
mu=[];
disp('generating clusters.');
for i=1:GA_Psize
    
    for t=1:1
        [ c,mu ]=FCM_o.update(c,mu,imgs(:,:,img_no),FCM_Csize);
    end
    [ p ]=GA_o.init( p,c);
end

disp('GA.');
[ SS,ba,bf ]=GA_o.loop(p,imgs(:,:,img_no),GA_Psize,GA_Miter,GA_mu,FCM_Csize);
mu=[];
[ c,mu ]=FCM_o.update(ba,mu,imgs(:,:,img_no),FCM_Csize);

figure();
for i=1:FCM_Csize
    subplot(2,round(FCM_Csize/2),i);
    imagesc(mu(:,:,i));
    title(['c=',num2str(ba(i))]);
end

[a,b]=min(bf);
if(b~=FCM_Csize || b~=(FCM_Csize-1))
    b=FCM_Csize;
    disp('parameters looks wrong! try wirh something else.');
end
th=ba(b);
f0=mu(:,:,b);
fr=f0;
gama=max(max(f0))/3;

sm = strel('ball',5,5);

for i=1:img_size
    for j=1:img_size
        if((i>Morph_SD) && (i<(img_size-Morph_SD)))
            if((j>Morph_SD) && (j<(img_size-Morph_SD)))
                nv=0;
                for k=1:Morph_SD
                    for l=1:Morph_SD
                        if(f0(i+k,j+l)>gama)
                            nv=nv+1;
                        end
                    end
                end
                if(nv>=(2*Morph_SD))
                    fr(i,j)=1;
                else
                    fr(i,j)=0;
                end
            else
                fr(i,j)=0;
            end
        else
            fr(i,j)=0;
        end
    end
end

f1 = imdilate(fr,sm);
f1 = imerode(f1,sm);
f1 = imopen(f1,sm);
mv=mean(mean(f1));

OOI=[];
OOI(:,:,1)=(imgs(:,:,img_no)./300);
OOI(:,:,2)=(imgs(:,:,img_no)./300);
OOI(:,:,3)=(imgs(:,:,img_no)./300);
for i=1:img_size
    for j=1:img_size
        if(f1(i,j)>=mv)
            OOI(i+round(Morph_SD/2),j+round(Morph_SD/2),1)=1.0;
            OOI(i+round(Morph_SD/2),j+round(Morph_SD/2),3)=0.7;
        end
    end
end
figure();
imshow(mat2gray(imgs(:,:,img_no)));
title('input image');

figure();
imagesc(f1);
title('tumor area');

figure();
imagesc(OOI);
title('tumor in image');
