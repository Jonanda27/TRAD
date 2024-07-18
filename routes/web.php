<?php

use Illuminate\Support\Facades\Route;
Use App\Http\Middleware\isLoggedIn;
Use App\Http\Middleware\isNotLoggedIn;
Use App\Http\Controllers\UserController;
Use App\Http\Controllers\SiteController;
Use App\Http\Controllers\BarangController;
Use App\Http\Controllers\BrandsController;
Use App\Http\Controllers\KategoriBarangController;
Use App\Http\Controllers\PesanController;
Use App\Http\Controllers\SlideShowController;
Use App\Http\Middleware\isAdmin;


/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/',[SiteController::Class, 'index'] );

Route::get('/about', function (){
    return view('about');
});

Route::get('/shop', [SiteController::class,'shop']);

Route::get('/contact', function (){
    return view('contact');
});

Route::get('/login', [UserController::class,'login'])->middleware(isNotLoggedIn::class);
Route::post('/user/authenticate', [UserController::class,'authenticate']); 


// Route::post('/logout', [UserController::class,'logout'])->middleware(isLoggedIn::class);

Route::get('/registrasi', [UserController::class,'registrasi']);
Route::get('/registrasi-admin', [UserController::class,'registrasiAdmin'])->middleware(isNotLoggedIn::class);
Route::post('/user/regular', [UserController::class,'storeRegular']);
Route::post('/user/admin', [UserController::class,'storeAdmin']);

Route::post('/pesan', [PesanController::class,'store']); 

Route::group(['prefix'=>'admin','middleware'=> isAdmin::class], function (){
    
Route::get('/logout',[UserController::class,'logout']);
    
    //Resources List - Silakan pakai u/ CRUD
    Route::resources([
        'barang' => BarangController::class,
        'brands' => BrandsController::class,
        'kategoribarang' => KategoriBarangController::class,
        'slideshow' => SlideShowController::class,
        // 'posts' => PostController::class,
    ]);
    
});

Route::get('/admin/kelola-pembelian', function (){
    return view('admin/KelolaPembelian/tabel');
});

// Route::get('/admin/kategoribarang', function (){
//     return view('admin.kategoribarang.index');
// });

Route::get('/admin/pesan',[PesanController::class,'index']);

Route::delete('/admin/pesan/{id}',[PesanController::class,'destroy']);

Route::get('/admin/kelola-pembelian/form', function (){
    return view('admin/KelolaPembelian/form');
});

Route::get('/admin/pesan/form', function (){
    return view('admin/pesan/form');
});