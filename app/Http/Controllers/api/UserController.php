<?php

namespace App\Http\Controllers\api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Hash;
use App\Models\NewUser;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
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
                'userID' => ['required'],
                'name' => ['required'],
                'phone' => ['required'],
                'email' => ['required'],
                'noReferal' => ['required', 'exists:referral_codes,noReferal'],
                'password' => ['required'],
                'pin' => ['required']
            ]);

            $formFields['password'] = bcrypt($formFields['password']);
            $formFields['pin'] = bcrypt($formFields['pin']);
            $formFields['name'] = Str::lower($formFields['name']);
            $formFields['email'] = Str::lower($formFields['email']);
            $formFields['role'] = $role;
            $formFields['status'] = 'inactive';

            $newUser = NewUser::create($formFields);

            $phoneVerify = new ForgotPasswordController();
            $sendOtpRequest = new Request(['userID' => $newUser->userID, 'phone' => $newUser->phone]);
            $sendOtpVerify = $phoneVerify->sendOtp($sendOtpRequest);

            if ($sendOtpVerify->getStatusCode() == 200) {
                return redirect('/login');
            }

            return $newUser;
        } catch (\Throwable $th) {
            Log::error('Error during registration: ' . $th->getMessage());
            return redirect('/registrasi')->withErrors(['msg' => 'Registration failed! Please try again.'])->withInput();
        }
    }

    public function processReferral(Request $request)
    {
        try {
            $newUser = NewUser::where('userID', $request->userID)->where('otp', $request->otp)->first();
            
            $phoneVerify = new ForgotPasswordController();
            $checkOtpRequest = new Request(['phone' => $newUser->phone, 'otp' => $newUser->otp]);
            $checkOtp = $phoneVerify->verifyOtp($checkOtpRequest);
    
            if ($checkOtp->getStatusCode() == 200) {
                $referralCodeController = new ReferralCodeController();
                $referralCodeRequest = new Request(['userID' => $newUser->userID]);
                $referralCode = $referralCodeController->store($referralCodeRequest);
    
                $referralUsageController = new ReferralUsageController();
                $referralUsageRequest = new Request([
                    'noReferal' => $newUser->noReferal,
                    'referrer_userID' => $newUser->userID
                ]);
                $referralUsageController->store($referralUsageRequest, $newUser->noReferal);
    
                $newUser->status = 'active';
                $newUser->otp = null;
                $newUser->save();
    
                return redirect('/login')->with('success', 'Registration successful!')->with('referralCode', $referralCode->noReferal);
            }
    
            // Jika OTP tidak valid
            // $newUser->delete();
            return redirect('/registrasi')->withErrors(['msg' => 'OTP verification failed.'])->withInput();
        } catch (\Throwable $th) {
            Log::error('Error during referral processing: ' . $th->getMessage());
            return redirect('/registrasi')->withErrors(['msg' => 'Registration successful but referral processing failed.'])->withInput();
        }
    }
    

    public function login(Request $request)
    {
        try {
            $request->validate([
                'userID' => 'required',
                'password' => 'required'
            ]);

            $user = NewUser::where('userID', $request->userID)->first();

            if (!$user) {
                return response()->json(['error' => 'Login failed. UserID or password is incorrect.'], 401);
            }

            if (!Hash::check($request->password, $user->password)) {
                return response()->json(['error' => 'Login failed. UserID or password is incorrect.'], 401);
            }

            $token = $user->createToken('authToken')->plainTextToken;
            $user->token = $token;
            return response()->json(['token' => $token, 'message' => 'Login successful. Welcome!'], 200);
        } catch (\Throwable $th) {
            Log::error('Login failed: ' . $th->getMessage());
            return response()->json(['error' => 'Login failed. Please try again.'], 500);
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
            'userID' => ['required', 'exists:newusers,userID'],
            'current_pin' => ['required', 'size:4'],
            'new_pin' => ['required', 'size:4'] // Misalnya minimal 4 karakter
        ]);

        // Cari pengguna berdasarkan userID
        $user = NewUser::where('userID', $request->userID)->firstOrFail();

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
