<?php

namespace App\Models\API;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;


class ReferralUsage extends Model
{
    use HasFactory;

    protected $table = 'referral_usages';

    protected $fillable = [
        'referrer_userId',
        'referred_userId',
    ];

    // Define relationships
    public function referrer()
    {
        return $this->belongsTo(User::class, 'referrer_userId', 'userId');
    }

    public function referred()
    {
        return $this->belongsTo(User::class, 'referred_userId', 'userId');
    }
}
