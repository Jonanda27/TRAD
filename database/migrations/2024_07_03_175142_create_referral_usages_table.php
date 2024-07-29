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
            $table->string('referrer_userId'); // UserID user yang memiliki referral
            $table->string('referred_userId'); // UserID user yang menggunakan referral
            $table->timestamps();

            $table->foreign('referrer_userId')->references('userId')->on('user')->onDelete('cascade');
            $table->foreign('referred_userId')->references('userId')->on('user')->onDelete('cascade');
        
            $table->index(['referrer_userId', 'referred_userId']);
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
