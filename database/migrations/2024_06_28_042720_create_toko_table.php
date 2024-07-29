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
        Schema::create('toko', function (Blueprint $table) {
            $table->bigIncrements('idToko');
            $table->unsignedBigInteger('userId');
            $table->string('fotoBackgroundToko')->nullable();
            $table->string('fotoProfileToko')->nullable();
            $table->string('namaToko');
            $table->string('kategoriToko');
            $table->text('alamatToko');
            $table->string('NomorTeleponToko');
            $table->string('emailToko')->unique();
            $table->text('deskripsiToko')->nullable();
            $table->string('jamOperasionalToko');
            $table->foreign('userId')->references('id')->on('user')->onDelete('cascade');
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
        Schema::dropIfExists('toko');
    }
};
