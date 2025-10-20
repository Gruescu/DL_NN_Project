import tkinter as tk
from tkinter import filedialog, messagebox
import os
import cv2
import numpy as np

# Funcție pentru calcularea distanței Euclidiene
def euclidean(img1, img2):
    return np.linalg.norm(img1 - img2)

# Pragul de distanță pentru a considera semnătura autentică
THRESHOLD = 10000  # Ajustabil

class SignatureApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Signature Recognition")
        self.root.geometry("800x600")

        # Directorul bazei de date
        self.database_dir = "Baza de date"
        if not os.path.exists(self.database_dir):
            os.makedirs(self.database_dir)

        # Elemente ale interfeței
        self.setup_ui()

    def setup_ui(self):
        # Cadru pentru butoane
        button_frame = tk.Frame(self.root)
        button_frame.pack(pady=10)

        # Butoane funcționale
        load_button = tk.Button(button_frame, text="Încarcă Semnătură", command=self.load_signature)
        load_button.grid(row=0, column=0, padx=10)

        add_button = tk.Button(button_frame, text="Adaugă Multiple Semnături în Baza de Date", command=self.add_multiple_to_database)
        add_button.grid(row=0, column=1, padx=10)

        recognize_button = tk.Button(button_frame, text="Recunoaște Semnătură", command=self.recognize_signature)
        recognize_button.grid(row=0, column=2, padx=10)

        delete_button = tk.Button(button_frame, text="Șterge Semnătură", command=self.delete_from_database)
        delete_button.grid(row=0, column=3, padx=10)

        # Etichetă pentru status
        self.status_label = tk.Label(self.root, text="Status: Aștept acțiunea utilizatorului...", bg="white", anchor="w")
        self.status_label.pack(fill="x", pady=10)

    def load_signature(self):
        # Încarcă o imagine
        file_path = filedialog.askopenfilename(filetypes=[("Image files", "*.png;*.jpg;*.jpeg")])
        if file_path:
            self.status_label.config(text="Semnătura încărcată.")
            self.current_image_path = file_path
        else:
            messagebox.showerror("Eroare", "Nu s-a selectat nicio semnătură!")

    def add_multiple_to_database(self):
        # Adaugă multiple imagini în baza de date
        file_paths = filedialog.askopenfilenames(filetypes=[("Image files", "*.png;*.jpg;*.jpeg")])
        if file_paths:
            for file_path in file_paths:
                file_name = os.path.basename(file_path)
                dest_path = os.path.join(self.database_dir, file_name)
                if not os.path.exists(dest_path):
                    os.rename(file_path, dest_path)
                else:
                    messagebox.showinfo("Info", f"Semnătura {file_name} există deja.")
            self.status_label.config(text="Semnături adăugate în baza de date.")
        else:
            messagebox.showerror("Eroare", "Nu s-au selectat semnături!")

    def delete_from_database(self):
        # Șterge o imagine din baza de date
        file_path = filedialog.askopenfilename(initialdir=self.database_dir, filetypes=[("Image files", "*.png;*.jpg;*.jpeg")])
        if file_path:
            os.remove(file_path)
            self.status_label.config(text=f"Semnătura {os.path.basename(file_path)} a fost ștearsă.")
        else:
            messagebox.showerror("Eroare", "Nu s-a selectat nicio semnătură pentru ștergere!")

    def preprocess_image(self, image_path):
        # Preprocesare imagine
        image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        image = cv2.resize(image, (200, 100))  # Uniformizare dimensiuni
        return image

    def recognize_signature(self):
        # Recunoaște semnătura încărcată comparativ cu baza de date
        if hasattr(self, 'current_image_path'):
            input_signature = self.preprocess_image(self.current_image_path)
            min_distance = float('inf')
            recognized_person = None

            for file_name in os.listdir(self.database_dir):
                db_signature_path = os.path.join(self.database_dir, file_name)
                db_signature = self.preprocess_image(db_signature_path)
                distance = euclidean(input_signature, db_signature)
                if distance < min_distance:
                    min_distance = distance
                    recognized_person = file_name

            if min_distance < THRESHOLD:
                self.status_label.config(text=f"Semnătura autentică: {recognized_person}")
            else:
                self.status_label.config(text="Semnătura este falsă.")
        else:
            messagebox.showerror("Eroare", "Nu s-a încărcat nicio semnătură!")

# Initializare aplicație
if __name__ == "__main__":
    root = tk.Tk()
    app = SignatureApp(root)
    root.mainloop()
