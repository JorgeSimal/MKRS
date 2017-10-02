function [finalAngles] = AnglesCalc(point1, point2)
%ANGLES Summary of this function goes here
%   Detailed explanation goes here

dif=point2-point1;
%Because of the exchange between y and z axes, we chanche 2 by 3 and
%viceversa
h1=sqrt(dif(1)^2+dif(2)^2);
h2=sqrt(dif(2)^2+dif(3)^2);
h3=sqrt(dif(1)^2+dif(3)^2);
xyangle=asin(dif(2)/h1);
yzangle=asin(dif(2)/h2);
zxangle=asin(dif(3)/h3);

finalAngles=[xyangle; yzangle; zxangle];
finalAngles = rad2deg(finalAngles);
end

