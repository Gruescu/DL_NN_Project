% 1. Detectarea și extracția caracteristicilor pentru semnături
disp('Extragem caracteristicile pentru semnături...');

% Funcție pentru extragerea caracteristicilor folosind HOG
extractHOGFeaturesWrapper = @(img) extractHOGFeatures(img, 'CellSize', [8 8]);

authFeatures = []; % Caracteristicile semnăturilor autentice
fakeFeatures = []; % Caracteristicile semnăturilor falsificate

% 2. Caracteristici pentru semnături autentice
for i = 1:length(authSignatures)
    img = authSignatures{i};
    img = imresize(img, [128 128]); % Redimensionare pentru uniformitate
    if size(img, 3) == 3
        img = rgb2gray(img); % Conversie în tonuri de gri dacă e necesar
    end
    features = extractHOGFeaturesWrapper(img);
    authFeatures = [authFeatures; features]; % Adăugăm caracteristicile
end

% 3. Caracteristici pentru semnături falsificate
for i = 1:length(fakeSignatures)
    img = fakeSignatures{i};
    img = imresize(img, [128 128]);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    features = extractHOGFeaturesWrapper(img);
    fakeFeatures = [fakeFeatures; features];
end

% 4. Rezumat
disp(['Caracteristici extrase pentru semnături autentice: ', num2str(size(authFeatures, 1))]);
disp(['Caracteristici extrase pentru semnături falsificate: ', num2str(size(fakeFeatures, 1))]);

% Vizualizare HOG pentru o semnătură autentică
figure;
if ~isempty(authSignatures)
    img = authSignatures{1};
    img = imresize(img, [128 128]);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    [features, visualization] = extractHOGFeatures(img, 'CellSize', [8 8]);
    imshow(img);
    hold on;
    plot(visualization);
    title('Caracteristici HOG pentru o semnătură autentică');
end

