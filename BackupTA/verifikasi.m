function varargout = verifikasi(varargin)
% Last Modified by Fuad Ikhlasul Amal 15-Apr-2015 12:03:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @verifikasi_OpeningFcn, ...
    'gui_OutputFcn',  @verifikasi_OutputFcn, ...
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


% --- Executes just before verifikasi is made visible.
function verifikasi_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.axes1, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes2, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes3, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes4, 'XTickLabel', [], 'YTickLabel', []);

labels = 1:1:300;
labels = [repmat('Data uji ', length(labels), 1), num2str(labels')];
set(handles.listdatatest, 'String', mat2cell(labels));

global pTest vTest testLabel pTrain vTrain trainLabel trainFea printEig veinEig testLabel;

load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
printData = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
veinData = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/multi_feature_conf33_chvd.mat';

nTrain = 3;
[idTrain, idTest] = generate_case(nTrain);

pTrain = printData(idTrain, 1:end-1);
pTest = printData(idTest, 1:end-1);
vTrain = veinData(idTrain, 1:end-1);
vTest = veinData(idTest, 1:end-1);

trainLabel = printData(idTrain, end);
testLabel = printData(idTest, end);

clear printData veinData;

printFea = pTrain * printEig;
veinFea = vTrain * veinEig;
trainFea = [printFea, veinFea];
clear printFea veinFea;

% --- Outputs from this function are returned to the command line.
function varargout = verifikasi_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on selection change in listdatatest.
function listdatatest_Callback(hObject, eventdata, handles)
global testLabel pTest vTest;
idx = get(hObject, 'value');
idperson = testLabel(idx);
idsample = mod(idx, 3);
if idsample == 0
    idsample = 3;
end
imshow(reshape(pTest(idx, :), [155 155]), [], 'Parent', handles.axes1);
imshow(reshape(vTest(idx, :), [155 155]), [], 'Parent', handles.axes2);
if idperson < 100
    if idperson < 10
        prefix = '00';
    else
        prefix = '0';
    end
else
    prefix = '';
end
set(handles.idpersonlbl, 'String', [prefix, num2str(idperson)]);
set(handles.idsamplelbl, 'String', ['0', num2str(idsample)]);

% --- Executes during object creation, after setting all properties.
function listdatatest_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in verbtn.
function verbtn_Callback(hObject, eventdata, handles)
global pTrain vTrain pTest vTest trainLabel trainFea printEig veinEig testLabel;
th = 295.2073;
dimFea = size(trainFea, 2);
idx = get(handles.listdatatest, 'value');
idperson = testLabel(idx);
idmodel = find(trainLabel == idperson);
modelFea = trainFea(idmodel, :);
print = pTest(idx, :);
vein = vTest(idx, :);

for ii = 1 : size(modelFea, 1)
    figure(1);
    set(gcf, 'Visible', 'off')
    hold(handles.axes3, 'off');
    hold(handles.axes4, 'off');
    imshow(reshape(pTrain(idmodel(ii), :), [155 155]), [], 'Parent', handles.axes3);
    imshow(reshape(vTrain(idmodel(ii), :), [155 155]), [], 'Parent', handles.axes4);
    hold(handles.axes3, 'on');
    hold(handles.axes4, 'on');
end

testFea = [print * printEig, vein * veinEig];

d = 0;
for jj = 1 : dimFea
    d = d + (testFea(jj) - modelFea(:, jj)).^2;
end
d = (d).^.5;

set(handles.distancelbl, 'String', num2str(min(d)));

if min(d) <= th
    set(handles.decisionlbl, 'String', 'Akses diterima');
    set(handles.decisionlbl, 'ForegroundColor', 'b');
else
    set(handles.decisionlbl, 'String', 'Akses ditolak');
    set(handles.decisionlbl, 'ForegroundColor', 'r');
end
