clc;
clear all;
close all;

[idTrain, ~] = generate_case(6);
load 'D:/Tugas Akhir/v1/dataset/print_chvd.mat';
print = data(idTrain, 1:end-1);
clear data;
load 'D:/Tugas Akhir/v1/dataset/vein_chvd.mat';
vein = data(idTrain, 1:end-1);
clear data;
[printEig, ~] = LPP(print, 0.1);
[veinEig, ~] = LPP(vein, 0.7);
printEig = flipud(printEig);
veinEig = flipud(veinEig);
save('dataset/multi_feature_conf6_chvd.mat', 'printEig', 'veinEig');