<?php

namespace App\Http\Controllers\API;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Str;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class UserController extends Controller{

    public function registerRegular(Request $request)
    {
        return $this->registerUser($request, 'regular');
    }

    // Fungsi untuk pendaftaran pengguna admin
    public function registerAdmin(Request $request)
    {
        return $this->registerUser($request, 'admin');
    }

    private function registerUser(Request $request, $role)
    {
        try {
            $formFields = $request->validate([
                'userId' => ['required'],
                'nama' => ['required'],
                'no_hp' => ['required'],
                'alamat' => ['required'],
                'email' => ['required'],
                'password' => ['required'],
                'pin' => ['required'],
                'noReferal' => ['required', 'exists:referral_codes,noReferal']
            ]);

            $formFields['password'] = bcrypt($formFields['password']);
            $formFields['pin'] = bcrypt($formFields['pin']);
            $formFields['nama'] = Str::lower($formFields['nama']);
            $formFields['email'] = Str::lower($formFields['email']);
            $formFields['role'] = $role;
            $formFields['status'] = 'inactive';

            $User = User::create($formFields);

            $phoneVerify = new ForgotPasswordController();
            $sendOtpRequest = new Request(['userId' => $User->userId, 'no_hp' => $User->no_hp]);
            $sendOtpVerify = $phoneVerify->sendOtp($sendOtpRequest);

            if ($sendOtpVerify->getStatusCode() == 200) {
                return redirect('/login');
            }

            return $User;
        } catch (\Throwable $th) {
            Log::error('Error during registration: ' . $th->getMessage());
            return redirect('/registrasi')->withErrors(['msg' => 'Registration failed! Please try again.'])->withInput();
        }
    }

    public function processReferral(Request $request)
    {
        try {
            $User = User::where('userId', $request->userId)->where('otp', $request->otp)->first();

            if (!$User) {
                return response()->json(['message' => 'User not found or invalid OTP.'], 404);
            }
            $phoneVerify = new ForgotPasswordController();
            $checkOtpRequest = new Request(['no_hp' => $User->no_hp, 'otp' => $User->otp]);
            $checkOtp = $phoneVerify->verifyOtp($checkOtpRequest);

            if ($checkOtp->getStatusCode() == 200) {
                $referralCodeController = new ReferralCodeController();
                $referralCodeRequest = new Request(['userId' => $User->userId]);
                $referralCode = $referralCodeController->store($referralCodeRequest);

                $referralUsageController = new ReferralUsageController();
                $referralUsageRequest = new Request([
                    'noReferal' => $User->noReferal,
                    'referrer_userId' => $User->userId
                ]);
                $referralUsageController->store($referralUsageRequest, $User->noReferal);

                $User->status = 'active';
                $User->otp = null;
                $User->save();

                return redirect('/login')->with('success', 'Registration successful!')->with('referralCode', $referralCode->noReferal);
            }

            // Jika OTP tidak valid
            // $newUser->delete();
            return redirect('/registrasi')->withErrors(['msg' => 'OTP verification failed.'])->withInput();
        } catch (\Throwable $th) {
            Log::error('Error during referral processing: ' . $th->getMessage());
            return response()->json(['message' => 'masuk catch.'], 404);
        }
    }
    public function login(Request $request)
    {
        try {
            $user = User::where('userId', $request->userId)->first();
            $role = $user->role == 'admin';
            $request->validate([
                'userId' => 'required|string',
                'password' => 'required'
            ]);

            if (!$user) {
                return response()->json(['error' => 'Login gagal. User ID atau password salah.'], 401);
            }

            if (!Hash::check($request->password, $user->password)) {
                return response()->json(['error' => 'Login gagal. User ID atau password salah.'], 401);
            }

            $token = $user->createToken('Personal Access Token')->plainTextToken;


            return response()->json(['token' => $token, 'user' => $user, 'message' => 'Login berhasil. Selamat datang' . ($user -> role == 'admin' ? 'Admin' : 'Regular').'!'], 200);
        } catch (\Throwable $th) {
            return response()->json(['error' => 'Login gagal. silahkan coba lagi.'], 500);
        }
    }
    public function logout(Request $request)
    {
        try {
            $user = $request->user();
            $user->tokens()->delete();

            return response()->json(['message' => 'Logout successful'], 200);
        } catch (\Throwable $th) {
            Log::error('Logout failed: ' . $th->getMessage());
            return response()->json(['error' => 'Logout failed. Please try again.'], 500);
        }
    }
    public function updatePin(Request $request)
    {
        // Validasi input
        $request->validate([
            'userId' => ['required', 'exists:user,userId'],
            'current_pin' => ['required', 'size:4'],
            'new_pin' => ['required', 'size:4'] // Misalnya minimal 4 karakter
        ]);

        // Cari pengguna berdasarkan userID
        $user = User::where('userId', $request->userId)->firstOrFail();

        // Periksa apakah PIN saat ini cocok
        if (!Hash::check($request->current_pin, $user->pin)) {
            return response()->json(['error' => 'PIN saat ini salah'], 400);
        }

        // Update PIN dengan PIN baru
        $user->pin = Hash::make($request->new_pin);
        $user->save();

        return response()->json(['message' => 'PIN berhasil diubah'], 200);
    }
}