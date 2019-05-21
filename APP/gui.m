function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 16-May-2019 14:16:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Abrir ficheiro de ?udio.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[nome,local] = uigetfile('*.wav','Coloque Um Ficheiro mp3.');       % Abrir explorador para carregar ficheiro
[audio,fs]=audioread(nome); 
handles.audio=audio;
handles.fs=fs;
player=audioplayer(audio,fs);
handles.player=player;
guidata(hObject, handles);

function yb = wahwah(fs,audio,handles)  % Fun��o para efeito Wah-wah
damp=0.05;
minf=500;
maxf=3000;
Fw=get(handles.slider7,'Value');    % Varia��o frequ�ncia
delta = Fw/fs;
% create triangle wave of centre frequency values
Fc=minf:delta:maxf;
while(length(Fc) < length(audio) )
Fc= [ Fc (maxf:-delta:minf) ];
Fc= [ Fc (minf:delta:maxf) ];
end
% trim tri wave to size of input
Fc = Fc(1:length(audio));
% difference equation coefficients
% must be recalculated each time Fc changes
F1 = 2*sin((pi*Fc(1))/fs);
% this dictates size of the pass bands
Q1 = 2*damp;
yh=zeros(size(audio)); % create emptly out vectors
yb=zeros(size(audio));
yl=zeros(size(audio));
% first sample, to avoid referencing of negative signals
yh(1) = audio(1);
yb(1) = F1*yh(1);
yl(1) = F1*yb(1);
% apply difference equation to the sample
for n=2:length(audio),
yh(n) = audio(n) - yl(n-1) - Q1*yb(n-1);
yb(n) = F1*yh(n) + yb(n-1);
yl(n) = F1*yb(n) + yl(n-1);
F1 = 2*sin((pi*Fc(n))/fs);
end

maxyb = max(abs(yb));
yb = yb/maxyb;
disp(yb);


function exit = panning(audiotot, handles, hObject) % Fun��o efeito panning
ang_inicial = (get(handles.slider3,'Value')*-1); 
ang_final=ang_inicial;
v = 32;
juncao_ang= (ang_inicial - ang_final)/v * pi / 180;

seg = floor((length(audiotot)/v) - 1);
m = 1;
ang = ang_inicial * pi / 180; 
exit=[[],[]];
for i=1:v
    A =[cos(ang), sin(ang); -sin(ang), cos(ang)];
    stereo = [audiotot(m:m+seg);audiotot(m:m+seg)];
    exit = [exit, A * stereo];
    ang = ang + juncao_ang;
    m = m + seg;
end;

function out = delay(fs,audio,handles)
s=size(audio,1);
out=zeros(s,1);
%x=zeros(s,1);
z=zeros(s,1);
%y=zeros(s,1);
%e=zeros(s,1);
f=zeros(s,1);
wet=get(handles.slider8,'Value');
string=[num2str(wet) '%'];
set(handles.text13,'String',string);
vde=get(handles.slider9,'Value');
string=[num2str(vde) 'ms'];
set(handles.text14,'String',string);
delay=round(vde*fs); %delay em samples
feed=get(handles.slider10,'Value');
string=[num2str(feed) '%'];
set(handles.text15,'String',string);

for i=1:s
    x(i)=aii(i);
    y(i)=x(i)*wet;
    if(i-delay>=1)
        e(i)=z(i-delay); 
    else
        e(i)=0; %se tiver vazio
    end
    
    f(i)=e(i)*feed;
    z(i)=x(i)+f(i);
    out(i)=e(i)+y(i);
    
end

% --- Reproduzir ?udio.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
player=handles.player;
out = handles.audio;
fs = handles.fs;
%------------------- Volume ----------------------------------
gain=get(handles.slider6,'Value');
n=size(out);
for i=1:n
    audiotot(i)=(out(i)*gain);
end
%------------------Panning -----------------------------------
pan = @panning;
exit = pan(audiotot,handles,hObject);
%---------------Distortion------------------------------------------------
if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max'))     % Caso utilizador carregue na op��o de usar efeito
n=size(exit,1);
y=zeros(n,1);
gaindist=get(handles.slider5,'Value');
string=[num2str(gaindist) '%'];
set(handles.text7,'String',string);

for i=1:n
   y(i)=exit(i,1)*gaindist;
   if(y(i)>1)
       y(i)=1;
   elseif (y(i)<-1)
       y(i)=-1;
   end
end
end
%-----------------Wah-Wah--------------------------------------------
wah=@wahwah;
if (get(handles.checkbox2,'Value') == get(handles.checkbox2,'Max'))
 exit = wah(fs,exit,handles);
end

%--------------- Delay-----------------------------------------------
del=@delay;
if (get(handles.checkbox3,'Value') == get(handles.checkbox2,'Max'))
 exit = del(fs,exit,handles);
end
%--------------Reproduzir �udio---------------------------------------
playerpan=audioplayer(exit,fs);
play(playerpan);
%disp(exit);
handles.playerpan=playerpan;

handles.exit=exit;
guidata(hObject, handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Bot?o Stop do ?udio.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
player=handles.playerpan;
stop(player);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Slider Panning.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% ---Exportar ?udio.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fs=handles.fs;
audio=handles.exit;
audiowrite('teste.wav',audio, fs);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
