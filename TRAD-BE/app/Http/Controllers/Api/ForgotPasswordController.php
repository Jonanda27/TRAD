<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Twilio\Rest\Client;

class ForgotPasswordController extends Controller
{
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'userId' => 'required|string',
            'no_hp' => 'required|string|regex:/^\+\d{1,15}$/'
        ]);
    
        if ($validator->fails()) {
            return response()->json(['error' => 'Format nomor telepon tidak valid.'], 400);
        }

        // Cari user berdasarkan nomor telepon & user ID
        $user = User::where('userId', $request->userId)->where('no_hp', $request->no_hp)->first();

        if (!$user) {
            return response()->json(['error' => 'Nomor telepon atau user ID tidak terdaftar.'], 404);
        }

        // Generate OTP
        $otp = rand(100000, 999999);

        // Simpan OTP ke database
        $user->otp = $otp;
        $user->save();

        // Kirim OTP melalui SMS
        $this->sendSms($request->no_hp, $otp);

        return response()->json(['message' => 'OTP telah dikirim ke nomor telepon Anda.'], 200);
    }
    private function sendSms($phone, $otp)
    {
        $sid = env('TWILIO_SID');
        $token = env('TWILIO_TOKEN');
        $twilioNumber = env('TWILIO_PHONE');
        $twilio = new Client($sid, $token);

        // $verification = $twilio->verify
        // ->v2->services("VA4d999b7ad1f766bc308716542653aff5")
        // ->verifications
        // ->create($phoneNumber, "sms");

        // print($verification->sid);

        $message = $twilio->messages
            ->create($phone, // to
            array(
                "from" => $twilioNumber,
                "body" => "Ini nomor OTP anda: $otp"
            )
            );

        print($message->sid);
        }

    public function verifyOtp(Request $request){
        $validator = Validator::make($request->all(), [
            'no_hp' => 'required|string',
            'otp' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        // Cari user berdasarkan nomor telepon dan OTP
        $user = User::where('no_hp', $request->no_hp)->where('otp', $request->otp)->first();

        if (!$user) {
            return response()->json(['error' => 'OTP atau nomor telepon tidak valid.'], 400);
        }

        return response()->json(['message' => 'OTP Benar!.'], 200);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'no_hp' => 'required|string',
            'otp' => 'required|string',
            'new_password' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        // Cari user berdasarkan nomor telepon dan OTP
        $user = User::where('no_hp', $request->no_hp)->where('otp', $request->otp)->first();

        if (!$user) {
            return response()->json(['error' => 'OTP atau nomor telepon tidak valid.'], 400);
        }

        // Ubah password
        $user->password = Hash::make($request->new_password);
        $user->otp = null; // Hapus OTP setelah digunakan
        $user->save();

        return response()->json(['message' => 'Password berhasil diubah.'], 200);
    }
}