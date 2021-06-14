function o=FCM

    o.init=@init;
    o.update=@update;

end

function [ c ]=init(img,Csize)

    c=[];
    s=size(img,1);
    Mv=max(max(img));
    mv=min(min(img));
    
    for i=1:Csize
        c(i)=(i*(Mv/(Csize+1))+mv);
    end

end

function [ c,mu ]=update(c,mu,img,Csize)

    s=size(img,1);
    for i=1:s
        for j=1:s
            for k=1:Csize
                tv=0;
                for n=1:Csize
                    tv=tv+((abs(img(i,j)-c(k))/abs(img(i,j)-c(n)))^2);
                end
                if(tv==0 || isnan(tv))
                    mu(i,j,k)=1;
                else
                    mu(i,j,k)=1/tv;
                end
            end
        end
    end
    
    for k=1:Csize
        tu=0;
        td=0;
        for i=1:s
            for j=1:s
                tu=tu+((mu(i,j,k)^2)*img(i,j));
                td=td+(mu(i,j,k)^2);
            end
        end
        c(k)=(tu/td);
    end
    
end