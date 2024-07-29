<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Toko extends Model
{
    use HasFactory;

    protected $table = 'toko';
    protected $primaryKey = 'idToko';

    protected $fillable = [
        'userId',
        'fotoBackgroundToko',
        'fotoProfileToko',
        'namaToko',
        'kategoriToko',
        'alamatToko',
        'NomorTeleponToko',
        'emailToko',
        'deskripsiToko',
        'jamOperasionalToko',
    ];

    /**
     * Get the products for the toko.
     */
    public function produk()
    {
        return $this->hasMany(Produk::class, 'idToko');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
