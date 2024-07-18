<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\api\UserController;
use App\Http\Controllers\api\Referral;
use App\Http\Controllers\api\ReferralCodeController;
use App\Http\Controllers\api\ReferralUsageController;
use App\Http\Controllers\api\ForgotPasswordController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });

Route::post('/register-regular', [UserController::class, 'registerRegular']);
Route::post('/register-admin', [UserController::class, 'registerAdmin']);
Route::post('/activate', [UserController::class, 'processReferral']);

// Route::post('/login', [UserController::class, 'login']);
Route::post('/logout', [UserController::class, 'logout'])->middleware('auth:sanctum');
Route::post('updatePin', [UserController::class, 'updatePin']);

Route::post('referral/check/{noReferal}', [ReferralCodeController::class, 'check']);
Route::post('/referral', [ReferralUsageController::class, 'store']);
Route::resource('referral_usages', ReferralUsageController::class);
Route::get('referral_usages/count/{referred_userID}', [ReferralUsageController::class, 'countByReferrer']);

Route::post('referral_codes/generate', [ReferralCodeController::class, 'store']);

Route::post('/send-otp', [ForgotPasswordController::class, 'sendOtp']);
Route::post('/verify-otp', [ForgotPasswordController::class, 'verifyOtp']);