<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class ProfileController extends Controller
{
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        $profileData = [
            'id' => $user->id,
            'profilePict' => $user->profilePict,
            'name' => $user->nama,
            'status' => $user->status,
            'expDate' => $user->expDate,
            'tradvoucher' => $user->tradvoucher,
            'tradPoint' => $user->tradPoint,
            'targetRefProgress' => $user->targetRefProgress,
            'targetRefValue' => $user->targetRefValue,
            'tradLevel' => $user->tradLevel,
            'bonusRadarTradBulanIni' => 'TBD - Atur Radar',  // Tambahkan logic sesuai kebutuhan
        ];

        return response()->json($profileData, 200);
    }

    public function showAkun($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        return response()->json($user);
    }

    public function update(Request $request, $id)
    {
        // Validasi input
        $request->validate([
            'nama' => 'required|string|max:255',
            'userId' => 'required|string|max:255'
        ]);

        // Temukan user berdasarkan ID
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        // Update user data
        $user->nama = $request->input('nama');
        $user->userId = $request->input('userId');
        $user->save();

        // Response JSON
        return response()->json([
            'id' => $user->id,
            'nama' => $user->nama,
            'userId' => $user->userId
        ], 200);
    }

    public function updatePersonalInfo(Request $request, $id)
    {
        // Validasi input
        $request->validate([
            'email' => 'required|string|email|max:255',
            'no_hp' => 'required|string|max:255',
            'tanggalLahir' => 'required|date',
            'jenisKelamin' => 'required|in:L,P'
        ]);

        // Temukan user berdasarkan ID
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        // Update user data
        $user->email = $request->input('email');
        $user->no_hp = $request->input('no_hp');
        $user->tanggalLahir = $request->input('tanggalLahir');
        $user->jenisKelamin = $request->input('jenisKelamin');
        $user->save();

        // Response JSON
        return response()->json([
            'id' => $user->id,
            'email' => $user->email,
            'no_hp' => $user->no_hp,
            'tanggalLahir' => $user->tanggalLahir,
            'jenisKelamin' => $user->jenisKelamin
        ], 200);
    }
}
