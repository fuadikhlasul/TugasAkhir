function roi_ed(handles)

tic;

% clear all
% close all
% clc

global h w;

pathData    = 'dataset/';
dataUsed    = 'rotated/';
irCode      = {'460', '850'};
nSession    = 6;
nPerson     = 100;
handPart    = 'l';
bwth        = [0.1 0.2];
% savePath    = [pathData, 'roi_ed/vein/'];

ROIPoints = zeros(nSession*nPerson*2, 3);


for ir = 1 : length(irCode)
    
    for pp = 1 : nPerson
        
        personId = num2str(pp);
        
        if(size(personId, 2) == 1)
            personId = strcat('00', personId);
        else
            if(size(personId, 2) == 2)
                personId = strcat('0', personId);
            end
        end
        
        for ss = 1 : nSession
            
            sessionId = num2str(ss);
            sessionId = strcat('0', sessionId);
            fileName = strcat(personId, '_', handPart, '_', irCode{ir}, '_', sessionId);
            
            imOrig = ImageAcquisition(strcat(pathData, dataUsed, ...
                fileName, '.jpg'));
            
            % Parameters to be observed (image binarization technique, threshold value)
            
            imBW = im2bw(imOrig, bwth(ir));
            
            % Clean the binary palm image by removing pixels which has 10
            % percent (limit) from total dimension of image of pixel size.
            % Variable limit is the parameter to be observed in order to obtain
            % the best binary palm image
            
            cleanth = [0.05 0.1 0.15];
            imBW(h-120:h, :) = 0;
            imBW = bwareaopen(imBW, round(cleanth(1) * h * w));
            imBW = imfill(imBW, 8, 'holes');
            
            % Get the boundary of palm image using A - diff(A, SE)
            
            %         SE = [0 1 0; 1 1 1; 0 1 0];
            %         imEroded = imerode(imBW, SE);
            %         tempBoundary = imBW - imEroded;
            
            [bwBoundary, ~] = bwboundaries(double(imBW), 'noholes');
            bwBoundary = cell2mat(bwBoundary);
            
            % Get the centroid of an image
            
            [x, y] = find(imBW);
            centroid = [mean(x) mean(y)];
            
            % Get the bottom-most coordinate of palm image (closest to the wirst)
            
            [~, idMaxRow] = max(bwBoundary(:, 1));
            bwBoundary = cat(1, bwBoundary(idMaxRow:size(bwBoundary, 1), :), bwBoundary(1:idMaxRow-1, :));
            
            [initPoint, ~] = find(bwBoundary == min(bwBoundary(:, 2)));
            [termPoint, ~] = find(bwBoundary == max(bwBoundary(:, 2)));
            tracePoint = bwBoundary(initPoint(end):termPoint(end), :);
            ED = sqrt((tracePoint(:,1) - centroid(1)).^2 + (tracePoint(:,2) - centroid(2)).^2);
            ED1 = diff(ED);
            
            if size(tracePoint, 1) == 0
                continue;
            else
                smoothedED1 = fastsmooth(ED1, 50, 2, 0);
            end
            
            skip = 1;
            
            if strcmp(handPart, 'l')
                flag = 1;
            else
                flag = 4;
            end
            
            for kk=1 : size(smoothedED1, 1)-1
                prior = smoothedED1(kk);
                next = smoothedED1(kk+1);
                changeSign = ((prior * next) < 0) && (prior < next);
                if changeSign
                    if flag == skip
                        flag = 0;
                    else
                        ROIPoints((pp-1)*nSession+ss,skip) = tracePoint(kk, 1);
                        ROIPoints((pp-1)*nSession+ss+1,skip) = tracePoint(kk, 2);
                        skip = skip+1;
                    end
                end
            end
            
            width = (((ROIPoints((pp-1)*nSession+ss,1) - ROIPoints((pp-1)*nSession+ss,3)))^2+...
                ((ROIPoints((pp-1)*nSession+ss+1,3) - ROIPoints((pp-1)*nSession+ss+1,1)))^2)^0.5;
            height=width;
            
            degreeRef = (ROIPoints((pp-1)*nSession+ss,1) - ROIPoints((pp-1)*nSession+ss,3)) / ...
                (ROIPoints((pp-1)*nSession+ss+1,3) - ROIPoints((pp-1)*nSession+ss+1,1));
            
            theta = (360 / (2 * pi) * atan(degreeRef));
            
            imTemp = (imOrig) * 0;
            imTemp(ROIPoints((pp-1)*nSession+ss,1):ROIPoints((pp-1)*nSession+ss,1)+1, ...
                ROIPoints((pp-1)*nSession+ss+1,1):ROIPoints((pp-1)*nSession+ss+1,1)+1) ...
                = 150;
            imTemp(ROIPoints((pp-1)*nSession+ss,3):ROIPoints((pp-1)*nSession+ss,3)+1, ...
                ROIPoints((pp-1)*nSession+ss+1,3):ROIPoints((pp-1)*nSession+ss+1,3)+1) ...
                = 200;
            
            imRotated = imrotate(imOrig, -theta);
            imTempRotated = imrotate(imTemp, -theta);
            
            [row1, col1] = find(imTempRotated == 150);
            
            ROI = imcrop(imRotated, [col1(1)-10 row1(1)+30 width height]);
            
            figure(1);
            cf = gcf;
            set(cf, 'visible', 'off');
            hold off;
            imshow(imOrig, 'Parent', handles.axes1);
            %         subplot(221);
            plot(ED, 'Parent', handles.axes2);
            %         subplot(222);
            plot(ED1, 'Parent', handles.axes3);
            %         subplot(223);
            imshow(imOrig, 'Parent', handles.axes4);
            hold(handles.axes4, 'on');
            plot(centroid(2), centroid(1), 'r+', 'Parent', handles.axes4);
            hold(handles.axes4, 'on');
            plot(ROIPoints((pp-1)*nSession+ss+1,1), ROIPoints((pp-1)*nSession+ss,1), 'g*', 'Parent', handles.axes4);
            hold(handles.axes4, 'on');
            plot(ROIPoints((pp-1)*nSession+ss+1,3), ROIPoints((pp-1)*nSession+ss,3), 'g*', 'Parent', handles.axes4);
            %         subplot(224);
            imshow(ROI, 'Parent', handles.axes5);
            %
            %         gui = figure(1);
            %         saveas(gui, ['gui/roi_ed/', fileName, '.jpg']);
            hold on;
            
        end
        
    end
    
end