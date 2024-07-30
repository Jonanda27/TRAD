<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
Use App\Models\KategoriBarang;
Use App\Models\User;
Use App\Models\SlideShow;
Use App\Models\Brands;
Use App\Models\Barang;


class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        User::create([
            'id' => 1,
            'role' => 'admin',
            'nama' => 'Kristiandi S',
            'no_hp' => '08234524356',
            'alamat' => 'Jl.Cimahi No.100',
            'email' => 'kris@gmail.com',
            'password' => '$2y$10$nhHZlKMmqMN9kdmSpz3p8eXNyxhr/Cu/f999IJlJ4jHZ5cJ.1NF2O',

        ]);

        Brands::create([
            'id' => 1,
            'nama' => 'Niki',
            'deskripsi' => 'Fashion',
            'icon' => '',

        ]);

        Brands::create([
            'id' => 2,
            'nama' => 'Specs',
            'deskripsi' => 'Fashion',
            'icon' => '',

        ]);

        Brands::create([
            'id' => 3,
            'nama' => 'Adidas',
            'deskripsi' => 'Fashion',
            'icon' => '',

        ]);

        KategoriBarang::create([
            'id' => 1,
            'nama' => 'Lari',
            'icon' => '',

        ]);

        KategoriBarang::create([
            'id' => 2,
            'nama' => 'Basket',
            'icon' => '',

        ]);

        KategoriBarang::create([
            'id' => 3,
            'nama' => 'Futsal',
            'icon' => '',

        ]);

        SlideShow::create([
            'id' => 1,
            'judul' => 'Diskon Perlengkapan Lari',
            'deskripsi' => 'Barang premiuam terbatas,Diskon hanya untuk hari ini',
            'id_kategori_barang' => 1,
            'gambar' => '',

        ]);

        Barang::create([
            'id' => 1,
            'nama' => 'Sepatu Futsal',
            'harga' => 500000,
            'stock' => 100,
            'deskripsi' => 'Sepatu Futsal',
            'id_kategori_barang' => 3,
            'gender' => 1,
            'ukuran' => 40,
            'foto' => '',
            'bintang' => '5',

        ]);

        Barang::create([
            'id' => 2,
            'nama' => 'Sepatu Basket',
            'harga' => 600000,
            'stock' => 100,
            'deskripsi' => 'Sepatu Basket',
            'id_kategori_barang' => 2,
            'gender' => 2,
            'ukuran' => 40,
            'foto' => '',
            'bintang' => '4',

        ]);

        Barang::create([
            'id' => 3,
            'nama' => 'Sepatu R',
            'harga' => 500000,
            'stock' => 100,
            'deskripsi' => 'Sepatu Futsal',
            'id_kategori_barang' => 3,
            'gender' => 1,
            'ukuran' => 42,
            'foto' => '',
            'bintang' => '5',

        ]);

        Barang::create([
            'id' => 4,
            'nama' => 'Sepatu VV',
            'harga' => 650000,
            'stock' => 100,
            'deskripsi' => 'Sepatu Futsal',
            'id_kategori_barang' => 3,
            'gender' => 1,
            'ukuran' => 41,
            'foto' => '',
            'bintang' => '4',

        ]);

        Barang::create([
            'id' => 5,
            'nama' => 'Sepatu Lari',
            'harga' => 500000,
            'stock' => 100,
            'deskripsi' => 'Sepatu Lari',
            'id_kategori_barang' => 1,
            'gender' => 2,
            'ukuran' => 40,
            'foto' => '',
            'bintang' => '5',

        ]);
        // \App\Models\User::factory(10)->create();
    }
}