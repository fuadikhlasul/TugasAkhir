function varargout = identifikasi(varargin)
% Last Modified by Fuad Ikhlasul Amal 17-Apr-2015 14:37:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @identifikasi_OpeningFcn, ...
                   'gui_OutputFcn',  @identifikasi_OutputFcn, ...
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

% --- Executes just before identifikasi is made visible.
function identifikasi_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

set(handles.axes1, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes2, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes3, 'XTickLabel', [], 'YTickLabel', []);
set(handles.axes4, 'XTickLabel', [], 'YTickLabel', []);

labels = 1:1:300;
labels = [repmat('Data uji ', length(labels), 1), num2str(labels')];
set(handles.listdatatest, 'String', mat2cell(labels));

global pTest vTest pTrain vTrain modelFea printEig veinEig testLabel trainLabel;
load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
printData = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
veinData = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/multi_feature_conf33_chvd.mat';
[idTrain, idTest] = generate_case(3);
pTest = printData(idTest, 1:end-1);
vTest = veinData(idTest, 1:end-1);
pTrain = printData(idTrain, 1:end-1);
vTrain = veinData(idTrain, 1:end-1);
trainLabel = printData(idTrain, end);
testLabel = printData(idTest, end);
modelFea = [pTrain * printEig, vTrain * veinEig];
clear printData veinData;

% --- Outputs from this function are returned to the command line.
function varargout = identifikasi_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in listdatatest.
function listdatatest_Callback(hObject, eventdata, handles)
global pTest vTest testLabel;
idx = get(hObject, 'value');
personid = testLabel(idx);
sampleid = mod(idx, 3);
if sampleid == 0
    sampleid = 3;
end
if personid < 100
    if personid < 10
        prefix = '00';
    else
        prefix = '0';
    end
else
    prefix = '';
end
set(handles.actualidlbl, 'String', ['ID ', prefix, num2str(personid)]);
set(handles.sampleidlbl, 'String', ['S-0', num2str(sampleid)]);
imshow(reshape(pTest(idx, :), [155 155]), [], 'Parent', handles.axes1);
imshow(reshape(vTest(idx, :), [155 155]), [], 'Parent', handles.axes2);

% --- Executes during object creation, after setting all properties.
function listdatatest_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in identifybtn.
function identifybtn_Callback(hObject, eventdata, handles)
global pTrain vTrain modelFea pTest vTest printEig veinEig trainLabel testLabel;

dimFea = size(modelFea, 2);
idx = get(handles.listdatatest, 'value');
print = pTest(idx, :);
vein = vTest(idx, :);
testFea = [print * printEig, vein * veinEig];

th = 295.2073;

dd = 999999;
mindist = dd;
idxPredicted = 1;

for ii = 1 : size(pTrain, 1)
    figure(1);
    set(gcf, 'Visible', 'off');
    hold(handles.axes3, 'off');
    hold(handles.axes4, 'off');
    imshow(reshape(pTrain(ii, :), [155 155]), [], 'Parent', handles.axes3);
    imshow(reshape(vTrain(ii, :), [155 155]), [], 'Parent', handles.axes4);
    hold(handles.axes3, 'on');
    hold(handles.axes4, 'on');
    
    dd = 0;
    for ff = 1 : dimFea
        dd = dd + (modelFea(ii, ff) - testFea(ff))^2;
    end
    dd = (dd)^.5;
    
    if dd < mindist
        mindist = dd;
        idxPredicted = ii;
    end
    
    if trainLabel(ii) < 100
        if trainLabel(ii) < 10
            pfx = '00';
        else
            pfx = '0';
        end
    else
        pfx = '';
    end
        
    set(handles.text17, 'String', [pfx, num2str(trainLabel(ii))]);
    set(handles.distlbl, 'String', num2str(dd));
end

set(handles.text17, 'String', '--');
set(handles.distlbl, 'String', '--');
    
set(handles.distancelbl, 'String', num2str(mindist));
predicted = trainLabel(idxPredicted);
actual = testLabel(idx);

if predicted < 100
    if predicted < 10
        pfx = '00';
    else
        pfx = '0';
    end
else
    pfx = '';
end

if mindist <= th
    set(handles.predictedidlbl, 'String', ['ID ', pfx, num2str(predicted)]);
    if predicted ~= actual
        set(handles.predictedidlbl, 'ForegroundColor', 'r');
    else
        set(handles.predictedidlbl, 'ForegroundColor', 'b');
    end
else
    set(handles.predictedidlbl, 'String', 'Tidak dikenali');
    if predicted == actual
        set(handles.predictedidlbl, 'ForegroundColor', 'r');
    else
        set(handles.predictedidlbl, 'ForegroundColor', 'b');
    end
end

imshow(reshape(pTrain(idxPredicted, :), [155 155]), [], 'Parent', handles.axes3);
imshow(reshape(vTrain(idxPredicted, :), [155 155]), [], 'Parent', handles.axes4);

function edit1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
