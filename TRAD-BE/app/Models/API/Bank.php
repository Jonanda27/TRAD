<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Bank extends Model
{
    use HasFactory;

    protected $table = 'bank';

    protected $fillable = [
        'id_user',
        'namaBank',
        'nomorRekening',
        'pemilikRekening',
    ];

    public function user()
    {
        return $this->belongsTo(user::class, 'id_user');
    }
}
