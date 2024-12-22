# JakBites oleh F11 - PBP 2024/2025

### 🍽️ Temukan restoran dan makanan terbaik di Jakarta! 🌆  

### Build Badge  
[![Build status](https://build.appcenter.ms/v0.1/apps/f42e3dea-3a3a-4576-bfbe-706ad8177e6c/branches/main/badge)](https://appcenter.ms)


### [🚀 Download Here!](https://install.appcenter.ms/orgs/pbp-11/apps/jakbites/distribution_groups/public/releases/7)

## Tim Kami 👥

- Christian Yudistira Hermawan (2306241676)
- Muhammad Fadhlan Karimuddin (2306245011)
- Alpha Sutha Media (2306275935)
- Shintia Dharma Shanty (2306245655)
- William Matthew Saputra (2306165862)

## Apa itu JakBites❓

**JakBites** adalah platform inovatif yang dirancang untuk membantu Anda menemukan pengalaman kuliner terbaik di Jakarta! Dengan tampilan yang mudah digunakan dan fitur yang lengkap, JakBites memudahkan Anda dalam menjelajahi berbagai restoran dan makanan yang ada di ibu kota. 🎉

Jakarta, sebagai kota metropolitan, menawarkan beragam pilihan kuliner dari berbagai penjuru dunia. JakBites hadir untuk menjadi panduan kuliner pribadi Anda, menampilkan berbagai restoran dan produk makanan lengkap dengan informasi detail, rating, dan ulasan dari pengguna lainnya. Dengan JakBites, Anda dapat dengan mudah mencari restoran favorit atau menemukan tempat makan baru berdasarkan preferensi Anda seperti jenis makanan, harga, dan lokasi.

Beberapa fitur utama yang ditawarkan oleh JakBites meliputi:
- **Pencarian dan Penyortiran:** Cari restoran dan makanan favorit Anda dengan mudah menggunakan filter berdasarkan kategori, harga, dan lokasi.
- **Rating dan Ulasan:** Dapatkan rekomendasi terbaik dari komunitas JakBites melalui rating dan ulasan yang diberikan oleh pengguna lainnya.
- **Favorit:** Simpan restoran dan makanan favorit Anda untuk akses cepat di kemudian hari.
- **Antarmuka yang Intuitif:** Nikmati pengalaman menjelajah kuliner dengan antarmuka yang sederhana dan responsif, dirancang untuk memudahkan navigasi Anda.

Dengan JakBites, menemukan tempat makan yang sempurna di Jakarta menjadi lebih praktis dan menyenangkan! 🌟

## Modul 📦

1. **Autentikasi dan Admin/Super User: Fadhlan**
   - **🔐 Halaman Login:** Halaman untuk masuk ke akun pengguna.
   - **📝 Halaman Registrasi:** Halaman pendaftaran untuk pengguna baru.
   - **🛠️ Halaman Admin:** Halaman yang memungkinkan admin untuk menambah Restoran dan Makanan.
   - **🍔 Tambah Makanan dan Restoran:** Admin dapat menambah data makanan dan restoran baru.

2. **Utama: Christian**
   - **🏠 Halaman Beranda (Halaman HTML Statis):** Halaman statis yang menampilkan informasi dasar tentang JakBites.
   - **📋 Halaman Utama (Daftar Produk):** Halaman yang menampilkan daftar makanan dan restoran, lengkap dengan fitur penyortiran dan filter untuk memudahkan pencarian.

3. **Makanan: Shintia**
   - **🍽️ Halaman Produk:** Halaman yang menampilkan detail produk makanan, termasuk rating dan ulasan dari pengguna.
   - **⭐ Rating dan Ulasan:** Pengguna dapat memberikan rating serta menulis ulasan untuk produk makanan.

4. **Restoran: Alpha**
   - **🏢 Halaman Restoran:** Halaman yang menampilkan detail restoran, termasuk daftar makanan yang disediakan.
   - **🍛 Daftar Makanan Restoran:** Daftar makanan yang tersedia di restoran tertentu.
   - **🌟 Rating Restoran:** Pengguna dapat memberikan rating dan ulasan untuk restoran.

5. **Pengguna: William**
   - **👤 Halaman Pengguna:** Halaman yang menampilkan profil pengguna, di mana mereka dapat memperbarui informasi dan mengelola akun, termasuk mengubah kata sandi.
   - **❤️ Halaman Favorit:** Pengguna dapat melihat dan mengelola daftar restoran dan makanan favorit mereka.

## Dataset Awal 📊

- [Kaggle - Daftar Produk Pengiriman Makanan Indonesia GoFood](https://www.kaggle.com/datasets/ariqsyahalam/indonesia-food-delivery-gofood-product-list)

## Peran 🔏

1. **Pengguna Biasa (User):** 
   Pengguna umum yang menggunakan JakBites untuk menemukan restoran dan makanan di Jakarta. Mereka dapat mencari restoran dan produk makanan, menambah tempat favorit, serta memberikan ulasan dan rating terhadap restoran atau produk makanan.

2. **Administrator (Admin / Super User):** 
   Admin memiliki hak penuh untuk mengelola konten di JakBites. Mereka dapat menambahkan restoran dan makanan baru.

## Integrasi dengan Aplikasi Web JakBites ⚙️

Untuk mengintegrasikan aplikasi mobile JakBites dengan layanan web yang telah dibangun pada Proyek Tengah Semester, kami mengikuti beberapa langkah utama:

1. **Membuat Model di Flutter**:
   - Mendefinisikan kelas model yang sesuai dengan respons dari layanan web Django menggunakan metode `fromJson` dan `toJson`.
   - Mengimpor library `dart:convert` untuk membantu dalam proses konversi data JSON.

2. **Mengambil Data dari Layanan Web**:
   - Menggunakan paket `http` untuk melakukan permintaan ke layanan web.
   - Melakukan parsing data JSON yang diterima menjadi objek model di Flutter.

3. **Manajemen State dengan Provider**:
   - Mengimplementasikan `Provider` untuk mengelola state secara global.
   - Memungkinkan akses ke instance `CookieRequest` di seluruh widget dalam aplikasi.

4. **Autentikasi**:
   - Mengintegrasikan fitur login dan registrasi dengan endpoint autentikasi pada layanan web Django.
   - Menggunakan paket `pbp_django_auth` untuk mempermudah proses autentikasi dan pengelolaan cookie.

5. **Pengujian dan Debugging**:
   - Menguji koneksi antara aplikasi Flutter dan layanan web untuk memastikan data dapat diambil dan dikirim dengan benar.
   - Melakukan debugging terhadap isu yang muncul selama proses integrasi.

6. **Deploy Aplikasi**:
   - Melakukan deploy aplikasi Flutter dan memastikan bahwa aplikasi terhubung dengan layanan web yang telah di-deploy sebelumnya.
   - Memastikan fungsi-fungsi utama berjalan dengan baik setelah proses deploy.

Dengan mengikuti langkah-langkah di atas, aplikasi mobile JakBites berhasil terhubung dengan layanan web, memungkinkan sinkronisasi data antara aplikasi web dan mobile serta memberikan pengalaman pengguna yang konsisten.

## Tracker Progress 🧑‍💻
https://docs.google.com/spreadsheets/d/1knfOWS6yBqFtnk24bmdTAVb6XyoES_G3vpkKikH71y8/edit?usp=sharing

