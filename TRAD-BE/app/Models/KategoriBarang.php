<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KategoriBarang extends Model
{
    protected $table = 'kategori_barang';

    public function kategori_barang(): HasMany
    {
        return $this->hasMany(KategoriBarang::class,'id_kategori_barang');
    }

    use HasFactory;

    public static function index($search = '')
    {
        return KategoriBarang::orderBy('created_at','desc')
        ->when($search,function ($query, $search){
            return $query->where('nama','like',$search);
        });
    }
}