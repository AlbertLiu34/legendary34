function [x ,y] = NewtonIteration(f,x0,eps)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明

format long;
%  f：目标函数
%  x0：初始点
%  eps：精度
%  x_0：目标函数的自变量值
%  f_0：目标函数的函数值
if nargin == 2
    eps = 1.0e-6;  %  当未输入精度eps时，默认为十的负六次幂
end
df = diff(f);  %  一阶导数
fxk = 1;
xk = x0;
while fxk > eps
    fx = subs(f,symvar(f),xk);
    if diff(df) == 0
        dfx = double(df);  %  一阶导数不能为零
    else
        dfx = subs(df,symvar(df),xk); 
    end
    xk = xk - fx/dfx;
    fxk = abs(fx);
end

x = xk;
f = subs(f,symvar(f),x);
format short;
x = double(x);
end

