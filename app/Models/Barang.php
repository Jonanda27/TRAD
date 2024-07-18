<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    protected $table = 'barang';

    public function kategori_barang(): BelongsTo
    {
        return $this->belongsTo(KategoriBarang::class,'id_kategori_barang');
    }

    public function barang(): HasMany
    {
        return $this->hasMany(Barang::class,'id_barang');
    }

    use HasFactory;

    public static function index($search = '')
    {
        return Barang::select("barang.*","kategori_barang.nama as nama_kategori_barang")
        ->leftJoin('kategori_barang','kategori_barang.id','=','barang.id_kategori_barang')
        ->orderBy('created_at','desc')
        ->when($search,function ($query, $search){
            return $query->where('nama','like',"%" .$search. "%");
        });
    }
    public static function indexBarang($search = '')
    {
        return Barang::select("barang.*","kategori_barang.nama as nama_kategori_barang")
        ->leftJoin('kategori_barang','kategori_barang.id','=','barang.id_kategori_barang')
        ->orderBy('created_at','desc')->limit(3)
        ->when($search,function ($query, $search){
            return $query->where('nama','like',"%" .$search. "%");
        });
    }
}