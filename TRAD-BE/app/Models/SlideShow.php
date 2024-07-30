<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SlideShow extends Model
{
    protected $table = 'slide_show';

    public function kategori_barang(): BelongsTo
    {
        return $this->belongsTo(KategoriBarang::class,'id_kategori_barang');
    }

    public function slide_show(): HasMany
    {
        return $this->hasMany(SlideShow::class,'id_slide_show');
    }

    use HasFactory;

    public static function index($search = '')
    {
        return SlideShow::select("slide_show.*","kategori_barang.nama as nama_kategori_barang")
        ->leftJoin('kategori_barang','kategori_barang.id','=','slide_show.id_kategori_barang')
        ->orderBy('created_at','desc')
        ->when($search,function ($query, $search){
            return $query->where('nama','like',"%" .$search. "%");
        });
    }
    public static function indexSlideShow($search = '')
    {
        return SlideShow::select("slide_show.*","kategori_barang.nama as nama_kategori_barang")
        ->leftJoin('kategori_barang','kategori_barang.id','=','slide_show.id_kategori_barang')
        ->orderBy('created_at','desc')->limit(3)
        ->when($search,function ($query, $search){
            return $query->where('nama','like',"%" .$search. "%");
        });
    }
}