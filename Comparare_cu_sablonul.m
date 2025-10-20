% 1. Pregătirea datelor pentru antrenare (autentic și falsificat)
labels = [ones(size(authFeatures, 1), 1); -ones(size(fakeFeatures, 1), 1)]; % 1 - autentic, -1 - falsificat
allFeatures = [authFeatures; fakeFeatures]; % Combina caracteristicile

% 2. Împărțirea datelor în seturi de antrenament și testare
cv = cvpartition(length(labels), 'HoldOut', 0.2); % 80% antrenament, 20% testare
XTrain = allFeatures(training(cv), :); % Datele de antrenament
YTrain = labels(training(cv)); % Etichetele pentru antrenament
XTest = allFeatures(test(cv), :); % Datele de testare
YTest = labels(test(cv)); % Etichetele pentru testare

% 3. Antrenarea unui model SVM
disp('Antrenăm modelul SVM...');
svmModel = fitcsvm(XTrain, YTrain, 'KernelFunction', 'linear', 'Standardize', true);

% 4. Testarea modelului pe setul de testare
disp('Testăm modelul...');
YPred = predict(svmModel, XTest);

% 5. Calcularea acurateței
accuracy = sum(YPred == YTest) / length(YTest) * 100;
disp(['Acuratețea modelului: ', num2str(accuracy), '%']);

% 6. Afișarea unor rezultate
confMatrix = confusionmat(YTest, YPred);
disp('Matricea de confuzie:');
disp(confMatrix);
