% Diavase thn eikona (grayscale) 
img = imread('normal40_var_refl.png'); 
 
% Adaptive threshold kai binarazation
T = adaptthresh(img, 0.49);
bw = imbinarize(img, T);

% Adjusting the binary image
se = strel("disk", 2);
bw = bwareaopen(bw,50);      % afairesi mikrou thorivou
bw = imclose(bw,se);         % kleisimo kenon
bw = imfill(bw,"holes");     % gemisma trupwn

% Transforiming the numbers for watershed
D = bwdist(~bw); 
D2 = imgaussfilt(D, 1); 
markers = imregionalmax(D2); 
markers = bwareaopen(markers, 10); 

% Watershed segmentation
D3 = imimposemin(-D2, markers); 
D3(~bw) = Inf;
L = watershed(D3); 

% Labeling
L(~bw) = 0; 
mask =  L > 0;
mask = bwareaopen(mask,20);
labels = bwlabel(mask);

% Properties
props = regionprops(labels, 'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength'); 
numCell = length(props); 
features = zeros(numCell, 4); % Area, Perimeter, Ratio, LabelID

for i = 1:numCell 
    area = props(i).Area; 
    perim = props(i).Perimeter; 
    ratio = props(i).MajorAxisLength / props(i).MinorAxisLength;

   features(i, :) = [area, perim, ratio, i]; % apothikeush sto pinaka 
end

% Plot results
figure; 
subplot(1,2,1); 
imshow(img); 
title('arxikh eikona');

subplot(1,2,2); 
imshow(label2rgb(labels)); 
title("eikona after segmentation kai labeling");

% Print properties
for i = 1:numCell 
    fprintf('Purhnas %d:\n', i); 
    fprintf(' Area: %.2f\n', features(i,1)); 
    fprintf(' Perimeter: %.2f\n', features(i,2)); 
    fprintf(' Major/Minor Axis Ratio: %.3f\n\n', features(i,3)); 
end
