function [BondPrice] = zcb(maturity)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
global pp

BondPrice = exp(-maturity.*ppval(pp,maturity)*1e-2);

end

