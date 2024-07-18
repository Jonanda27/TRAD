<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\NewUser;
use App\Models\ReferralCode;

class UsersSeeder extends Seeder
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
            'userID' => 'test1',
            'name' => 'test1',
            'phone' => '1234567890',
            'email' => 'test1@example.com',
            'password' => bcrypt('123456'),
            'pin' => bcrypt('1234'),
            'role' => 'regular',
            'noReferal' => 'referralCode456',
        ]);

        $user2 = NewUser::create([
            'userID' => 'admin1',
            'name' => 'admin1',
            'phone' => '9876543210',
            'email' => 'admin1@example.com',
            '' => 'admin1@example.com',
            'password' => bcrypt('123456'),
            'pin' => bcrypt('1234'),
            'role' => 'admin',
            'noReferal' => 'referralCode123',
        ]);

        // Seeder untuk referral codes
        ReferralCode::create([
            'userID' => $user1->userID,
            'noReferal' => 'referralCode123',
        ]);

        ReferralCode::create([
            'userID' => $user2->userID,
            'noReferal' => 'referralCode456',
        ]);
    }
}
