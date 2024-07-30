<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('barang', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nama');
            $table->integer('harga')->default(0);
            $table->integer('stock')->default(0);
            $table->string('deskripsi')->nullable();
            $table->unsignedBigInteger('id_kategori_barang');
            $table->string('gender')->nullable();
            $table->string('ukuran');
            $table->string('foto')->nullable();
            $table->integer('bintang')->default(0);
            $table->foreign('id_kategori_barang')->references('id')->on('kategori_barang');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('barang');
    }
};
