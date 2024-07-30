<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pembelian extends Model
{
    protected $table = 'pembelian';

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class,'id_invoice');
    }
    use HasFactory;
}
