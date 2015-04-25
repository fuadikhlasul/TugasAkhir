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
trainFea = [printFea, veinFea];
dimFea = size(trainFea, 2);
clear printFea veinFea

th = 295.2073;

rejected = 0;

for dd = 1 : 100
    idperson = find(trainLabel == dd);
    vein = vTest(idperson, :);
    print = pTest(idperson, :);
    modelFea = trainFea(idperson, :);
    
    for pp = 1 : length(idperson)
        printTest = print(pp, :);
        veinTest = vein(pp, :);
        testFea = [printTest * printEig, veinTest * veinEig];
        
        dist = 0;
        for ff = 1 : dimFea
            dist = dist + (modelFea(:, ff) - testFea(ff)).^2;
        end
        dist = (dist).^.5;
        
        min(dist)
        if min(dist) <= th
            disp(['ID ', num2str(dd), ' : accepted']);
        else
            disp(['ID ', num2str(dd), ' : rejected']);
            rejected = rejected + 1;
        end
    end
end
rejected

er = rejected/300 * 100
rr = 100 - er


