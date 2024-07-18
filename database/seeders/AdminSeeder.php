<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\NewUser;
use App\Models\ReferralCode;

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
        $user1 = NewUser::create([
            'userID' => 'Admin',
            'name' => 'Admin',
            'phone' => '+6285157883965',
            'email' => 'Admin@example.com',
            'password' => bcrypt('123456'),
            'pin' => bcrypt('1234'),
            'role' => 'admin',
            'noReferal' => 'referralCode456',
            'status' => 'active',
        ]);

        // Seeder untuk referral codes
        ReferralCode::create([
            'userID' => $user1->userID,
            'noReferal' => 'TRAD2024',
        ]);
    }
}
