function verify_signature()
    % Creează figura principală
    fig = uifigure('Name', 'Signature Verification', 'Position', [100, 100, 800, 600]);

    % Tabel pentru afișarea datelor achiziționate
    uitable(fig, 'Position', [20, 300, 360, 250], ...
        'ColumnName', {'ID', 'Nume'}, ...
        'RowName', []);

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
        'ButtonPushedFcn', @(btn, event) addToDatabase());

    % Buton pentru ștergere din baza de date
    uibutton(fig, 'Position', [50, 100, 150, 30], ...
        'Text', 'Șterge din Baza de Date', ...
        'ButtonPushedFcn', @(btn, event) deleteFromDatabase());

    % Buton pentru compararea semnăturilor
    uibutton(fig, 'Position', [50, 50, 150, 30], ...
        'Text', 'Compară Semnături', ...
        'ButtonPushedFcn', @(btn, event) compareSignatures());

    % Text pentru afișarea mesajelor de status
    uilabel(fig, 'Position', [220, 50, 300, 30], ...
        'Text', 'Status: Aștept acțiunea utilizatorului...', ...
        'Tag', 'StatusLabel');
end

function loadSignature(ax)
    % Funcție pentru încărcarea unei imagini
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files'}, 'Selectează o Semnătură');
    if file
        img = imread(fullfile(path, file));
        imshow(img, 'Parent', ax);
        updateStatus('Semnătura a fost încărcată cu succes.');
    else
        updateStatus('Nu s-a selectat nicio imagine.');
    end
end

function addToDatabase()
    % Funcție pentru adăugarea semnăturii în baza de date
    updateStatus('Funcționalitatea de adăugare în baza de date urmează să fie implementată.');
end

function deleteFromDatabase()
    % Funcție pentru ștergerea unei intrări din baza de date
    updateStatus('Funcționalitatea de ștergere urmează să fie implementată.');
end

function compareSignatures()
    % Funcție pentru compararea semnăturilor
    updateStatus('Funcționalitatea de comparare urmează să fie implementată.');
end

function updateStatus(message)
    % Funcție pentru actualizarea mesajului de status
    lbl = findobj('Tag', 'StatusLabel'); % Găsește elementul UI cu tag-ul 'StatusLabel'
    if ~isempty(lbl)
        lbl.Text = ['Status: ', message]; % Actualizează textul
    else
        warning('Eticheta de status nu a fost găsită.');
    end
end

