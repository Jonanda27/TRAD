<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Bank;

class BankController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'id_user' => 'required|exists:user,id',
            'namaBank' => 'required|in:Bank Mandiri,Bank BRI,Bank BCA,Bank BSI',
            'nomorRekening' => 'required|numeric',
            'pemilikRekening' => 'required|string'
        ]);

        $bank = Bank::create($request->all());

        return response()->json([
            'namaBank' => $bank->namaBank,
            'nomorRekening' => $bank->nomorRekening,
            'pemilikRekening' => $bank->pemilikRekening
        ], 201);
    }

    public function update(Request $request, $id)
    {
        // Validasi data
        $request->validate([
            'id_user' => 'required|exists:user,id',
            'namaBank' => 'required|in:Bank Mandiri,Bank BRI,Bank BCA,Bank BSI',
            'nomorRekening' => 'required|numeric',
            'pemilikRekening' => 'required|string'
        ]);

        // Cari data bank berdasarkan id
        $bank = Bank::find($id);
        if (!$bank) {
            return response()->json([
                'status' => 'error',
                'message' => 'Bank tidak ditemukan',
                'code' => 404
            ], 404);
        }

        // Perbarui data bank
        $bank->id_user = $request->id_user;
        $bank->namaBank = $request->namaBank;
        $bank->nomorRekening = $request->nomorRekening;
        $bank->pemilikRekening = $request->pemilikRekening;
        $bank->save();

        // Kembalikan respons sukses
        return response()->json([
            'status' => 'success',
            'message' => 'Bank berhasil diperbarui',
            'code' => 200,
            'data' => $bank
        ], 200);
    }


}
