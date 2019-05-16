function varargout = img_gui(varargin)
% IMG_GUI MATLAB code for img_gui.fig
%      IMG_GUI, by itself, creates a new IMG_GUI or raises the existing
%      singleton*.
%
%      H = IMG_GUI returns the handle to a new IMG_GUI or the handle to
%      the existing singleton*.
%
%      IMG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_GUI.M with the given input arguments.
%
%      IMG_GUI('Property','Value',...) creates a new IMG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_gui

% Last Modified by GUIDE v2.5 02-May-2019 17:48:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @img_gui_OutputFcn, ...
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


% --- Executes just before img_gui is made visible.
function img_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_gui (see VARARGIN)

% Choose default command line output for img_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes img_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = img_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
my_path = '/home/user/Desktop/Sonu_new/Testdata/*.jpg';


[fn,pn] = uigetfile(my_path,...
    'Select the image');

fileName = fullfile(pn,fn);
img = imread(fileName);
axes(handles.axes1);
imshow(img);title("Selected Image");
handles.ImgData1=img;
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
set(handles.edit1,'string','');
I3 = handles.ImgData1;
Bt = 20;
Nc = 9;
load('RF_model.mat')
img = rgb2gray(I3);
I = im2double(img);
I=imresize(I,[512,384]);
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';
B = blockproc(I,[8 8],dct);
%     BB = imquantize(B,.05);
q_mtx = floor([
    9,6,6,9,14,23,30,35;
    7,7,8,11,15,34,35,32;
    8,8,9,14,23,33,40,32;
    8,10,13,17,30,50,46,36;
    10,13,21,32,39,63,60,45;
    14,20,32,37,47,60,66,53;
    28,37,45,50,60,70,70,59;
    42,53,55,57,65,58,60,57
    ]*.2);

c = @(block_struct)(block_struct.data) ./ q_mtx;
%imshow(img);
B2 = blockproc(B,[8 8],c);

B2 = round(B2);

B3 = blockproc(B2,[8 8],@(block_struct) q_mtx .* block_struct.data);

invdct = @(block_struct) round(T' * block_struct.data * T);

I2 = blockproc(B3,[8 8],invdct);
Y = I2;
modeLocations = [
    1,2;
    1,3;
    1,4;
    2,1;
    2,2;
    2,3;
    3,1;
    3,2;
    4,1 ];  % location of DCT coefficients

for modeIndex = 1:Nc%size(modeLocations, 1)
    
    modeLocation = modeLocations(modeIndex, :); % loading first location
    [height, width] = size(Y);
    mask = zeros(8);
    mask(modeLocation(1), modeLocation(2)) = 1;
    mask = repmat(mask, height / 8, width / 8);
    coeffs = Y(logical(mask));
    
    Histogram = hist(coeffs, -Bt:1:Bt);
    
    Histograms(modeIndex, :) = Histogram / sum(Histogram);
    
end

features = reshape(Histograms', 1, []);

% vals = find(features);
feat = features(:,vals);    % removing zeroes

lbl = predict(Mdl,feat);
disp(upper(lbl))
%msgbox(upper(lbl),'Prediction:')
set(handles.edit1,'string',lbl);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1,'string',' ');
