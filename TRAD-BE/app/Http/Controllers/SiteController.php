<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\Barang;
Use App\Models\KategoriBarang;
Use App\Models\SlideShow;

Use Auth;


class SiteController extends Controller
{
    public function __construct()
    {
        $this->middleware('isAdmin');
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $limit = $request->limit ?? 9;
        $search = $request->search ?? null;
        
        return view('index',[
        'kategori_array'=> KategoriBarang::index($search)->paginate( 3),
        'barang_array'=>Barang::orderBy('bintang', 'DESC')->paginate( 3),
        'slideshow_array'=> SlideShow::index($search)->paginate( 3),
        'limit'=>$limit,
        'search'=>$search
        ]);



    }
    public function shop()
    {
        $limit = $request->limit ?? 9;
        $search = $request->search ?? null;
        
        return view('shop',[
        'barang_array'=> Barang::index($search)->paginate($limit),
        'limit'=>$limit,
        'search'=>$search
        ]);



    }

}