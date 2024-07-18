<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\Barang;
Use App\Models\KategoriBarang;

Use Auth;


class BarangController extends Controller
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
    $barang_array = Barang::all();
        
        return view('admin.barang.index',[
        'barang_array'=> Barang::index($search)->paginate($limit),
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
        return view ('admin.barang.create',[
        'barang_categories'=> KategoriBarang::all()
        ]);
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

        $barang = new Barang;
        $barang->nama = $request->input('nama');
        $barang->harga = $request->input('harga');
        $barang->stock = $request->input('stock');
        $barang->deskripsi = $request->input('deskripsi');
        $barang->id_kategori_barang = $request->input('id_kategori_barang');
        $barang->gender = $request->input('gender');
        $barang->ukuran = $request->input('ukuran');
        $barang->bintang = $request->input('bintang');
        $barang->foto = $request->input('foto');
        if ($request->hasFile('foto')){
            $barang->foto = $request->file('foto')->store('foto_barang', 'public');        
        }
        // dd($request->all());
        try{
            $barang->save();
        // $formFields = $request->validate([
        //     'nama' => 'required',
        //     'harga' => 'required',
        //     'deskripsi' => 'required',
        // ] );
        // if ($request->hashFile('gambar')){
        //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
        // }
        // Barang::create($formFields);
        return redirect('admin/barang')
        ->with('success','Data Barang Berhasil Dibuat!');
    } catch (\Throwable $th){
        //throw $th
        return redirect('/admin/barang/$id/create')
        ->with('eror', 'Data Barang Gagal Dibuat!')->withInput();
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
        return view('admin.barang.edit',[
            'barang_categories'=> KategoriBarang::all(),
            'barang'=> Barang::find($id)
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

        $barang = Barang::find($id);
        $barang->nama = $request->input('nama');
        $barang->harga = $request->input('harga');
        $barang->stock = $request->input('stock');
        $barang->deskripsi = $request->input('deskripsi');
        $barang->id_kategori_barang = $request->input('id_kategori_barang');
        $barang->gender = $request->input('gender');
        $barang->ukuran = $request->input('ukuran');
        $barang->foto = $request->input('foto');

        if ($request->hasFile('foto')){
            $barang->foto = $request->file('foto')->store('foto_barang', 'public');        
        }

        $barang->bintang = $request->input('bintang');

        try{
            $barang->save();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/barang')
            ->with('success','Data Barang Berhasil DiUpdate!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/barang/$id/edit')
            ->with('eror', 'Data Barang Gagal DiUpdate!')->withInput();
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

        $barang = Barang::find($id);

        try{
            $barang->delete();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/barang')
            ->with('success','Data Barang Berhasil Dihapus!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/barang')
            ->with('eror', 'Data Barang Gagal Dihapus!')->withInput();
        }  
    }
}