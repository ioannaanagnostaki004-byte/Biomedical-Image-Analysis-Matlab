% Ρυθμίσεις Φακέλων 
imageFolder = '.\Images';       
textFolder  = '.\Ground Truth'; 

% Χρησιμοποιούμε το feature_mask.png για πιο αξιόπιστα αποτελέσματα
maskFilename = 'feature_mask.png'; 
maskPath = fullfile(imageFolder, maskFilename);

% Έλεγχος αν υπάρχει η μάσκα
if isfile(maskPath)
    ROI_Mask = imread(maskPath);
    % Μετατροπή σε logical (binary) αν δεν είναι ήδη
    if size(ROI_Mask,3) == 3, ROI_Mask = rgb2gray(ROI_Mask); end
    ROI_Mask = logical(ROI_Mask > 0);
    fprintf('Η μάσκα %s φορτώθηκε επιτυχώς.\n', maskFilename);
else
    warning('Δεν βρέθηκε αρχείο μάσκας. Θα γίνει χρήση thresholding.');
    ROI_Mask = []; % Κενό για να ξέρουμε να κάνουμε fallback
end

% 1. Βρίσκουμε όλες τις "Εικόνες 1" 
% Χρησιμοποιούμε fullfile για σωστή διαχείριση φακέλων σε Windows
refFiles = dir(fullfile(imageFolder, '*_1.jpg'));

if isempty(refFiles)
    error('Δεν βρέθηκαν αρχεία που να λήγουν σε _1.jpg στον φάκελο Images.');
end

fprintf('Βρέθηκαν %d ζεύγη εικόνων προς επεξεργασία.\n', length(refFiles));

% Πίνακας για αποθήκευση αποτελεσμάτων
resultsTable = {}; 

% Επεξεργασία για τα πρώτα 10 ζεύγη 
numPairs = min(length(refFiles), 10);

for k = 1:numPairs
    % Βήμα 1: Κατασκευή Ονομάτων Αρχείων 
    
    % Όνομα αρχείου 1: 
    filename1 = refFiles(k).name;
    
    % Εξάγουμε το ID. Αντικαθιστούμε το "_1.jpg" με κενό.
    pairID = strrep(filename1, '_1.jpg', ''); 
    
    % Κατασκευάζουμε το όνομα της 2ης εικόνας: "A01" + "_2.jpg" -> "A01_2.jpg"
    filename2 = [pairID, '_2.jpg'];
    
    % Κατασκευάζουμε το όνομα του txt: "control_points_" + "A01" + "_1_2.txt"
    txtFilename = ['control_points_', pairID, '_1_2.txt'];
    
    % Debugging: Εκτύπωση για έλεγχο
    fprintf('\nΕπεξεργασία Ζεύγους %d (%s)\n', k, pairID);
    fprintf('Διαβάζω Image 1: %s\n', filename1);
    fprintf('Διαβάζω Image 2: %s\n', filename2);
    fprintf('Διαβάζω Points : %s\n', txtFilename);
    
    % Βήμα 2: Έλεγχος αν υπάρχουν τα αρχεία 
    path1 = fullfile(imageFolder, filename1);
    path2 = fullfile(imageFolder, filename2);
    pathTxt = fullfile(textFolder, txtFilename);
    
    if ~isfile(path2)
        fprintf(2, 'ΣΦΑΛΜΑ: Δεν βρέθηκε η εικόνα %s\n', filename2); continue;
    end
    if ~isfile(pathTxt)
        fprintf(2, 'ΣΦΑΛΜΑ: Δεν βρέθηκε το αρχείο %s\n', txtFilename); continue;
    end
    
    % Βήμα 3: Φόρτωση Δεδομένων 
    img1 = imread(path1);
    img2 = imread(path2);
    
    % Διάβασμα σημείων από το txt
    fileID = fopen(pathTxt, 'r');
    % Διαβάζουμε 4 floats ανά γραμμή: Ref_X, Ref_Y, Test_X, Test_Y
    data = fscanf(fileID, '%f %f %f %f', [4, inf])';
    fclose(fileID);
    
    fixedPoints  = data(:, 1:2); % Στήλες 1-2 (Εικόνα 1)
    movingPoints = data(:, 3:4); % Στήλες 3-4 (Εικόνα 2)
    
    % 2: Fusion ΠΡΙΝ την ευθυγράμμιση 
    % Εδώ γίνεται το Fusion των 2 εικόνων του συγκεκριμένου ζεύγους
    figure('Name', ['Pair ', pairID]);
    subplot(2, 2, 1);
    imshow(imfuse(img1, img2, 'blend')); 
    title('Fusion Πριν');
    
    % 4 & 5: Υπολογισμός Affine & Εφαρμογή 
    try
        % Υπολογισμός affine
        tform = fitgeotrans(movingPoints, fixedPoints, 'affine');
        
        % Εφαρμογή στην εικόνα 2
        outputView = imref2d(size(img1));
        alignedImg = imwarp(img2, tform, 'OutputView', outputView);
        
        % Μετασχηματισμός ΚΑΙ της Μάσκας
        if ~isempty(ROI_Mask)
            mask2_warped = imwarp(ROI_Mask, tform, 'OutputView', outputView);
        else
            mask2_warped = [];
        end

        % Εμφάνιση αποτελέσματος Fusion ΜΕΤΑ
        subplot(2, 2, 2);
        imshow(imfuse(img1, alignedImg, 'blend'));
        title('Fusion Μετά (After)');
        
        % Εμφάνιση ξεχωριστών εικόνων
        subplot(2, 2, 3); imshow(img1); 
        title(['Original ', pairID, '_1']);
        subplot(2, 2, 4); imshow(alignedImg); 
        title(['Aligned ', pairID, '_2']);
        
        % 6: Μετρικές (Χωρίς μαύρα pixels) 
        % Μετατροπή σε Grayscale μόνο για τους υπολογισμούς
        if size(img1,3)==3, g1=rgb2gray(img1); else, g1=img1; end
        if size(img2,3)==3, g2=rgb2gray(img2); else, g2=img2; end
        if size(alignedImg,3)==3, gAligned=rgb2gray(alignedImg); else, gAligned=alignedImg; end
        
        % Πριν την ευθυγράμμιση: Η μάσκα είναι ίδια και στις δύο θέσεις
        [ccPre, miPre] = calcMetricsWithMask(g1, g2, ROI_Mask, ROI_Mask);
        
        % Μετά την ευθυγράμμιση: Η μάσκα 2 έχει στρίψει (mask2_warped)
        [ccPost, miPost] = calcMetricsWithMask(g1, gAligned, ROI_Mask, mask2_warped);
        
        % Αποθήκευση στον πίνακα
        tformStr = mat2str(round(tform.T, 2));
        resultsTable(end+1, :) = {pairID, tformStr, miPre, miPost, ccPre, ccPost};
        
    catch ME
        fprintf(2, 'Πρόβλημα στον υπολογισμό Affine για το %s: %s\n', pairID, ME.message);
    end
end

% Εκτύπωση Τελικού Πίνακα 
if ~isempty(resultsTable)
    fprintf('\n\n=========================================================================================\n');
    fprintf('%-10s | %-25s | %-8s | %-8s | %-8s | %-8s\n', 'Ζεύγος', 'Πίνακας (T)', 'MI Pre', 'MI Post', 'CC Pre', 'CC Post');
    fprintf('-----------------------------------------------------------------------------------------\n');
    for i = 1:size(resultsTable, 1)
        fprintf('%-10s | %-25s | %-8.4f | %-8.4f | %-8.4f | %-8.4f\n', ...
            resultsTable{i,1}, resultsTable{i,2}, resultsTable{i,3}, resultsTable{i,4}, resultsTable{i,5}, resultsTable{i,6});
    end
    fprintf('=========================================================================================\n');
end

% Συνάρτηση Μετρικών 
function [cc, mi] = calcMetricsWithMask(img1, img2, mask1, mask2)
    I1 = double(img1);
    I2 = double(img2);
    
    % Δημιουργία Κοινής Μάσκας (Intersection)
    if ~isempty(mask1) && ~isempty(mask2)
        % Κρατάμε pixels που είναι Valid ΚΑΙ στην 1 ΚΑΙ στην 2
        finalMask = mask1 & mask2;
    else
        % Fallback αν δεν βρέθηκε αρχείο μάσκας: αγνοούμε το μαύρο (0)
        finalMask = (I1 > 1) & (I2 > 1);
    end
    
    % Εφαρμογή μάσκας
    p1 = I1(finalMask);
    p2 = I2(finalMask);
    
    if isempty(p1), cc=0; mi=0; return; end
    
    % Correlation Coefficient
    c = corrcoef(p1, p2); 
    if numel(c)>1, cc = c(1,2); else, cc=0; end
    
    % Mutual Information
    edges = -0.5:255.5;
    h1 = histcounts(p1, edges, 'Normalization', 'probability');
    h2 = histcounts(p2, edges, 'Normalization', 'probability');
    hJ = histcounts2(p1, p2, edges, edges, 'Normalization', 'probability');
    
    nz = hJ > 0;
    pj = hJ(nz);
    [r, c_idx] = find(nz);
    
    mi = sum(pj .* log2(pj ./ (h1(r).' .* h2(c_idx).')));
end