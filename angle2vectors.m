function angle2 = angle2vectors(point1, point2, point3)
%point1 = junction point
%point2 = initial vector 
%point3 = final vector

u=point2-point1;
v=point3-point1;
angle2=acosd(dot(u,v)/(norm(u)*norm(v)));
%angle2 = atan2d(norm(cross(u,v)),dot(u,v));

end