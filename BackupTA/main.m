function varargout = main(varargin)

% Last Modified by Fuad Ikhlasul Amal 07-Apr-2015 12:27:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

soclogo = imread('soclogo.jpg');
telulogo = imread('telulogo.jpg');
imshow(telulogo, 'Parent', handles.axes1);
imshow(soclogo, 'Parent', handles.axes2);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- ROI CHVD button.
function roibutton_Callback(hObject, eventdata, handles)
roi;

% --- Feature extraction button.
function febutton_Callback(hObject, eventdata, handles)
fe;

% --- ROI Euclidean Distance button.
function roiedbutton_Callback(hObject, eventdata, handles)
roied;


% --- Executes on button press in verificationbutton.
function verificationbutton_Callback(hObject, eventdata, handles)
verifikasi;

% --- Executes on button press in identificationbutton.
function identificationbutton_Callback(hObject, eventdata, handles)
identifikasi;

% --- Executes on button press in creditsbutton.
function creditsbutton_Callback(hObject, eventdata, handles)
credits;