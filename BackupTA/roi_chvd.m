function roi_chvd(handles)

tic;

% clear all
% close all
% clc

start =  datestr(now);

global h w;

pathData    = 'dataset/';
dataUsed    = 'rotated/';
irCode      = {'460', '850'};
nSession    = 6;
nPerson     = 100;
handPart    = 'l';

pId = 1;
extremePoints = [];
features = [];

bwth    = [0.1, 0.2];
cleanth = 0.1;
bt      = 0.05;

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
            
            I = ImageAcquisition(strcat(pathData, dataUsed, ...
                fileName, '.jpg'));
            %         I = uint8(filter2(fspecial('average', 3), I));
            Ibw = im2bw(I, bwth(ir));
            %         Ibw = medfilt2(Ibw);
            
            limit = round(cleanth * h * w);
            Ibw(h-150:h, :) = 0;
            Ibw = bwareaopen(Ibw, limit);
            Ibw = imfill(Ibw, 8, 'holes');
            
            figure(1);
            cf = gcf;
            set(cf, 'visible', 'off');
            hold off;
            imshow(I, 'Parent', handles.axes1);
%             subplot(221);
            imshow(Ibw, 'Parent', handles.axes2);
            
            bwBoundaries= bwboundaries(Ibw, 'noholes');
            C = cell2mat(bwBoundaries);
            [maxrow, idmaxrow] = max(C(:, 1));
            [hc, wc] = size(C);
            C = cat(1, C(idmaxrow:hc, :), C(1:idmaxrow-1, :));
            
            %         kernel = [-1 -1 -1 0 1 1 1];
            kernel = [-1 -1.5 -2 0 2 1.5 1];
            
            newC = conv(double(C(:, 1)), kernel, 'same');
            hnewc = size(newC, 1);
            
            sign = newC(4) < 0;
            currentSign = sign;
            changeSign = [];
            idxsign = 1;
            count = bt * hnewc;
            
            for kk = 5 : hnewc
                count = count + 1;
                if(newC(kk) ~= 0)
                    currentSign = newC(kk) < 0;
                end
                if(currentSign ~= sign)
                    if(count > (bt(idxsign) * w))
                        columnLocation = C(kk, 2);
                        changeSign = [changeSign kk];
                        count = 0;
                        sign = ~sign;
                    end
                end
            end
            
            signCoord = C(changeSign(:), :);
            %         signCoord = flipud(signCoord);
            
            hold(handles.axes2, 'on');
            plot(signCoord(:, 2), signCoord(:, 1), 'r.', 'Parent', handles.axes2);
            
            temp = [];
            radius = 20;
            
            for check = 1 : size(signCoord, 1)
                point = signCoord(check, :);
                
                row = point(1);
                col = point(2);
                
                left = col - radius;
                right = col + radius;
                bottom = row + radius;
                
                if(left <= 0)
                    left = 1;
                end
                
                if(right > w)
                    right = w;
                end
                
                if((Ibw(row, left) == 1) && (Ibw(row, right) == 1) && ...
                        (Ibw(bottom, col) == 1))
                    temp = [temp; point];
                    if((Ibw(row, left) == 1) && (Ibw(bottom, col) == 1))
                        checkAgain1 = row - radius;
                        checkAgain2 = col + radius;
                        if(Ibw(checkAgain1, checkAgain2) == 1)
                            temp = [temp; point];
                        end
                    end
                end
            end
            
            hold(handles.axes2, 'on');
            plot(temp(:,2), temp(:,1), 'go', 'Parent', handles.axes2);
            
            if(size(temp, 1) < 4)
                temp = [temp; 1000 1000];
            else if(size(temp, 1) > 4)
                    minDist = 100;
                    thDist = 20;
                    temp1 = [];
                    temp2 = [];
                    forb = [];
                    ct = 0;
                    for ii=1 : size(temp, 1)-1
                        ct = 0;
                        temp2 = [];
                        if isempty(find(forb == ii))
                            for jj=ii+1 : size(temp, 1)
                                p1 = CekPosBorder(temp(ii, 1), temp(ii, 2), C);
                                p2 = CekPosBorder(temp(jj, 1), temp(jj, 2), C);
                                dist = abs(p1 - p2);
                                if dist < minDist
                                    newP(1, 1) = round((temp(ii, 1) + temp(jj, 1)) / 2);
                                    newP(1, 2) = round((temp(ii, 2) + temp(jj, 2)) / 2);
                                    temp2 = [temp2; newP];
                                    ct = ct + 1;
                                    forb = [forb; ii, jj];
                                else
                                    dist = ((temp(ii, 1) - temp(jj, 1))^2 + (temp(ii, 2) - temp(jj, 2))^2)^0.5;
                                    if dist < thDist
                                        newP(1, 1) = round((temp(ii, 1) + temp(jj, 1)) / 2);
                                        newP(1, 2) = round((temp(ii, 2) + temp(jj, 2)) / 2);
                                        temp2 = [temp2; newP];
                                        ct = ct + 1;
                                        forb = [forb; ii, jj];
                                    end
                                end
                            end
                            if ct == 0
                                temp1 = [temp1; temp(ii, 1) temp(ii, 2)];
                            else
                                temp1=[temp1; round(mean(temp2(:, 1))) round(mean(temp2(:, 2)))];
                            end
                        end
                    end
                    if isempty(find(forb == ii + 1))
                        temp1 = [temp1; temp(ii+1, 1) temp(ii+1, 2)];
                    end
                    
                    if size(temp1, 1) < 4
                        temp1(4, :) = [1000 1000];
                    end
                    
                    temp = temp1(1:4, :);
                end
            end
            
            %     temp=flipud(temp);
            
            hold(handles.axes2, 'on');
            plot(temp(:,2), temp(:,1), 'b+', 'Parent', handles.axes2);
            
            extremePoints = [extremePoints; temp'];
            borderArea = extremePoints(pId:pId+1, :)';
            bArea = cat(2, borderArea(:, 2), borderArea(:, 1));
            
%             subplot(222);
            imshow(I, 'Parent', handles.axes3);
            hold(handles.axes3, 'on');
            plot(bArea(:, 1), bArea(:, 2), 'r.', 'Parent', handles.axes3);
            
            if (borderArea(1, 1) == 1000) && (borderArea(1, 2) == 1000)
                width = (((borderArea(2, 1) - borderArea(4, 1)))^2+...
                    ((borderArea(4, 2) - borderArea(2, 2)))^2)^0.5;
                height=width;
            else
                height = (((borderArea(2, 1) - borderArea(1, 1)))^2+...
                    ((borderArea(1, 2) - borderArea(2, 2)))^2)^0.5;
                width = (((borderArea(2, 1)  -borderArea(4, 1)))^2+...
                    ((borderArea(4, 2) - borderArea(2, 2)))^2)^0.5;
            end
            
            ref = (borderArea(2,1)-borderArea(4,1))/...
                (borderArea(4,2)-borderArea(2,2));
            
            
            theta = (360 / (2*pi) * atan(ref));
            Itemp = (Ibw) * 0;
            Itemp(borderArea(2, 1):borderArea(2, 1) + 2,...
                borderArea(2, 2):borderArea(2, 2) + 2) = 150;
            Itemp(borderArea(4, 1), borderArea(4, 2)) = 200;
            IRot = imrotate(I, -theta);
            IRotTemp = imrotate(Itemp, -theta);
            
            [row4, col4] = find(IRotTemp == 150);
            [row8, col8] = find(IRotTemp == 200);
            
            ROI = imcrop(IRot,[col4(1) row4(1) width height]);
            
%             subplot(223);
            imshow(IRot, 'Parent', handles.axes4);
            hold(handles.axes4, 'on');
            plot(col4, row4, 'r.', 'Parent', handles.axes4);
            plot(col8, row8, 'r.', 'Parent', handles.axes4);
%             subplot(224);
            imshow(ROI, 'Parent', handles.axes5);
            
            pId = pId + 2;
            
%             h = figure(1);
            %     saveas(h, ['GUI/ROI/', fileName, '.jpg']);
            hold on;
            
        end
        
    end
    
end

toc;








