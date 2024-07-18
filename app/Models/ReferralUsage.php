<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReferralUsage extends Model
{
    use HasFactory;

    protected $table = 'referral_usages';

    protected $fillable = [
        'referrer_userID',
        'referred_userID',
    ];

    // Define relationships
    public function referrer()
    {
        return $this->belongsTo(User::class, 'referrer_userID', 'userID');
    }

    public function referred()
    {
        return $this->belongsTo(User::class, 'referred_userID', 'userID');
    }
}
