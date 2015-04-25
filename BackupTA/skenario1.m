clc;
close all;
clear all;

load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';

nTrain = 6;
[idTrain idTest] = generate_case(nTrain);

dataTrain = data(idTrain, :);
dTrain = dataTrain(:, 1:end - 1);

[eigvec, ~] = LPP(dTrain, 1);
dim = size(eigvec, 2);
eigvec = flipud(eigvec);

feature = eigvec(:, 1:dim);
projData = dTrain * feature;
clear eigvec eigval dTrain data

accuracy = 0;

for ii = 1 : nTrain
    
    idx = 1:1:nTrain*100;
    
    if ii ~= nTrain
        vid = find(mod(idx, nTrain) == ii);
    else
        vid = find(mod(idx, nTrain) == 0);
    end
    
    valData = projData(vid, :);
    vLabel = dataTrain(vid, end);
    
    tid = setdiff(idx, vid);
    mData = projData(tid, :);
    tLabel = dataTrain(tid, end);
    
    clear idx
    
    correct = 0;
    for jj = 1 : length(vid)
        vData = valData(jj, :);
        
        dist = 0;
        for kk = 1 : dim
            dist = dist + (mData(:, kk) - vData(kk)).^2;
        end
        dist = (dist).^.5;
        
        tmp = find(dist == min(dist));
        actual = vLabel(jj);
        predicted = tLabel(tmp);
        correct = correct + (actual == predicted);
    end
    accuracy = accuracy + (correct/length(vid)*100);
end

accuracy/nTrain
