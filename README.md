# Smoker App

Aplikasi mobile berbasis Flutter yang mensimulasikan sistem e-commerce sederhana dengan fitur autentikasi menggunakan Firebase, integrasi backend dengan JWT, serta state management menggunakan Provider.

---

## Fitur Utama

### Authentication (Firebase)

* Registrasi menggunakan email dan password
* Login akun
* Verifikasi email (wajib)
* User tidak dapat login sebelum melakukan verifikasi email

### Integrasi Backend

* Mengirim Firebase ID Token ke backend
* Backend melakukan validasi dan mengembalikan JWT
* JWT disimpan (local storage / memory)
* JWT digunakan untuk request API berikutnya

### Catalog Product

* Menampilkan daftar produk (API atau dummy)
* Informasi produk:

  * Nama barang
  * Harga
  * Gambar (opsional)

### Cart (Keranjang)

* Menambahkan barang ke keranjang
* Menghapus barang dari keranjang
* Menghitung total harga
* Menggunakan Provider dan ChangeNotifier

### Checkout

* Menampilkan daftar item yang dipilih
* Menampilkan total harga

### State Management

* Provider
* ChangeNotifier
* notifyListeners()

### API Flow

1. Login → Firebase Authentication
2. Verifikasi → Backend (JWT diterbitkan)
3. Ambil produk → Backend atau dummy

---

## Struktur Project

```id="k2m9az"
lib/
│
├── models/
│   └── product.dart
│
├── providers/
│   ├── auth_provider.dart
│   └── cart_provider.dart
│
├── screens/
│   ├── auth_page.dart
│   ├── auth_wrapper.dart
│   ├── cart_page.dart
│   ├── home_page.dart
│   └── product_page.dart
│
├── services/
│   └── auth_service.dart
│
└── main.dart
```

---

## Teknologi yang Digunakan

* Flutter
* Firebase Authentication
* Cloud Firestore
* JWT (JSON Web Token)
* Provider

---

## Screenshot Aplikasi

Tambahkan screenshot aplikasi di bawah ini:

### Authentication
<img width="474" height="619" alt="image" src="https://github.com/user-attachments/assets/9be35306-caf4-4a93-bea6-30400b58563d" />

<img width="881" height="236" alt="image" src="https://github.com/user-attachments/assets/c25062f5-d1c6-44ec-b964-07d6da46f0bf" />


### Home / Product List

<img width="489" height="631" alt="image" src="https://github.com/user-attachments/assets/ce2e4e73-4350-491d-af22-f478d7bce9fe" />


### Cart

<img width="491" height="641" alt="image" src="https://github.com/user-attachments/assets/efb1f0a4-a90d-4cdf-a361-38eb69103074" />




---

## Cara Menjalankan Project

### 1. Clone Repository

```bash id="f9x2lm"
git clone https://github.com/username/smoker-app.git
cd smoker-app
```

### 2. Install Dependencies

```bash id="b7d1qp"
flutter pub get
```

### 3. Setup Firebase

* Buat project di Firebase Console
* Aktifkan Authentication (Email dan Password)
* Aktifkan Firestore Database
* Download file konfigurasi:

  * google-services.json (Android)
  * GoogleService-Info.plist (iOS)
* Letakkan pada folder yang sesuai

### 4. Jalankan Aplikasi

```bash id="q3r8tx"
flutter run
```

---

## Catatan

* Verifikasi email wajib sebelum login
* JWT digunakan untuk autentikasi ke backend
* State management menggunakan Provider
* Perubahan state menggunakan notifyListeners()

---

## Pengembangan Selanjutnya

* Integrasi payment gateway
* Penyimpanan cart secara persisten
* Peningkatan UI/UX
* Penambahan detail produk

---

## Author

Sadam Irham Marami (1123150087)
Ti 23 SE
Prodi : Teknik Informatika
Jurusan : Software Engineer
demo : https://youtu.be/degnL8qxK3c


---
