function [V_mean] = MCSE(StartDate,M,s0,r,mu,sigma,d,b_in,b_out)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
w=windmatlab

SD=datetime(StartDate,'InputFormat',"yyyyMMdd");

while SD < datetime("now")
    StartDate=input('请输入正确日期:','s');
    SD=datetime(StartDate,'InputFormat',"yyyyMMdd");
end

ED=SD+calyears(1)-caldays(1);

EndDate=datestr(ED,'yyyymmdd');

[knockin_date]=w.tdays(StartDate,EndDate,'Days=Trading');

N1=size(knockin_date,1);

for i = 1:11
    outday=SD+calmonths(i);
    if ismember(outday,knockin_date)
        knockout_date(i,:)={datestr(outday,'yyyy/mm/dd')};
    else
        while ismember(outday,knockin_date)==0
            outday=outday+caldays(1);
        end
        knockout_date(i,:)={datestr(outday,'yyyy/mm/dd')};
    end
end


N2=size(knockout_date,1);

knockin_days=datenum(knockin_date);
knockin_days=knockin_days-(datenum(SD)-1)*ones(size(knockin_days));

knockout_days=datenum(knockout_date);
knockout_days=knockout_days-(datenum(SD)-1)*ones(size(knockout_days));

sp=1;
for i = 1:N2
    for j = sp:N1
        if knockin_days(j)==knockout_days(i)
            outindex(i)=j;
            sp = j+1;
        end
    end
end


wt(1)=knockin_days(1);
for i = 2:N1
    wt(i)=knockin_days(i)-knockin_days(i-1);
end

W=ones(M,1)*sqrt(wt/365);

T=randn(M,N1).*W*triu(ones(N1));

S1=s0*exp((mu-d-sigma.^2/2)*W+sigma*T);

S2=S1(:,outindex);

S_out=S2>b_out*s0*ones(size(S2));

Path_out=S_out*ones(N2,1)>zeros(M,1);

S_in=S1<b_in*s0*ones(size(S1));

Path_in=S_in*ones(N1,1)>zeros(M,1);

P=[Path_out Path_in];

V=zeros(M,1);

for i = 1:M
    if P(i,1)
        outpoint=knockout_days(find(S_out(i,:),1,'first'));
        fv=1+outpoint/365*r;
        V(i)=fv*exp(-outpoint/365*mu);
    elseif P(i,2)
        V(i)=S1(i,N1)/s0*exp(-knockin_days(N1)/365*mu);
    else
        V(i)=(1+r)*exp(-mu);
    end    
end


V_mean=ones(1,M)*V/M;


    
end

