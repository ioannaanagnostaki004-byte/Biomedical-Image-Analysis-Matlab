%1.2 Ορισμός της path
rootFolder = 'C:\Users\ioann\OneDrive\Υπολογιστής\101_ObjectCategories';
%/content/drive/MyDrive/Colab Notebooks/101_ObjectCategories
imds = imageDatastore(rootFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

%7: Επιλογή 50 κλάσεων 
% allCats = categories(imds.Labels);
% subCats = allCats(1:50); 
% imds = subset(imds, ismember(imds.Labels, subCats));
% imds.Labels = removecats(imds.Labels); 

labelCount = countEachLabel(imds);
disp(labelCount);

%3
splitMethod = 'A';
if splitMethod == 'A'
    % Τρόπος 3α: 70% Train - 30% 
    [imdsTrain, imdsTest] = splitEachLabel(imds, 0.7, 'randomized');
fprintf('Επιλέχθηκε ο Τρόπος Α (70/30 split).\n');
else
    % Τρόπος 3β: Σταθερός αριθμός 
    numTrainFiles = 30; 
    [imdsTrain, imdsTest] = splitEachLabel(imds, numTrainFiles, 'randomized');
    fprintf('Επιλέχθηκε ο Τρόπος Β (%d εικόνες ανά κλάση).\n', numTrainFiles);
end

numClasses = numel(categories(imdsTrain.Labels));

%4
x = 8;
y = 32;

%Pretrained AlexNet

netAlex = imagePretrainedNetwork("alexnet", NumClasses=numClasses);

augImdsTrainA = augmentedImageDatastore([227 227], imdsTrain, 'ColorPreprocessing', 'gray2rgb');
augImdsTestA = augmentedImageDatastore([227 227], imdsTest, 'ColorPreprocessing', 'gray2rgb');

optionsA = trainingOptions("sgdm", ...
    "InitialLearnRate", 1e-4, ...
    "LearnRateSchedule", "piecewise", ...
    "LearnRateDropFactor", 0.2, ...
    "LearnRateDropPeriod", 5, ...
    "MaxEpochs", x, ...                % Εδώ είναι το numEpochs
    "MiniBatchSize", y, ...            % Εδώ είναι το batchSize
    "ValidationData", augImdsTestA, ... % <--- ΕΔΩ ΒΑΖΕΙΣ ΤΟ TEST SET
    "ValidationFrequency", 30, ...      % Κάθε πόσα βήματα να ελέγχει (π.χ. κάθε 30 iterations)
    "Plots", "training-progress");

%5 
trainedNetAlex = trainnet(augImdsTrainA, netAlex, "crossentropy", optionsA);

fprintf('Υπολογισμός προβλέψεων... παρακαλώ περιμένετε.\n');
scoresA = minibatchpredict(trainedNetAlex, augImdsTestA);

classNames = categories(imdsTrain.Labels);
YPredA = scores2label(scoresA, classNames);
YTestA = imdsTestA.Labels;

accuracy = mean(YPredA == YTestA);
fprintf('Η ακρίβεια του AlexNet στο Test Set είναι: %.2f%%\n', accuracy*100);

figure('Name', 'AlexNet Results')
confusionchart(YTestA, YPredA, 'Title', ['Confusion Matrix - AlexNet (Accuracy: ', num2str(accuracy*100, '%.2f'), '%)'], ...
    'ColumnSummary', 'column-normalized','RowSummary', 'row-normalized');

%Pretraind VGG16
augImdsTrainVGG = augmentedImageDatastore([224 224], imdsTrain, 'ColorPreprocessing', 'gray2rgb');
augImdsTestVGG = augmentedImageDatastore([224 224], imdsTest, 'ColorPreprocessing', 'gray2rgb');

netVGG = imagePretrainedNetwork("vgg16", NumClasses=numClasses);

optionsVGG  = trainingOptions("sgdm", ...
    "InitialLearnRate", 1e-4, ...
    "LearnRateSchedule", "piecewise", ...
    "LearnRateDropFactor", 0.2, ...
    "LearnRateDropPeriod", 5, ...
    "MaxEpochs", x, ...               
    "MiniBatchSize", y, ...            
    "ValidationData", augImdsTestVGG, ... 
    "ValidationFrequency", 30, ...      
    "Plots", "training-progress");

trainedNetVGG = trainnet(augImdsTrainVGG, netVGG, "crossentropy", optionsVGG);

%5
fprintf('Υπολογισμός προβλέψεων... παρακαλώ περιμένετε.\n');
scoresVGG = minibatchpredict(trainedNetAlex, augImdsTestA);

classNames = categories(imdsTrain.Labels);
YPredVGG = scores2label(scoresVGG, classNames);
YTestVGG = imdsTest.Labels;

accuracy = mean(YPredVGG == YTestVGG);
fprintf('Η ακρίβεια του VGG16 στο Test Set είναι: %.2f%%\n', accuracy*100);

figure('Name', 'VGG16 Results')
confusionchart(YTestVGG, YPredVGG, 'Title', ['Confusion Matrix - VGG16 (Accuracy: ', num2str(accuracy*100, '%.2f'), '%)'], ...
    'ColumnSummary', 'column-normalized', 'RowSummary', 'row-normalized');