function [idxTrain, idxTest] = generateCase(nTrain)

nPerson = 100;
nSession = 6;

idTrain = [];
idTest = [];

if nTrain == 1
    for ii = 1 : nPerson * nSession
        if mod(ii, nSession) == 0
            idTrain = [idTrain; ii];
        else
            idTest = [idTest; ii];
        end
    end
elseif nTrain == 2
    for ii = 1 : nSession : nPerson * nSession
        arrIdx = ii:1:ii+nSession-1;
        medIdx = floor(median(arrIdx));
        idTrain = [idTrain; [medIdx; medIdx+1]];
        idTest = [idTest; setdiff(arrIdx', [medIdx medIdx+1]')];
    end    
elseif nTrain == 3
    for ii = 1 : nPerson * nSession
        if mod(ii, 2) ~= 0
            idTrain = [idTrain; ii];
        else
            idTest = [idTest; ii];
        end
    end
elseif nTrain == 4
    for ii = 1 : nSession : nPerson * nSession
        arrIdx = ii:1:ii+nSession-1;
        medIdx = floor(median(arrIdx));
        idTest = [idTest; [medIdx; medIdx+1]];
        idTrain = [idTrain; setdiff(arrIdx', [medIdx medIdx+1]')];
    end
elseif nTrain == 5
    for ii = 1 : nPerson * nSession
        if mod(ii, nSession) == 0
            idTest = [idTest; ii];
        else
            idTrain = [idTrain; ii];
        end
    end
elseif nTrain == 6
    idTrain = (1:1:600)';
    idTest = idTrain;
end

idxTrain = idTrain;
idxTest = idTest;



