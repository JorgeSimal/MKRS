tic;
%%%%%USER PARAMETERS%%%%%
%Assuming CAM1 is left, CAM2 is right and global reference system in between
x1=0;           x2=0;
y1=0;           y2=0;
z1=0;           z2=0;
alpha1=0;       alpha2=0;
%%%%%%%%%%%%%%%%%%%%%%%%%

%Variables declaration
time=0;
Confidence1=zeros(1,15);
Confidence2=zeros(1,15);
m1=mean(Confidence1);
m2=mean(Confidence2);

while (time<1)
time=toc;
CamPoints1=importdata('0Text.txt');
CamPoints2=importdata('1Text.txt');

    %Calibration
    RealPoints1 = Transform2Global(CamPoints1(:,1:3), x1, y1, z1, alpha1);
    Confidence1 = CamPoints1(:,4)';
    %RealPoints2 = Transform2Global(CamPoints2(:,1:3), x2, y2, z2, alpha2);
    %Confidence2 = CamPoints2(:,4)';
    
    figure(1);
    hold on;
    set(gca, 'ylim', [0 1]);
    xlabel('Time(s)');
    ylabel('Confidence');
    scatter(time, mean(Confidence1),'filled','red'), ax.YLim =[0 1];
    
    figure(2);
    set(gca, 'ylim', [0 1]);
    xlabel('Time(s)');
    ylabel('Confidence');
    hold on;
   
    scatter(time,mean(Confidence2),'filled','red');
    
    %Mix points somehow and draw skeleton
    %%Mix skeletons
    Gskeleton = zeros(3,15);
    for i = 1:15
        if (Confidence1(i)>Confidence2(i))
            Gskeleton(:,i)=RealPoints1(:,i);
        else
            if (Confidence2(i)>Confidence1(i))
                Gskeleton(:,i)=RealPoints2(:,i);
            else    %Confidence1(i)==Confidence2(i)
                Gskeleton(:,i)=mean(RealPoints1(:,i),RealPoints2(:,i));
            end
        end
   
    end
    
    %%Drawing skeleton
    figure(3);
    set(gca, 'xlim', [-1000 1000], 'ylim', [0 2000]);
    
    scatter3(RealPoints1(1,:),RealPoints1(3,:),RealPoints1(2,:),'filled'),view(0,0);
   
    SkeletonConnectionMap = [
        [1 2];
        [2 3];
        [3 5];
        [5 7];
        [2 4];
        [4 6];
        [6 8];
        [3 9];
        [4 9];
        [9 10];
        [9 11];
        [10 11];
        [10 12];
        [12 14];
        [11 13];
        [13 15]];
    
    for j = 1:16
        X1 = [Gskeleton(1, SkeletonConnectionMap(j,1)) Gskeleton(1, SkeletonConnectionMap(j,2))];
        Y1 = [Gskeleton(3, SkeletonConnectionMap(j,1)) Gskeleton(3, SkeletonConnectionMap(j,2))];
        Z1 = [Gskeleton(2, SkeletonConnectionMap(j,1)) Gskeleton(2, SkeletonConnectionMap(j,2))];
        line(X1,Y1,Z1,'LineWidth',1.5,'LineStyle','-','Marker','o','Color','b');
    end
    
    %%Angles calculation%%  Reference: 
    %Neck-head
    hn=Angles(Gskeleton(:,2),Gskeleton(:,1));

    %Shoulder-elbow
    lse=Angles(Gskeleton(:,3),Gskeleton(:,5));
    rse=Angles(Gskeleton(:,4),Gskeleton(:,6));
    
    %Elbow-hand
    leh=Angles(Gskeleton(:,5),Gskeleton(:,7));
    reh=Angles(Gskeleton(:,6),Gskeleton(:,8));
    
    %Torso-neck
    tn=Angles(Gskeleton(:,9),Gskeleton(:,2));
    
    %%Draw angles (depending on the view and selection)
    sel=0; view=1;
    figure(3);
    hold on;
    switch view
        case {1} %front view (xy)
            xsel=1;ysel=1;zsel=0;
        case {2} %left view (yz)
            xsel=0;ysel=1;zsel=1;
        case {3} %right view (yz)
            xsel=0;ysel=1;zsel=1;
        case {4} %top view (zx)
            xsel=1;ysel=0;zsel=1;
        otherwise
            xsel=1;ysel=1;zsel=1;
    end
    
    %Documentacion generator
    %Guardar las notas y ...
    
%time=toc;
pause(.0001);
end

