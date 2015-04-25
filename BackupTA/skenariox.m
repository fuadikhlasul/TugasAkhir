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

[eigvec, ~] = LPP(dPrintTrain, 1);
eigvec = flipud(eigvec);
printEig = eigvec;

printFea = dPrintTrain * printEig;
clear eigvec;

[eigvec, ~] = LPP(dVeinTrain, 1);
eigvec = flipud(eigvec);
veinEig = eigvec;
veinFea = dVeinTrain * veinEig;
clear eigvec;

param = 0.1:0.1:0.9;

finalAcc = [];
for pr = 1 : length(param)
    for rp = length(param) : -1 : 1
        disp(['Perbandingan: ', num2str(param(pr)), ':', num2str(param(rp))]);
        a = round(param(pr) * nTrain * 100);
        b = round(param(rp) * nTrain * 100);
        trainFea = [printFea(:, 1:a), veinFea(:, 1:b)];
        dimFea = size(trainFea, 2);
        cumAcc = 0;
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
                for kk = 1 : dimFea
                    dist = dist + (mData(:, kk) - vData(kk)).^2;
                end
                dist = (dist).^.5;
                
                tmp = find(dist == min(dist));
                actual = vLabel(jj);
                predicted = tLabel(tmp);
                correct = correct + (actual == predicted);
            end
            accuracy = accuracy + correct;
            cumAcc = cumAcc + accuracy;
        end
        finalAcc = [finalAcc, cumAcc/nTrain];
    end
end

pot();









