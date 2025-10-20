function GUI()
    % Definim variabila globală pentru statusLabel
    global statusLabel;

    % Creează figura principală
    fig = uifigure('Name', 'Signature Verification', 'Position', [100, 100, 800, 600]);

    % Tabel pentru afișarea datelor achiziționate
    data_table = uitable(fig, 'Position', [20, 300, 360, 250], ...
        'ColumnName', {'ID', 'Nume'}, ...
        'RowName', [], ...
        'ColumnEditable', [false, true]);  % Permite editarea coloanei "Nume"

    % Axă grafică pentru afișarea imaginii
    ax = uiaxes(fig, 'Position', [420, 300, 350, 250]);
    title(ax, 'Imaginea Semnăturii');
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    
    % Buton pentru încărcarea imaginii
    uibutton(fig, 'Position', [50, 200, 150, 30], ...
        'Text', 'Achiziție de Date', ...
        'ButtonPushedFcn', @(btn, event) loadSignature(ax));

    % Buton pentru adăugare în baza de date
    uibutton(fig, 'Position', [50, 150, 150, 30], ...
        'Text', 'Adaugă în Baza de Date', ...
        'ButtonPushedFcn', @(btn, event) addToDatabase(data_table));

    % Buton pentru ștergere din baza de date
    uibutton(fig, 'Position', [50, 100, 150, 30], ...
        'Text', 'Șterge din Baza de Date', ...
        'ButtonPushedFcn', @(btn, event) deleteFromDatabase(data_table));

    % Buton pentru compararea semnăturilor
    uibutton(fig, 'Position', [50, 50, 150, 30], ...
        'Text', 'Compară Semnături', ...
        'ButtonPushedFcn', @(btn, event) compareSignatures(ax, data_table));

    % Text pentru afișarea mesajelor de status (actualizat în GUI)
    statusLabel = uilabel(fig, 'Position', [220, 20, 560, 30], ...
        'Text', 'Status: Aștept acțiunea utilizatorului...', 'Tag', 'StatusLabel');
end

function loadSignature(ax)
    global statusLabel;
    % Funcție pentru încărcarea unei imagini
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files'}, 'Selectează o Semnătură');
    if file
        img = imread(fullfile(path, file));
        imshow(img, 'Parent', ax);
        assignin('base', 'loadedSignature', img); % Salvează semnătura în workspace pentru utilizare ulterioară
        updateStatus('Semnătura a fost încărcată cu succes.');
    else
        updateStatus('Nu s-a selectat nicio imagine.');
    end
end

function addToDatabase(data_table)
    % Funcție pentru adăugarea semnăturii în baza de date
    if evalin('base', 'exist(''loadedSignature'', ''var'')')
        img = evalin('base', 'loadedSignature');
        name = inputdlg('Introduceți numele persoanei:');
        
        if ~isempty(name)
            name = strtrim(name{1});  % Normalizează inputul
            
            % Dacă există baza de date, încarcă-o
            if isfile('signatureDatabase.mat')
                load('signatureDatabase.mat', 'database');
            else
                database = {}; % Dacă nu există, creează o bază de date goală
            end
            
            % Elimină Persoana1 dacă există
            idx = find(cellfun(@(x) strcmp(x.Name, 'Persoana1'), database), 1);
            if ~isempty(idx)
                database(idx) = [];  % Șterge Persoana1
            end
            
            % Determină ID-ul pentru semnătura nouă
            if ~isempty(database)
                maxID = max(cellfun(@(x) x.ID, database));  % Găsește cel mai mare ID existent
                newID = maxID + 1;  % Incrementăm ID-ul pentru noua semnătură
            else
                newID = 1;  % Dacă baza de date este goală, începem de la 1
            end
            
            % Adaugă semnătura în baza de date
            database{end+1} = struct('ID', newID, 'Name', name, 'Image', img);
            save('signatureDatabase.mat', 'database');
            
            % Crează un cell array pentru tabelul de afișare
            newData = {};
            for i = 1:numel(database)
                newData{i, 1} = num2str(database{i}.ID);  % ID-ul ca șir
                newData{i, 2} = database{i}.Name;        % Numele ca șir
            end
            
            % Actualizează tabelul cu noile date
            data_table.Data = newData;
            
            updateStatus('Semnătura a fost adăugată în baza de date.');
        else
            updateStatus('Adăugarea semnăturii a fost anulată.');
        end
    else
        updateStatus('Nu există nicio semnătură încărcată.');
    end
end

function deleteFromDatabase(data_table)
    % Funcție pentru ștergerea semnăturii din baza de date
    if isfile('signatureDatabase.mat')
        load('signatureDatabase.mat', 'database');
    else
        database = {};  % Dacă nu există, baza de date este goală
    end
    
    if iscell(database)
        % Crează lista cu numele semnăturilor pentru a le afișa în dialog
        nameList = cellfun(@(x) char(x.Name), database, 'UniformOutput', false);
        
        % Afișează un dialog pentru a alege semnătura de șters
        [selection, ok] = listdlg('ListString', nameList, 'SelectionMode', 'single', 'PromptString', 'Alege semnătura de șters:');
        
        if ok
            % Șterge semnătura aleasă
            database(selection) = [];
            save('signatureDatabase.mat', 'database');
            
            newData = {};
            for i = 1:numel(database)
                newData{i, 1} = num2str(database{i}.ID);  % ID-ul ca șir
                newData{i, 2} = database{i}.Name;        % Numele ca șir
            end
            
            % Actualizează tabelul cu noile date
            data_table.Data = newData;
            updateStatus('Semnătura a fost ștearsă din baza de date.');
        else
            updateStatus('Ștergerea semnăturii a fost anulată.');
        end
    else
        updateStatus('Eroare: Baza de date nu este într-un format valid.');
    end
end

function compareSignatures(ax, data_table)
    global statusLabel;
    % Funcție pentru compararea semnăturilor
    try
        if evalin('base', 'exist(''loadedSignature'', ''var'')')
            img = evalin('base', 'loadedSignature');
            
            if isfile('signatureDatabase.mat')
                load('signatureDatabase.mat', 'database');
                matchFound = false;
                
                for i = 1:numel(database)
                    % Compară semnătura încărcată cu semnătura din baza de date
                    if compareImages(img, database{i}.Image)
                        updateStatus(['Semnătura aparține persoanei: ', database{i}.Name]);
                        matchFound = true;
                        break;
                    end
                end
                
                if ~matchFound
                    updateStatus('Semnătura nu a fost recunoscută.');
                end
            else
                updateStatus('Baza de date nu există.');
            end
        else
            updateStatus('Nu există nicio semnătură încărcată.');
        end
    catch ME
        updateStatus(['Eroare la compararea semnăturilor: ', ME.message]);
    end
end

function match = compareImages(img1, img2)
    % Preprocesare: Convertim la grayscale și redimensionăm
    img1_gray = rgb2gray(imresize(img1, [100, 100]));
    img2_gray = rgb2gray(imresize(img2, [100, 100]));
    
    % Extragem caracteristicile HOG din ambele imagini
    features1 = computeHOG(img1_gray);
    features2 = computeHOG(img2_gray);
    
    % Comparăm caracteristicile HOG utilizând distanța Euclidiană
    distance = norm(features1 - features2);  % Distanța Euclidiană între vectorii de caracteristici
    
    % Setăm un prag pentru diferență
    threshold = 0.5;  % Pragul pentru diferența dintre caracteristici (poate fi ajustat)
    
    % Dacă distanța este sub prag, considerăm că semnăturile sunt similare
    match = distance < threshold;
end

function features = computeHOG(img)
    % Calcularea gradientului pe direcțiile X și Y folosind operatorii Sobel
    [Gx, Gy] = gradient(double(img));
    
    % Calcularea magnitudinii și unghiului gradienților
    magnitude = sqrt(Gx.^2 + Gy.^2);
    angle = atan2(Gy, Gx);
    
    % Definirea numărului de celule (poți ajusta acest parametru)
    cell_size = 8;
    [rows, cols] = size(img);
    
    % Împărțirea imaginii în celule
    features = [];
    for i = 1:cell_size:rows-cell_size+1
        for j = 1:cell_size:cols-cell_size+1
            % Extragem celula curentă
            mag_cell = magnitude(i:i+cell_size-1, j:j+cell_size-1);
            ang_cell = angle(i:i+cell_size-1, j:j+cell_size-1);
            
            % Histogramă pe direcția unghiului gradienților (0-180 grade)
            hist = zeros(9, 1);  % 9 binuri de unghiuri (0:20:180)
            for m = 1:cell_size
                for n = 1:cell_size
                    bin = floor(mod(ang_cell(m, n), pi) / (pi/9)) + 1;
                    hist(bin) = hist(bin) + mag_cell(m, n);
                end
            end
            
            % Adăugăm histogramă la vectorul de caracteristici
            features = [features; hist];
        end
    end
end

function updateStatus(message)
    global statusLabel;
    % Actualizăm mesajul de status
    statusLabel.Text = message;
end