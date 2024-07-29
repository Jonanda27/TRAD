<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUserTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('user', function (Blueprint $table) {
            $table->id();
            $table->string('userId')->unique();
            $table->string('nama');
            $table->string('no_hp');
            $table->string('alamat');
            $table->string('email')->unique();
            $table->string('noReferal');
            $table->string('password');
            $table->string('pin');
            $table->string('role');
            $table->string('otp')->unique()->nullable();
            $table->string('status');
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
        Schema::dropIfExists('user');
    }
}
