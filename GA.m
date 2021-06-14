function o=GA

    o.init=@init;
    o.loop=@loop;

end

function [ p ]=init( p,c )
    s=size(p,2);
    p(:,s+1)=c;
end

function [ SS,ba,bf ]=loop( p,img,GA_Psize,GA_Miter,GA_mu,FCM_Csize )

ll=[];
r=[];
[ r,p,ll ]=f(p,img,GA_Psize,FCM_Csize);
mv=mean(r);
br=0;
SS=[];
ba=[];
bf=[];

for t=1:GA_Miter
    
    sp=[];
    cc=1;
    for i=1:GA_Psize
        if(r(i)>=mv)
            sp(:,cc)=p(:,i);
            cc=cc+1;
        end
    end
    
    cc=cc-1;
    if(cc>=2)
        for i=1:GA_Psize
            if(r(i)<mv)
                p1=round(rand()*(cc-1))+1;
                p2=round(rand()*(cc-1))+1;
                ss1=round(rand()*(FCM_Csize-1))+1;
                ss2=round(rand()*(FCM_Csize-1))+1;
                p(:,i)=sp(:,p1);
                p(ss1,i)=sp(ss1,p2);
                p(ss2,i)=sp(ss2,p2);
            end
        end
    end
    
    if(rand()<=GA_mu)
        p1=round(rand()*(GA_Psize-1))+1;
        s1=round(rand()*(FCM_Csize-1))+1;
        rv=(rand()*254);
        p(s1,p1)=rv;
    end
    
    [ r,p,ll ]=f(p,img,GA_Psize,FCM_Csize);
    mv=mean(r);
    
    if(br<max(r))
        [br,b]=max(r);
        ba=p(:,b);
        bf=ll(:,b);
    end
    %disp(['GA : best f=',num2str(br),'  mean f=',num2str(mv)]);
    SS(t,1)=br;
    SS(t,2)=mv;
    
end

end

function [ r,p,ll ]=f(p,img,GA_Psize,FCM_Csize)

s=size(img,1);
pp=zeros(FCM_Csize,GA_Psize,4);
r=zeros(1,GA_Psize);
ll=zeros(FCM_Csize,GA_Psize);
for i=1:s
    for j=1:s
        for k=1:GA_Psize
            [a,b]=min(abs(p(:,k)-img(i,j)));
            pp(b,k,1)=pp(b,k,1)+i;
            pp(b,k,2)=pp(b,k,2)+j;
            pp(b,k,3)=pp(b,k,3)+1;
            pp(b,k,4)=pp(b,k,4)+img(i,j);
        end
    end
end

pp(:,:,1)=(pp(:,:,1)./(pp(:,:,3)+0.0001));
pp(:,:,2)=(pp(:,:,2)./(pp(:,:,3)+0.0001));
pp(:,:,4)=(pp(:,:,4)./(pp(:,:,3)+0.0001));

for i=1:s
    for j=1:s
        for k=1:GA_Psize
            [a,b]=min(abs(p(:,k)-img(i,j)));
            r(k)=r(k)+(sqrt((i-pp(b,k,1))^2+(j-pp(b,k,2))^2));
            ll(b,k)=ll(b,k)+(sqrt((i-pp(b,k,1))^2+(j-pp(b,k,2))^2));
        end
    end
end

r=1./r;

end