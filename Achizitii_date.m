% 1. Setarea directoarelor pentru semnături
authDir = 'autentice'; % Directoriul pentru semnături autentice
fakeDir = 'falsificate';    % Directoriul pentru semnături falsificate

% 2. Citirea semnăturilor autentice
authFiles = dir(fullfile(authDir, '*.png')); % Poți schimba '*.png' dacă ai alt format
fakeFiles = dir(fullfile(fakeDir, '*.png'));

% 3. Structura pentru datele colectate
authSignatures = {};
fakeSignatures = {};

% 4. Încărcarea și stocarea semnăturilor
disp('Încărcăm semnăturile autentice...');
for i = 1:length(authFiles)
    img = imread(fullfile(authDir, authFiles(i).name));
    authSignatures{i} = img;
end

disp('Încărcăm semnăturile falsificate...');
for i = 1:length(fakeFiles)
    img = imread(fullfile(fakeDir, fakeFiles(i).name));
    fakeSignatures{i} = img;
end

% 5. Afișarea rezumatului
disp(['Număr de semnături autentice: ', num2str(length(authSignatures))]);
disp(['Număr de semnături falsificate: ', num2str(length(fakeSignatures))]);

% 6. Vizualizarea câtorva semnături
figure;
subplot(1,2,1);
imshow(authSignatures{1});
title('Exemplu - Semnătură Autentică');

subplot(1,2,2);
imshow(fakeSignatures{1});
title('Exemplu - Semnătură Falsificată');
