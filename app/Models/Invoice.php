<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    protected $table = 'invoice';

    public function pembelian(): HasMany
    {
        return $this->hasMany(Pembelian::class,'id_invoice');
    }
    use HasFactory;

}
