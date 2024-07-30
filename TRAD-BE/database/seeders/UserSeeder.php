<?php
 
namespace Database\Seeders;
 
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
 
class UserSeeder extends Seeder
{
    /**
     * Run the database seeders.
     *
     * @return void
     */
    public function run()
    {
        DB::table('user')->insert([
            'id' => '1',
            'role' => 'admin',
            'nama' => 'admin',
            'email' => 'kristiandi@gmail.com',
            'no_hp' => '08123412324',
            'alamat' => 'Jl.rancabentang',
            'password' => Hash::make('12345678')
        ]);

        DB::table('user')->insert([
            'id' => '2',
            'role' => 'admin',
            'nama' => 'evv',
            'email' => 'evv@gmail.com',
            'no_hp' => '081234123345',
            'alamat' => 'Jl.rancabentang',
            'password' => Hash::make('12345678')
        ]);
    }
}