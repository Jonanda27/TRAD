<?php

namespace App\Http\Controllers\api;

use App\Models\ReferralCode;
use Illuminate\Http\Request;
use App\Models\NewUser;
use App\Http\Controllers\Controller;

class ReferralCodeController extends Controller
{
    // Menampilkan semua kode referral
    public function index()
    {
        $referralCodes = ReferralCode::all();
        return response()->json($referralCodes);
    }

    public function store(Request $request)
{
    $request->validate([
        'userID' => 'required|exists:newusers,userID',
    ]);

    // Dapatkan informasi pengguna berdasarkan userID
    $user = NewUser::where('userID', $request->userID)->firstOrFail();

    // Pastikan noReferal ada dan valid
    if (!$user->noReferal) {
        return response()->json(['error' => 'User noReferal must be provided.'], 400);
    }

    // Buat kode referal berdasarkan format yang disebutkan
    $referral_code = strtoupper(substr($user->name, 0, 2)) .
                    $user->created_at->format('mdy') .
                    strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, 2));

    // Simpan kode referal
    $referralCode = ReferralCode::create([
        'userID' => $user->userID,
        'noReferal' => $referral_code, // Pastikan noReferal diisi dengan nilai yang valid
    ]);

    return $referralCode;
}
    // public function check($noReferal)
    // {
    //     $referralCode = ReferralCode::where('noReferal', $noReferal)->first();

    //     if ($referralCode) {
    //         return $referralCode;
    //     } else {
    //         return response()->json(['message' => 'Referral code not found'], 404);
    //     }
    // }
    public function check($noReferal)
    {
        $referralCode = ReferralCode::where('noReferal', $noReferal)->first();

        return $referralCode ?: null;
    }

    // Menghapus kode referral tertentu
    public function destroy($id)
    {
        $referralCode = ReferralCode::findOrFail($id);
        $referralCode->delete();
        return response()->json(null, 204);
    }
}
