<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FotoProduk extends Model
{
    use HasFactory;

    protected $table = 'foto_produk';
    public $timestamps = false;

    protected $fillable = [
        'idProduk',
        'fotoProduk',
    ];

    public function produk()
    {
        return $this->belongsTo(Produk::class, 'idProduk');
    }
}
