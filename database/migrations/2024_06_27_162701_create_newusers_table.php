<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateNewUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('newusers', function (Blueprint $table) {
            $table->id();
            $table->string('userID')->unique();
            $table->string('name');
            $table->string('phone');
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
        Schema::dropIfExists('newusers');
    }
}
