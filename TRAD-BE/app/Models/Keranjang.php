<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Keranjang extends Model
{
    protected $table = 'keranjang';

    public function barang()
    {
        return $this->hasManyThrough(Barang::class, Keranjang::class,'id_barang');
    }
    use HasFactory;
}
