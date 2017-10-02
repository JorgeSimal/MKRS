%%CALIBRACIÓN AUTOMÁTICA

function [ x2, y2, z2, alpha2] = Calibration (skel1, skel2)

u = skel1(4,:)-skel1(3,:);
v = skel2(4,:)-skel2(3,:);
a=AnglesCalc(0,u);
b=AnglesCalc(0,v);
alpha2 = b(3)-a(3);
skel2=antiTransform2Global(skel2,0,0,0,alpha2);
skel2=skel2';

    difskel = abs(skel2-skel1(:,1:3));
    x2=mean(difskel(:,1));
    y2=mean(difskel(:,2));
    z2=mean(difskel(:,3));
   
    
    %Refresh skeleton and test the result
    %skel2(:,1)=skel2(:,1)-x2;
    %skel2(:,2)=skel2(:,2)-y2;
    %skel2(:,3)=skel2(:,3)-z2;
    
    %skel1
    %skel2


end