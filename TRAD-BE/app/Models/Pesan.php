<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pesan extends Model
{
    protected $table = 'pesan';

    public function pesan(): HasMany
    {
        return $this->hasMany(Pesan::class,'id_pesan');
    }

    use HasFactory;

    public static function index($search = '')
    {
        return Pesan::orderBy('created_at','desc')
        ->when($search,function ($query, $search){
            return $query->where('nama','like',$search);
        });
    }
}