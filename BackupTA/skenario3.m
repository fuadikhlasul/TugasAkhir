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

clear print vein idTrain idTest;

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
dimPrintFea = size(printFea, 2);
dimVeinFea = size(veinFea, 2);

dimFea = size(trainFea, 2);

clear printFea veinFea;

cumAcc = 0;

alpha = 0;

for ii = 1 : nTrain
    
    idx = 1:1:nTrain*100;
    
    if ii ~= nTrain
        vid = find(mod(idx, nTrain) == ii);
    else
        vid = find(mod(idx, nTrain) == 0);
    end
    
    valData = trainFea(vid, :);
    vLabel = trainLabel(vid, end);
    
    tid = setdiff(idx, vid);
    mData = trainFea(tid, :);
    tLabel = trainLabel(tid);
    
    clear idx
    
    accuracy = 0;
    correct = 0;
    
    for jj = 1 : length(vid)
        vData = valData(jj, :);
        
        dist = 0;
        
        printDist = 0;
        for kk = 1 : dimPrintFea
            printDist = printDist + (mData(:, kk) - vData(kk)).^2;
        end
        printDist = (printDist).^.5;
        printDist = printDist .* alpha;
        
        veinDist = 0;
        for kk = dimPrintFea + 1 : dimFea
            veinDist = veinDist + (mData(:, kk) - vData(kk)).^2;
        end
        veinDist = (veinDist).^.5;
        veinDist = veinDist .* (1 - alpha);
        
        dist = printDist + veinDist;
        
        tmp = find(dist == min(dist));
        actual = vLabel(jj);
        predicted = tLabel(tmp);
        if predicted ~= actual
            disp(['actual : ', num2str(actual), ' - predicted : ', num2str(predicted)]);
        end
        correct = correct + (actual == predicted);
    end
    
    accuracy = accuracy + correct;
    cumAcc = cumAcc + accuracy;
%     accuracy
end
cumAcc/nTrain








