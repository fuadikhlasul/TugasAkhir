function varargout = roi(varargin)

% Last Modified by Fuad Ikhlasul Amal 07-Apr-2015 12:30:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roi_OpeningFcn, ...
                   'gui_OutputFcn',  @roi_OutputFcn, ...
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


% --- Executes just before roi is made visible.
function roi_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

set(handles.axes1, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes2, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes3, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes4, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes5, 'XTickLabel', [], 'YTickLabel', []);

% --- Outputs from this function are returned to the command line.
function varargout = roi_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in startchvdbutton.
function startchvdbutton_Callback(hObject, eventdata, handles)
roi_chvd(handles);


% --- Executes on button press in startedbutton.
function startedbutton_Callback(hObject, eventdata, handles)
roi_ed(handles);
