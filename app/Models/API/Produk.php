<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;

    protected $table = 'produk';
    protected $primaryKey = 'idProduk';

    protected $fillable = [
        'idToko',
        'namaProduk',
        'harga',
        'bagiHasil',
        'voucher',
        'kodeProduk',
        'hashtag',
        'deskripsiProduk',
    ];

    public function toko()
    {
        return $this->belongsTo(Toko::class, 'idToko');
    }

    public function kategori()
    {
        return $this->belongsToMany(Kategori::class, 'kategori_produk', 'produk_id', 'kategori_id');
    }

    public function fotoProduk()
    {
        return $this->hasMany(FotoProduk::class, 'idProduk');
    }
}
