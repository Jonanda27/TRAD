<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Brands extends Model
{
    protected $table = 'brands';

    public function brands(): HasMany
    {
        return $this->hasMany(Brands::class,'id_brands');
    }

    use HasFactory;

    public static function index($search = '')
    {
        return Brands::orderBy('created_at','desc')
        ->when($search,function ($query, $search){
            return $query->where('nama','like',$search);
        });
    }
}
