function [output,V] = kfunc(x)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
global pp sigma c t T strike

ft = ppval(fnder(pp),T)*1e-2;

tmT = t-ones(size(t))*T;

if isa(x,'sym')
     V = zcb(t)/zcb(T).*c.*exp(tmT*(ft-x(1))-sigma(1)^2/2*T*tmT.^2);
     for i = 2:size(sigma,1)
         V = V + zcb(t)/zcb(T).*c.*exp(tmT*(ft-x(i))-sigma(i)^2/2*T*tmT.^2);
     end
     output = ones(size(t'))*V;
else
    s = ones(size(x));
    output = ones(size(sigma*x));
    for i = 1:size(sigma,1)
    V(:,:,i) = zcb(t)/zcb(T).*c*s.*exp(tmT*(ft*s-x)-sigma(i)^2/2*T*tmT.^2*s);
    
    output(i,:) = ones(size(t')) * V(:,:,i) - strike;
    end
end


end

