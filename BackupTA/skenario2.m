clc;
close all;
clear all;

nTrain = 6;
[idTrain idTest] = generate_case(nTrain);
param = [0.1:0.1:0.9];

load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';

dataTrain = data(idTrain, :);
dTrain = dataTrain(:, 1:end - 1);
clear data;

veinCumAcc = [];

for pp = 1 : length(param)
    [eigvec, ~] = LPP(dTrain, param(pp));
    dim = size(eigvec, 2);
    eigvec = flipud(eigvec);
    
    feature = eigvec(:, 1:dim);
    projData = dTrain * feature;
    clear eigvec eigval
    
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
    veinCumAcc = [veinCumAcc (accuracy/nTrain)];
end

load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';

dataTrain = data(idTrain, :);
dTrain = dataTrain(:, 1:end - 1);
clear data;

printCumAcc = [];

for pp = 1 : length(param)
    [eigvec, ~] = LPP(dTrain, param(pp));
    dim = size(eigvec, 2);
    eigvec = flipud(eigvec);
    
    feature = eigvec(:, 1:dim);
    projData = dTrain * feature;
    clear eigvec eigval
    
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
    printCumAcc = [printCumAcc (accuracy/nTrain)];
end

axis = 10:10:90;
figure(1);
plot(axis, veinCumAcc, ':kx', 'MarkerSize', 7);
hold on;
plot(axis, printCumAcc, '--ko', 'MarkerSize', 7);
xlabel('Panjang dimensi yang digunakan: (%) dari total panjang vektor ciri');
ylabel('Akurasi (%)');
legend('Palmvein','Palmprint','Location','SouthEast');
ylim([80 100]);


















