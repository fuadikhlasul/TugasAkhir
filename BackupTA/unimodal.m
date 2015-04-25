clc;
close all;
clear all;

nScenario = 6;

load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';

disp('Pengujian 2DLPP untuk vein Euclidean Distance');

% Nilai dari parameter jumlah dimensi fitur yang digunakan

truncation = [0.1 0.2 0.3 0.5];

% Melakukan percobaan sebanyak 6 skenario yang terdiri dari:
% Skenario 1 : 1 data train, 5 data testing
% Skenario 2 : 2 data train, 4 data testing
% Skenario 3 : 3 data train, 3 data testing
% Skenario 4 : 4 data train, 2 data testing
% Skenario 5 : 5 data train, 1 data testing
% Skenario 6 : 6 data train, 6 data testing

idxScenario = [];
accuracy = [];

for ii=1 : nScenario
%     disp(['Skenario-' num2str(ii)]);
    idxScenario = [idxScenario ii];
    [idTrain idTest] = generate_case(ii);
    
    dataTrain = data(idTrain, :);
    dataTest = data(idTest, :);
    
    dTrain = dataTrain(:, 1:end-1);
    
    for tt=1 : size(truncation, 2)
        disp(['Menggunakan jumlah fitur sejumlah ' num2str(truncation(tt)*100) '% dari total sampel (n = ' num2str(truncation(tt) * size(idTrain, 1)) ')']);
        [eigvec, ~] = LPP(dTrain, truncation(tt));
        
        dim = size(eigvec, 2);
        
        eigvec = flipud(eigvec);
        feature = eigvec(:, 1:dim);
        clear eigvec eigval
        
        projDTrain = dTrain * feature;
        correct = 0;
        
        for jj=1 : size(dataTest, 1)
            dTest = dataTest(jj, 1:end-1);
            projDTest = dTest * feature;
            dist = 0;
            for kk=1 : dim
                dist = dist + (projDTrain(:, kk) - projDTest(kk)).^2;
            end
            dist = (dist).^.5;
            tmp = find(dist == min(dist));
            actual = dataTest(jj, end);
            predicted = dataTrain(tmp, end);
            correct = correct + (predicted == actual);
        end
        
        accuracy(ii, tt) = correct / size(dataTest, 1) * 100;
        
        disp(['Akurasi : ' num2str(accuracy(ii, tt)) '%']);
    end
end

figure(1);
for aa=1 : size(truncation, 2)
    plot(idxScenario, accuracy(:, aa), 'LineWidth', 2);
    hold on;
end





