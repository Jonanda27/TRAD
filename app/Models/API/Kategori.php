<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    use HasFactory;

    protected $table = 'kategori';

    protected $fillable = [
        'namaKategori',
    ];

    public function produk()
    {
        return $this->belongsToMany(Produk::class, 'kategori_produk', 'kategori_id', 'produk_id');
    }
}
