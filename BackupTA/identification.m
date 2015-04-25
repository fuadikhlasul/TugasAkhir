clc
clear all
close all

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
modelFea = [printFea, veinFea];
dimFea = size(modelFea, 2);
clear printFea veinFea

th = 295.2073;

far = 0;
frr = 0;

for dd = 1 : length(idTest)
    printTest = pTest(dd, :);
    veinTest = vTest(dd, :);
    testFea = [printTest * printEig, veinTest * veinEig];
    
    dist = 0;
    for ff = 1 : dimFea
        dist = dist + (modelFea(:, ff) - testFea(ff)).^2;
    end
    dist = (dist).^.5;
    
    idxPredict = find(dist == min(dist));
    predicted = trainLabel(idxPredict);
    actual = testLabel(dd);
    
    if min(dist) <= th
        far = far + (actual ~= predicted);
        if actual ~= predicted
%             idxPredict
%             dd
%             disp(['ID ', num2str(actual), ' recognized as ', num2str(predicted)]);
        end
    else
        frr = frr + (actual == predicted);
        if actual == predicted
            idxPredict
            dd
%             disp(['ID ', num2str(actual), ' recognized as ', num2str(predicted)]);
        end
    end
end

er = (far/300*100 + frr/300*100) / 2
rr = 100 - er













