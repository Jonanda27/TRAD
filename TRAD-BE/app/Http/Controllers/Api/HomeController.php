<?php

// app/Http/Controllers/Api/HomeController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Produk;

class HomeController extends Controller
{
    // Method to get home data by user ID
    public function show($id)
    {
        $user = User::with('tokos')->find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        // Calculate total vouchers from all products
        $totalVoucher = Produk::sum('voucher');

        // Adding dynamic attributes
        $homeData = [
            'id' => $user->id,
            'profilePict' => 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png', // Default value or from another source
            'nama' => $user->nama,
            'status' => 'Active', // Default value or from another source
            'expDate' => '2023-12-31', // Default value or from another source
            'tradVoucher' => $totalVoucher, // Calculated total voucher
            'tradPoint' => 1500, // Default value or from another source
            'jumlahToko' => $user->tokos->count(), // Total number of tokos
            'tokos' => $user->tokos->map(function ($toko) {
                return [
                    'nama' => $toko->namaToko,
                    'gambar' => $toko->fotoProfileToko, // Assuming 'gambar' is the column name for the image URL
                ];
            })
        ];

        return response()->json($homeData);
    }
}
