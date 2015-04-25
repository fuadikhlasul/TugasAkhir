clc;
clear all;
close all;

load 'D:/Tugas Akhir/v1/dataset/multi_feature_conf33_chvd.mat';
load 'thresh_array.mat';
load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
printData = data;
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
veinData = data;
clear data;

[idTrain, idTest] = generate_case(3);

printTrain = printData(idTrain, 1:end-1);
printTest = printData(idTest, 1:end-1);
veinTest = veinData(idTest, 1:end-1);
veinTrain = veinData(idTrain, 1:end-1);

trainLabel = veinData(idTrain, end);
testLabel = veinData(idTest, end);
clear printData veinData;

feaModel = [printTrain * printEig, veinTrain * veinEig];
dimFea = size(feaModel, 2);

% ===================================================
% Konfigurasi threshold untuk menghitung FAR dan FRR
% ===================================================

minta = min(min(ta));
maxta = max(max(ta));
gta = 50;
delta = (maxta - minta) / gta;
const = 1:1:gta;
FAR = [];
FRR = [];

for tt = 1 : length(const)
    
    th = minta + const(tt) * delta;
    
    far = 0;
    frr = 0;
    th
    for ii = 1 : length(idTest)
        pTest = printTest(ii, :);
        vTest = veinTest(ii, :);
        printFea = pTest * printEig;
        veinFea = vTest * veinEig;
        feaTest = [printFea, veinFea];
        
        dist = 0;
        for jj = 1 : dimFea
            dist = dist + (feaModel(:, jj) - feaTest(jj)).^2;
        end
        dist = (dist).^.5;
        
        idx = find(dist == min(dist));
        actual = testLabel(ii);
        predicted = trainLabel(idx);
        
        if min(dist) < th
            far = far + (actual ~= predicted);
            if actual ~= predicted
%                 disp(['(False Accept) : Orang dengan ID ', num2str(actual), ' salah dikenali sebagai orang dengan ID ', num2str(predicted)]);
            end
        else
            frr = frr + (actual == predicted);
            if actual == predicted
%                 disp(['(False Reject) : Orang dengan ID ', num2str(actual), ' salah dikenali sebagai orang dengan ID ', num2str(predicted)]);
            end
        end
    end
    far/length(idTest)
    frr/length(idTest)
    FAR = [FAR, far/length(idTest)];
    FRR = [FRR, frr/length(idTest)];
end

threshold = const * delta + minta;
figure(1);
plot(threshold(1:10), FAR(1:10), '--k^', 'MarkerSize', 5);
hold on;
plot(threshold(1:10), FRR(1:10), '--ks', 'MarkerSize', 5); 
ylim([0 0.3]);
ylabel('FAR/FRR');
xlabel('Threshold');
legend('FAR','FRR');

figure(2);
plot(FAR, 1-FRR, '--ks', 'Color', 'b', 'LineWidth', 2);
ylim([0 1]);
ylabel('1-FRR (GAR)');
xlabel('FAR');



