function [knockin_days,knockout_days,N1,N2] = DateProcessor(StartDate)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
w=windmatlab;

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


end

