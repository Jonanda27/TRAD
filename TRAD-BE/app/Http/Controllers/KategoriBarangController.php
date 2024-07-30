<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\KategoriBarang;
Use Auth;


class KategoriBarangController extends Controller
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
        $limit = $request->limit ?? 3;
        $search = $request->search ?? null;
    $kategori_barang_array = KategoriBarang::all();
        
        return view('admin.kategoribarang.index',[
        'kategori_barang_array'=> KategoriBarang::index($search)->paginate($limit),
        'limit'=>$limit,
        'search'=>$search
        ]);

    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create(Request $request)
    {
        return view ('admin.kategoribarang.create');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $currentUser = Auth::User();

        $kategori_barang = new KategoriBarang;
        $kategori_barang->nama = $request->input('nama');

        if ($request->hasFile('icon')){
            $kategori_barang->icon = $request->file('icon')->store('icon_kategori_barang', 'public');        
        }

        // php artisan storage:link

        // dd($request->all());
        try{
            $kategori_barang->save();
        // $formFields = $request->validate([
        //     'nama' => 'required',
        //     'harga' => 'required',
        //     'deskripsi' => 'required',
        // ] );
        // if ($request->hashFile('gambar')){
        //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
        // }
        // Barang::create($formFields);
        return redirect('admin/kategoribarang')
        ->with('success','Data KategoriBarang Berhasil Dibuat!');
    } catch (\Throwable $th){
        //throw $th
        return redirect('/admin/kategoribarang/create')
        ->with('eror', 'Data Kategori Barang Gagal Dibuat!')->withInput();
    } 
}
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        return view('admin.kategoribarang.edit',[
            'kategori_barang_array'=> KategoriBarang::find($id)
            ]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $currentUser = Auth::User();

        $kategori_barang = KategoriBarang::find($id);
        $kategori_barang->nama = $request->input('nama');
        $kategori_barang->icon = $request->input('icon');

        if ($request->hasFile('icon')){
            $kategori_barang->icon = $request->file('icon')->store('icon_kategori_barang', 'public');     
        }
        try{
            $kategori_barang->save();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/kategoribarang')
            ->with('success','Data Kategori Barang Berhasil DiUpdate!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/kategoribarang/$id/edit')
            ->with('eror', 'Data KategoriBarang Gagal DiUpdate!')->withInput();
        } 

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $currentUser = Auth::User();

        $kategori_barang = KategoriBarang::find($id);

        try{
            $kategori_barang->delete();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/kategoribarang')
            ->with('success','Data Kategori Barang Berhasil Dihapus!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/kategoribarang')
            ->with('eror', 'Data Kategori Barang Gagal Dihapus!')->withInput();
        }  
    }
}