
%% INTERFACE
function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose 'GUI allows only one
%      instance to run (singleton)'.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 15-Sep-2017 20:36:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
    if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
    gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT


% --- Executes just before interface is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

% Choose default command line output for interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(gcf,'javaframe');
jIcon=javax.swing.ImageIcon('C:\MKRS\square.png');
jframe.setFigureIcon(jIcon);

%Load interface pictures
i1=imread('C:\MKRS\kin.jpg');
%set(handles.pushbutton15,'CData',i1);
%set(handles.pushbutton15,'CData',i1)
axes(handles.axes1);
imshow(i1);
axes(handles.axes2);
imshow(i1);
axes(handles.axes3);
i2=imread('C:\MKRS\logo_uc3m.jpg');
imshow(i2);
%Clear 00_Recorded Anngles.csv
fd='00_Recorded Angles.csv';
if(fopen(fd)~=-1)
    f=fopen(fd,'wt');
    fprintf(f, 'Time(s),head-neck,neck-torso,left elbow,left hand,right elbow,right hand,left shoulder-hand,right shoulder-hand,left arm-body,right arm-body(o)\n');
    fclose(f);
end
set(handles.status,'string','Connect Cameras & Click on RUN');

set(handles.Stopbutton, 'Userdata', 0);
set(handles.Calbutton, 'Userdata', 0);
%cla(handles.axes4,'reset');
cla(handles.axes5,'reset');
cla(handles.axes6,'reset');
set(handles.conf1,'string', '0 %');
set(handles.conf2,'string', '0 %');


% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function Runbutton_Callback(hObject, eventdata, handles)
tic;

%% PROCCESSING

%%%%%USER PARAMETERS%%%%%
%Assuming CAM1 is left, CAM2 is right and global reference system in between
%x1=1030 ;       x2=-720;    %(mm)
%y1=240;         y2=240;    %(mm)
%z1=-250;        z2=-250;   %(mm)
%alpha1=-20;     alpha2=20;  %(degrees)

x1=0;x2=0;
y1=0;y2=0;
z1=0;z2=0;
alpha1=0;alpha2=0;

%Little settings
upshoulders=70;
%%%%%%%%%%%%%%%%%%%%%%%%%

%Variables declaration
%CamPoints1=importdata('C:\Users\MSI-PC\Desktop\MATLAB3\0Text.txt','\t');
CamPoints1=importdata('C:\MKRS\0Text.txt','\t');
%CamPoints2=importdata('C:\Users\MSI-PC\Desktop\MATLAB3\1Text.txt','\t');
CamPoints2=importdata('C:\MKRS\1Text.txt','\t');
Confidence1=zeros(1,15);
Confidence2=zeros(1,15);
count=0;
count2=0;

%Main loop
    while ((count2==0||~isempty(CamPoints1)||~isempty(CamPoints2)))
    time=toc;
    count=count+1;
    count2=count2+1;
    set(handles.status,'string','Running...');
    
    %Calibration
    cal = get(handles.Calbutton, 'userdata');
    if(cal && (~isempty(CamPoints1))&& (~isempty(CamPoints2)) )
        set(handles.status,'string','Calibrating...');
        [dx,dy,dz,dalpha]=Calibration(CamPoints1, CamPoints2);
        x1=dx/2;y1=dy;z1=-dz;alpha1=-dalpha/2;
        x2=-dx/2;y2=dy;z2=-dz;alpha2=dalpha/2;
        set(handles.Calbutton, 'Userdata', 0);
    end

    %CamPoints11=importdata('C:\Users\MSI-PC\Desktop\MATLAB3\0Text.txt','\t');
    CamPoints11=importdata('C:\MKRS\0Text.txt','\t');
        if (~isempty(CamPoints11))
            %Create and/or clear txt files
            %fclose(fopen('C:\MKRS\0Text.txt','wt'));
            CamPoints1=CamPoints11;
        end
        
    %CamPoints22=importdata('C:\Users\MSI-PC\Desktop\MATLAB3\1Text.txt','\t');
    CamPoints22=importdata('C:\MKRS\1Text.txt','\t');
        if(~isempty(CamPoints11))
            %fclose(fopen('C:\MKRS\1Text.txt','wt'));
            CamPoints2=CamPoints22;
        end

    %Coordinates transforms
    if(~isempty(CamPoints1))
    RealPoints1 = Transform2Global(CamPoints1(:,1:3), x1, y1, z1, alpha1);
    RealPoints1(2,2:4)=RealPoints1(2,2:4)+upshoulders;
    Confidence1 = CamPoints1(:,4)';
    end
 
    if(~isempty(CamPoints2))
    RealPoints2 = Transform2Global(CamPoints2(:,1:3), x2, y2, z2, alpha2);
    RealPoints2(2,2:4)=RealPoints2(2,2:4)+upshoulders;
    Confidence2 = CamPoints2(:,4)';
    end
    
    %%Anti-mistake filters
    %%%Invalidate skeleton if head missing or neck stretching 
    if(~isempty(CamPoints1))
        neck1=RealPoints1(:,1)-RealPoints1(:,2);
        hn1=AnglesCalc(RealPoints1(:,2),RealPoints1(:,1));
        hn1=round(hn1);
        if((Confidence1(1)==0)||(norm(neck1)>250)||(hn1(1)<60)||(hn1(2)<60))
            Confidence1(:)=0;
        end
    end
    
    if(~isempty(CamPoints2))
        neck2=RealPoints2(:,1)-RealPoints2(:,2);
        hn2=AnglesCalc(RealPoints2(:,2),RealPoints2(:,1));
        hn2=round(hn2);
        if((Confidence2(1)==0)||(norm(neck2)>250)||(hn2(1)<60)||(hn2(2)<60))
            Confidence2(:)=0;
        end
    end

    
    if(count>10)
    cla(handles.axes5,'reset');
    cla(handles.axes6,'reset');
    count=0;
    end
    
    axes(handles.axes5);
    ylabel(handles.axes5,'Confidence');
    set(gca, 'ylim', [0 1], 'xlim', [-inf inf]);
    hold on;
    scatter(time, mean(Confidence1(1:11)),'filled','red');
    set(handles.conf1,'string',strcat(int2str(100*round(mean(Confidence1(1:11)),2)),' %'));
    
    axes(handles.axes6);
    set(gca, 'ylim', [0 1], 'xlim', [-inf inf]);
    hold on;
    scatter(time,mean(Confidence2(1:11)),'filled','red');
    set(handles.conf2,'string',strcat(int2str(100*round(mean(Confidence2(1:11)),2)),' %'));
    
    %Mix skeletons
    Gskeleton = zeros(3,15);
        
    %%Fill new Skeleton
    for i = 1:15
        if (Confidence1(i)>Confidence2(i))
            Gskeleton(:,i)=RealPoints1(:,i);
        else
            if (Confidence2(i)>Confidence1(i))
                Gskeleton(:,i)=RealPoints2(:,i);
            else
                if((Confidence1(i)==Confidence2(i))&&(Confidence1(i)~=0)&&(Confidence2(i)~=0))
                    Gskeleton(1,i) = mean([RealPoints1(1,i); RealPoints2(1,i)]);
                    Gskeleton(2,i) = mean([RealPoints1(2,i); RealPoints2(2,i)]);
                    Gskeleton(3,i) = mean([RealPoints1(3,i); RealPoints2(3,i)]);
                end
            end
        end
   
    end
    
    %%Drawing skeleton
    axes(handles.axes4);
    %In scatter3 we change y to z and viceversa to better plotting
    %scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(-37.5,30);
   
   if(get(handles.Frontbutton,'Value'))
    scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(0,0);
    axis([-750 750 1000 2500 -750 750]);
    %axis equal;
    %axis off;
   end
   
   if(get(handles.Topbutton,'Value'))
    scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(0,90);
    axis([-750 750 1000 2500]);
    
    %axis equal;
    %axis off;
   end
   
   if(get(handles.Leftbutton,'Value'))
    scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(-90,0);
    axis([-750 750 1000 2500 -750 750]);
    %axis equal;
    %axis off;
   end
   
   if(get(handles.Rightbutton,'Value'))
    scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(90,0);
    axis([-750 750 1000 2500 -750 750]);
    %axis equal;
    %axis off;
   end
   
   if(get(handles.globalbutton,'Value'))
    scatter3(Gskeleton(1,1:11),Gskeleton(3,1:11),Gskeleton(2,1:11),'filled','C','b'),view(-37.5,30);
    axis([-750 750 1000 2500 -750 750]);
    %axis equal;
    %axis off;
   end
   
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
        %[10 12];
        %[12 14];
        %[11 13];
        %[13 15]
        ];
    
    for j = 1:12
        X1 = [Gskeleton(1, SkeletonConnectionMap(j,1)) Gskeleton(1, SkeletonConnectionMap(j,2))];
        Y1 = [Gskeleton(3, SkeletonConnectionMap(j,1)) Gskeleton(3, SkeletonConnectionMap(j,2))];
        Z1 = [Gskeleton(2, SkeletonConnectionMap(j,1)) Gskeleton(2, SkeletonConnectionMap(j,2))];
        line(X1,Y1,Z1,'LineWidth',1.5,'LineStyle','-','Marker','o','Color','b');
    end
    
    %%Angles calculation%%
    drawnow;
    ang=zeros(3,11);
    %a='Front';
    %fprintf('%s',a);
    %cab=cellstr(['Front';'Lateral';'Top'])
    %cab=[1 2 3; 4 5 6; 7 8 9];
    
    %Neck-head
    if(handles.headneck.Value)
        hn=AnglesCalc(Gskeleton(:,2),Gskeleton(:,1));
        hn=round(hn);
        set(handles.uno1,'string',hn(1));
        set(handles.uno2,'string',hn(2));
        set(handles.uno3,'string',hn(3));
        ang(:,2)=hn;
    end

    %Neck-torso
    if(handles.necktorso.Value)
        nt=AnglesCalc(Gskeleton(:,9),Gskeleton(:,2));
        nt=round(nt);
        set(handles.dos1,'string',nt(1));
        set(handles.dos2,'string',nt(2));
        set(handles.dos3,'string',nt(3));
        ang(:,3)=nt;
    end
    
    %Shoulder-elbow
    if(handles.leftelbow.Value)
        lse=AnglesCalc(Gskeleton(:,3),Gskeleton(:,5));
        lse=round(lse);
        set(handles.tres1,'string',lse(1));
        set(handles.tres2,'string',lse(2));
        set(handles.tres3,'string',lse(3));
        ang(:,4)=lse;
    end
    
    if(handles.rightelbow.Value)
        rse=AnglesCalc(Gskeleton(:,4),Gskeleton(:,6));
        rse=round(rse);
        set(handles.cinco1,'string',rse(1));
        set(handles.cinco2,'string',rse(2));
        set(handles.cinco3,'string',rse(3));
        ang(:,5)=rse;
    end
    
    %Elbow-hand
    if(handles.lefthand.Value)
        leh=AnglesCalc(Gskeleton(:,5),Gskeleton(:,7));
        leh=round(leh);
        set(handles.cuatro1,'string',leh(1));
        set(handles.cuatro2,'string',leh(2));
        set(handles.cuatro3,'string',leh(3));
        ang(:,6)=leh;
    end
    
    if(handles.righthand.Value)
        reh=AnglesCalc(Gskeleton(:,6),Gskeleton(:,8));
        reh=round(reh);
        set(handles.seis1,'string',reh(1));
        set(handles.seis2,'string',reh(2));
        set(handles.seis3,'string',reh(3));
        ang(:,7)=reh;
    end
    
    %Left ShoulderElbowHand
    if(handles.checkbox23.Value)
        lseh=angle2vectors(Gskeleton(:,5),Gskeleton(:,7),Gskeleton(:,3));
        lseh=round(lseh);
        set(handles.edit23,'string',lseh);
        ang(:,8)=lseh;
    end
    
    %Right ShoulderElbowHand
    if(handles.checkbox24.Value)
        rseh=angle2vectors(Gskeleton(:,6),Gskeleton(:,4),Gskeleton(:,8));
        rseh=round(rseh);
        set(handles.edit24,'string',rseh);
        ang(:,9)=rseh;
    end
    
    %Left ArmBody
    if(handles.checkbox25.Value)
        s=Gskeleton(:,2)-Gskeleton(:,3);    
        lab=angle2vectors(Gskeleton(:,3),Gskeleton(:,9)-s,Gskeleton(:,5));
        lab=round(lab);
        set(handles.edit25,'string',lab);
        ang(:,10)=lab;
    end
    
    %Right ArmBody
    if(handles.checkbox26.Value)
        t=Gskeleton(:,4)-Gskeleton(:,2);        
        rab=angle2vectors(Gskeleton(:,4),Gskeleton(:,9)+t,Gskeleton(:,6));
        rab=round(rab);
        set(handles.edit26,'string',rab);
        ang(:,11)=rab;
    end
    
    ang(:,1)=round(time,3);
    %table=[cab ang];
    table=ang;
    
    %STOP
    stop = get(handles.Stopbutton, 'userdata');
    if(stop)
        set(handles.status,'string','Stopped.');
        break;
    end
    
    if(get(handles.pushbutton12,'userdata'))
       fid=fopen('00_Recorded Angles.csv','a'); 
       formatSpec = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
       fprintf(fid,formatSpec,table(1,:),table(2,:),table(3,:));
       fclose(fid);
    end
    
    %pause(.001);
    end
    set(handles.status,'string','Stopped.');

    if (isempty(CamPoints1)&&isempty(CamPoints2))
    %cla(handles.axes4,'reset'); 
    cla(handles.axes5,'reset');
    cla(handles.axes6,'reset');
    %set(handles.conf1,'string', '0 %');
    %set(handles.conf2,'string', '0 %');
    %set(handles.status,'string','Connect Cameras & Click on RUN');
    end



%% NOTES 

function Notes_Callback(hObject, ~, handles)
%Save notes
notes = get(hObject,'String');
fileID = fopen('C:\MKRS\Notas.txt','wt');
formatSpec = '%s\n';
[n,~] = size(notes);
for j=1:n
    fprintf(fileID, formatSpec, notes(j,:));
end
    fclose(fileID);

function Notes_CreateFcn(hObject, ~, handles)


%% SELECT ANGLES TO TRACK

function headneck_Callback(hObject, eventdata, handles)
% str2double(get(hObject,'String')) returns contents of righthand as a double
if(~get(hObject,'Value'))
    set(handles.uno1,'string','-');
    set(handles.uno2,'string','-');
    set(handles.uno3,'string','-');
end
function necktorso_Callback(hObject, ~, handles)
if(~get(hObject,'Value'))
    set(handles.dos1,'string','-');
    set(handles.dos2,'string','-');
    set(handles.dos3,'string','-');
end
function leftelbow_Callback(hObject, ~, handles)
if(~get(hObject,'Value'))
    set(handles.tres1,'string','-');
    set(handles.tres2,'string','-');
    set(handles.tres3,'string','-');
end
function lefthand_Callback(hObject, ~, handles)
if(~get(hObject,'Value'))
    set(handles.cuatro1,'string','-');
    set(handles.cuatro2,'string','-');
    set(handles.cuatro3,'string','-');
end
function rightelbow_Callback(hObject, ~, handles)
if(~get(hObject,'Value'))
    set(handles.cinco1,'string','-');
    set(handles.cinco2,'string','-');
    set(handles.cinco3,'string','-');
end
function righthand_Callback(hObject, ~, handles)
if(~get(hObject,'Value'))
    set(handles.seis1,'string','-');
    set(handles.seis2,'string','-');
    set(handles.seis3,'string','-');
end

function checkbox23_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(handles.edit23,'string','-');
end
function checkbox24_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(handles.edit24,'string','-');
end
function checkbox25_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(handles.edit25,'string','-');
end
function checkbox26_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(handles.edit26,'string','-');
end



%% PUSHBUTTONS

function Stopbutton_Callback(hObject, ~, handles)
set(handles.Stopbutton, 'userdata', 1);

function Calbutton_Callback(hObject, eventdata, handles)
set(handles.Calbutton, 'userdata', 1);

function Savebutton_Callback(hObject, ~, handles)
saveas(handles.figure1,'Capture','png');
save('Capture');

function globalbutton_Callback(hObject, ~, handles)
handles.axes4.View= [-37.5,30];

function Frontbutton_Callback(hObject, ~, handles)
handles.axes4.View  = [0,0];

function Topbutton_Callback(hObject, ~, handles)
handles.axes4.View  = [0,90];

function Leftbutton_Callback(hObject, ~, handles)
handles.axes4.View  = [-90,0];

function Rightbutton_Callback(hObject, ~, handles)
handles.axes4.View  = [90,0];

%% NUMBER BOXES just to show angles

function uno1_Callback(hObject, ~, handles)
function uno1_CreateFcn(hObject, ~, handles)
function uno2_Callback(hObject, ~, handles)
function uno2_CreateFcn(hObject, ~, handles)
function uno3_Callback(hObject, ~, handles)
function uno3_CreateFcn(hObject, ~, handles)
function dos1_Callback(hObject, ~, handles)
function dos1_CreateFcn(hObject, ~, handles)
function dos2_Callback(hObject, ~, handles)
function dos2_CreateFcn(hObject, ~, handles)
function dos3_Callback(hObject, ~, handles)
function dos3_CreateFcn(hObject, ~, handles)
function tres1_Callback(hObject, ~, handles)
function tres1_CreateFcn(hObject, ~, handles)
function tres2_Callback(hObject, ~, handles)
function tres2_CreateFcn(hObject, ~, handles)
function tres3_Callback(hObject, ~, handles)
function tres3_CreateFcn(hObject, ~, handles)
function cuatro1_Callback(hObject, ~, handles)
function cuatro1_CreateFcn(hObject, ~, handles)
function cuatro2_Callback(hObject, ~, handles)
function cuatro2_CreateFcn(hObject, ~, handles)
function cuatro3_Callback(hObject, ~, handles)
function cuatro3_CreateFcn(hObject, ~, handles)
function cinco1_Callback(hObject, ~, handles)
function cinco1_CreateFcn(hObject, ~, handles)
function cinco2_Callback(hObject, ~, handles)
function cinco2_CreateFcn(hObject, ~, handles)
function cinco3_Callback(hObject, ~, handles)
function cinco3_CreateFcn(hObject, ~, handles)
function seis1_Callback(hObject, ~, handles)
function seis1_CreateFcn(hObject, ~, handles)
function seis2_Callback(hObject, ~, handles)
function seis2_CreateFcn(hObject, ~, handles)
function seis3_Callback(hObject, ~, handles)
function seis3_CreateFcn(hObject, ~, handles)

function edit23_Callback(hObject, eventdata, handles)
function edit23_CreateFcn(hObject, eventdata, handles)
function edit24_Callback(hObject, eventdata, handles)
function edit24_CreateFcn(hObject, eventdata, handles)
function edit25_Callback(hObject, eventdata, handles)
function edit25_CreateFcn(hObject, eventdata, handles)
function edit26_Callback(hObject, eventdata, handles)
function edit26_CreateFcn(hObject, eventdata, handles)

function conf1_Callback(hObject, eventdata, handles)
function conf1_CreateFcn(hObject, eventdata, handles)
function conf2_Callback(hObject, eventdata, handles)
function conf2_CreateFcn(hObject, eventdata, handles)

function radiobutton4_Callback(hObject, eventdata, handles)
set(handles.uipanel6,'Visible','on');
set(handles.uipanel7,'Visible','off');

function radiobutton5_Callback(hObject, eventdata, handles)
set(handles.uipanel6,'Visible','off');
set(handles.uipanel7,'Visible','on');

function pushbutton12_Callback(hObject, eventdata, handles)
set(handles.pushbutton12,'Visible','off');
set(handles.pushbutton13,'Visible','on');
set(handles.pushbutton12, 'userdata', 1);
set(handles.pushbutton13, 'userdata', 0);

function pushbutton13_Callback(hObject, eventdata, handles)
set(handles.pushbutton13,'Visible','off');
set(handles.pushbutton12,'Visible','on');
set(handles.pushbutton13, 'userdata', 1);
set(handles.pushbutton12, 'userdata', 0);

function pushbutton14_Callback(hObject, eventdata, handles)
open('C:\MKRS\UserViewer0PP.exe');
%open('SimpleUserTracker0.exe');

function pushbutton15_Callback(hObject, eventdata, handles)
open('C:\MKRS\UserViewer1PP.exe');
%open('SimpleUserTracker1.exe');

function pushbutton18_Callback(hObject, eventdata, handles)
dos('taskkill /T /IM UserViewer0PP.exe');

function pushbutton19_Callback(hObject, eventdata, handles)
dos('taskkill /F /IM UserViewer1PP.exe');
