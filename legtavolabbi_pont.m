clc; clear; close all;

filename = '';

% --- Beolvasás ---
I0 = imread(filename);
if size(I0,3) > 1, I = rgb2gray(I0); else, I = I0; end

figure('Name','Válassz nagyítandó területet');
imshow(I, []); title('Rajzolj téglalapot a kolóniák köré, majd dupla katt');
hRect = drawrectangle('StripeColor','y'); wait(hRect);
bbox = round(hRect.Position);
bbox(1) = max(1,bbox(1)); bbox(2) = max(1,bbox(2));
bbox(3) = min(bbox(3), size(I,2)-bbox(1)+1);
bbox(4) = min(bbox(4), size(I,1)-bbox(2)+1);

% --- Kivágás ---
Icrop_disp = imcrop(I, bbox);
Icrop      = imcrop(I,     bbox);

% --- Középpontok a NAGYÍTOTT képen ---
figure('Name','Középpontok (nagyított kép)');
imshow(Icrop_disp, []); title('Kattints a középpontokra (Enter a végén)');
[xc, yc] = ginput;
hold on; plot(xc, yc, 'ro', 'MarkerSize',8, 'LineWidth',1.5); hold off;

% ------------- KÜSZÖBÖLÉS -----------------
topHatRadius = 25;
IcropTop = imtophat(Icrop, strel('disk', topHatRadius));
sens = 0.45;
BWc = imbinarize(IcropTop, 'adaptive', 'Sensitivity', sens);
BWc = imclose(BWc, strel('disk', 2));
BWc = imfill(BWc, 'holes');
BWc = bwareaopen(BWc, 150);
BWc = imclearborder(BWc);           


% --- Legtávolabbi fehér pont (lokális kereséssel) ---
N = numel(xc);
farCrop = nan(N,2);
Rc      = nan(N,1);
tieCounts = zeros(N,1);             
farTies  = cell(N,1);                

searchRadius = 170;
[XX,YY] = meshgrid(1:size(BWc,2), 1:size(BWc,1));

for k = 1:N
    cx = round(xc(k)); cy = round(yc(k));

    % Kör alakú ROI a kereséshez
    ROI = (XX-cx).^2 + (YY-cy).^2 <= searchRadius^2;

    % Komponens kiválasztása CSAK az ROI-n belül
    BWlocal = BWc & ROI;
    comp = bwselect(BWlocal, cx, cy, 8);

    % Ha nem fehérre esett a kattintás, a legközelebbi fehér pixelt az ROI-n belül
    if ~any(comp(:))
        [rW,cW] = find(BWlocal);
        if isempty(rW), continue; end
        [~,iNear] = min((cW-cx).^2 + (rW-cy).^2);
        comp = bwselect(BWlocal, cW(iNear), rW(iNear), 8);
    end

    [rr,cc] = find(comp);
    if isempty(rr), continue; end

    % Négyzetes távolság
    d2 = (cc - xc(k)).^2 + (rr - yc(k)).^2;
    maxd2 = max(d2);
    idxAll = find(d2 == maxd2);          
    tieCounts(k) = numel(idxAll);

    % Válaszd az elsőt "fő" pontnak
    iMax = idxAll(1);
    farCrop(k,:) = [cc(iMax), rr(iMax)];
    Rc(k) = sqrt(double(maxd2));

    % Ha több azonos távolságú van, mentsd és jelezd
    if tieCounts(k) > 1
        farTies{k} = [cc(idxAll) rr(idxAll)];  
        fprintf(['Figyelmeztetés: a(z) %d. középponthoz %d azonos távolságú legtávolabbi pont van (R = %.1f px).\n'], k, tieCounts(k), Rc(k));
    end
end


fprintf('\n== Legtávolabbi pontok (crop-koordináták) ==\n');
for k = 1:N
    if isnan(Rc(k))
        fprintf('  #%d: NINCS találat\n', k);
    else
        fprintf('  #%d: center=(%.1f, %.1f), far=(%.1f, %.1f), R=%.1f px\n', ...
            k, xc(k), yc(k), farCrop(k,1), farCrop(k,2), Rc(k));
    end
end
fprintf('==============================================\n\n');

% --- Rajz ---
figure('Name','Legtávolabbi fehér pontok (nagyított kép)');
imshow(Icrop_disp, []); hold on;
plot(xc, yc, 'ro', 'MarkerSize',8, 'LineWidth',1.5);
plot(farCrop(:,1), farCrop(:,2), 'co', 'MarkerSize',6, 'LineWidth',1.5);
for k = 1:N
    if ~isnan(Rc(k))
        line([xc(k) farCrop(k,1)], [yc(k) farCrop(k,2)], 'Color','b', 'LineWidth',1.2);
        text(xc(k)+4, yc(k)-4, sprintf('R=%.1f', Rc(k)), 'Color','b', 'FontSize',9);
    end
end
Rc_valid = Rc(~isnan(Rc));
title(sprintf('Talált pontok: %d | Átlag R = %.1f px (nagyított kép)', ...
    numel(Rc_valid), mean(Rc_valid)));
legend({'Középpont','Legtávolabbi'}, 'Location','southoutside');
hold off;

