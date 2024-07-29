<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\API\ReferralCode;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Seeder untuk pengguna
        $user1 = User::create([
            'userId' => 'Admin',
            'nama' => 'Admin',
            'no_hp' => '+62888888888888',
            'alamat' => 'Bandung',
            'email' => 'Admin@example.com',
            'password' => bcrypt('123456'),
            'pin' => bcrypt('1234'),
            'role' => 'admin',
            'noReferal' => 'TRAD2024',
            'status' => 'active',
        ]);

        // Seeder untuk referral codes
        ReferralCode::create([
            'userId' => $user1->userId,
            'noReferal' => 'TRAD2024',
        ]);
    }
}
