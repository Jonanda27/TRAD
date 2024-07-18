<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReferralUsagesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('referral_usages', function (Blueprint $table) {
            $table->id();
            $table->string('referrer_userID'); // UserID user yang memiliki referral
            $table->string('referred_userID'); // UserID user yang menggunakan referral
            $table->timestamps();

            $table->foreign('referrer_userID')->references('userID')->on('newusers')->onDelete('cascade');
            $table->foreign('referred_userID')->references('userID')->on('newusers')->onDelete('cascade');
        
            $table->index(['referrer_userID', 'referred_userID']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('referral_usages');
    }
}
