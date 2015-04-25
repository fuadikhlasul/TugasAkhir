function varargout = roied(varargin)
% Last Modified by Fuad Ikhlasul Amal 09-Apr-2015 07:21:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roied_OpeningFcn, ...
                   'gui_OutputFcn',  @roied_OutputFcn, ...
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


% --- Executes just before roied is made visible.
function roied_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.axes1, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes2, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes3, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes4, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes5, 'XTickLabel', [], 'YTickLabel', []);

% --- Outputs from this function are returned to the command line.
function varargout = roied_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
roi_ed(handles);
