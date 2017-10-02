function globalPoints = antiTransform2Global(camPoints, dx, dy, dz, alpha)
%ANTITRANSFORM2GLOBAL transforms coordinates from diferent reference systems.
%Here it's only took in account the rotation around y axis and all the
%displacements in x, y, z.

%b=ones(4,15)
%camPoints'
%b(1:3,:) = camPoints'

b=camPoints';
TM = [cosd(alpha) 0 sind(alpha) dx; 0 1 0 dy ;-sind(alpha) 0 cosd(alpha) dz; 0 0 0 1]; %Transformation Matrix (rotation and translation)
step2 = TM\b;
globalPoints=step2(1:3,:);

end