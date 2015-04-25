clc;
clear all;
close all;

load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
print = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
vein = data;

nTrain = 6;

cd('D:/Tugas Akhir/v1/');
[idTrain idTest] = generate_case(nTrain);
trainLabel = data(idTrain, end);
testLabel = data(idTest, end);
clear data;

dPrintTrain = print(idTrain, 1:end-1);
dVeinTrain = vein(idTrain, 1:end-1);
dPrintTest = print(idTest, 1:end-1);
dVeinTest = vein(idTest, 1:end-1);

clear print vein nTrain idTrain idTest;

[eigvec, ~] = LPP(dPrintTrain, 0.8);
eigvec = flipud(eigvec);
printEig = eigvec;
printFea = dPrintTrain * printEig;
clear eigvec;

[eigvec, ~] = LPP(dVeinTrain, 0.6);
eigvec = flipud(eigvec);
veinEig = eigvec;
veinFea = dVeinTrain * veinEig;
clear eigvec;

trainFea = [printFea, veinFea];
dimFea = size(trainFea, 2);

clear printFea veinFea;

correct = 0;
for ii=1 : length(testLabel)
    pTest = dPrintTest(ii, :);
    vTest = dVeinTest(ii, :);
    testFea = [pTest * printEig, vTest * veinEig];
    dist = 0;
    
    for jj=1 : dimFea
        dist = dist + (trainFea(:, jj) - testFea(jj)).^2;
    end
    
    dist = (dist).^.5;
    idx = find(dist == min(dist));
    actual = testLabel(ii);
    predicted = trainLabel(idx);
    
    correct = correct + (actual == predicted);
end

disp(['akurasi : ' num2str(correct / length(testLabel) * 100) '%']);








