<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Bank;
use App\Models\Produk;

class LayananPoinController extends Controller
{
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        $bank = Bank::where('id_user', $id)->first();

        // Calculate the total tradVoucher from all products
        $totalTradVoucher = Produk::sum('voucher');

        // Adding dynamic attributes
        $profileData = [
            'nama' => $user->nama,
            'tradVoucher' => $totalTradVoucher,
            'tradPoint' => 1500, // Default value or from another source
            'namaBank' => $bank ? $bank->namaBank : null,
            'nomorRekening' => $bank ? $bank->nomorRekening : null,
            'pemilikRekening' => $bank ? $bank->pemilikRekening : null,
        ];

        return response()->json($profileData);
    }
}
