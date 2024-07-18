<?php

namespace App\Http\Controllers\api;

use Illuminate\Http\Request;
use App\Models\ReferralUsage;
use App\Http\Controllers\Controller;
use App\Models\ReferralCode;

class ReferralUsageController extends Controller
{
    /**
     * Display a listing of the referral usages.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $referralUsages = ReferralUsage::with(['referrer', 'referred'])->get();
        return response()->json($referralUsages);
    }

    // public function store(Request $request)
    // {
    //     $userID = ReferralCode::where('noReferal', $request->noReferal)->value('userID');
    //     $request->validate([
    //         'referrer_userID' => 'required|exists:newusers,userID',
    //         // 'referred_userID' => 'required|exists:newusers,userID',
    //     ]); 
    //     $request['referred_userID'] = $userID;
    //     $referralUsage = ReferralUsage::create($request->all());

    //     return response()->json($referralUsage, 201);
    // }

    public function store(Request $request, $noReferal)
    {
        // $referralCodeController = new ReferralCodeController();
        // $referralCode = $referralCodeController->check($noReferal);

        // if (!$referralCode) {
            // return response()->json(['error' => 'Referral code tidak ditemukan'], 422);
        // }

        $userID = ReferralCode::where('noReferal', $noReferal)->value('userID');

        $formFields = $request->validate([
            'referrer_userID' => 'required|exists:newusers,userID',
        ]);

        $formFields['referred_userID'] = $userID;

        $referralUsage = ReferralUsage::create($formFields);

        return response()->json($referralUsage, 201);
    }

    public function countByReferrer($referred_userID)
    {
        $count = ReferralUsage::where('referred_userID', $referred_userID)->count();
        return response()->json(['count' => $count]);
    }

    /**
     * Display the specified referral usage.
     *
     * @param int $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $referralUsage = ReferralUsage::with(['referrer', 'referred'])->findOrFail($id);
        return response()->json($referralUsage);
    }

    /**
     * Remove the specified referral usage from storage.
     *
     * @param int $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $referralUsage = ReferralUsage::findOrFail($id);
        $referralUsage->delete();

        return response()->json(null, 204);
    }
}
