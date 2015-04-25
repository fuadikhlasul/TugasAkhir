function varargout = fe(varargin)
% Last Modified by Fuad Ikhlasul Amal 12-Apr-2015 13:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fe_OpeningFcn, ...
                   'gui_OutputFcn',  @fe_OutputFcn, ...
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


% --- Executes just before fe is made visible.
function fe_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.axes1, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes2, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes3, 'XTickLabel', [], 'YTickLabel', []);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = fe_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
global veinEig printEig fea;
[idTrain, ~] = generate_case(1);
load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
print = data(idTrain, 1:end-1);
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
vein = data(idTrain, 1:end-1);
[eig, ~] = LPP(print, 1);
printEig = eig;
printFea = print * printEig;
[eig, ~] = LPP(vein, 1);
veinEig = eig;
veinFea = vein * veinEig;
fea = [printFea veinFea];
idx = 1:1:100;
idlp = 1:1:size(veinEig, 2);
set(handles.idlabel1, 'String', mat2cell(idx));
set(handles.idlabel2, 'String', mat2cell(idx));
set(handles.lstlabel, 'String', mat2cell(idlp));
imshow(reshape(printEig(:, 1), [155 155]), [], 'Parent', handles.axes1);
imshow(reshape(veinEig(:, 1), [155 155]), [], 'Parent', handles.axes2);

% --- Executes on selection change in lstlabel.
function lstlabel_Callback(hObject, eventdata, handles)
global veinEig printEig;
idx = get(hObject,'Value');
imshow(reshape(printEig(:, idx), [155 155]), [], 'Parent', handles.axes1);
imshow(reshape(veinEig(:, idx), [155 155]), [], 'Parent', handles.axes2);

% --- Executes during object creation, after setting all properties.
function lstlabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in idlabel1.
function idlabel1_Callback(hObject, eventdata, handles)
global fea idx1;
hold(handles.axes3, 'off');
idx1 = get(hObject,'Value');
plot(fea(idx1, :), 'b.', 'Parent', handles.axes3);

% --- Executes during object creation, after setting all properties.
function idlabel1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in idlabel2.
function idlabel2_Callback(hObject, eventdata, handles)
global fea idx1;
idx2 = get(hObject,'Value');
hold(handles.axes3, 'off');
plot(fea(idx1, :), 'b.', 'Parent', handles.axes3);
hold(handles.axes3, 'on');
plot(fea(idx2, :), 'ro', 'Parent', handles.axes3);

% --- Executes during object creation, after setting all properties.
function idlabel2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
