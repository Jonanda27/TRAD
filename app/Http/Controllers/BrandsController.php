<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\Brands;
Use Auth;


class BrandsController extends Controller
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
    $brands_array = Brands::all();
        
        return view('admin.brands.index',[
        'brands_array'=> Brands::index($search)->paginate($limit),
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
        return view ('admin.brands.create');
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

        $brands = new Brands;
        $brands->nama = $request->input('nama');
        $brands->deskripsi = $request->input('deskripsi');

        if ($request->hasFile('icon')){
            $brands->icon = $request->file('icon')->store('icon_brands', 'public');        
        }

        // php artisan storage:link

        // dd($request->all());
        try{
            $brands->save();
        // $formFields = $request->validate([
        //     'nama' => 'required',
        //     'harga' => 'required',
        //     'deskripsi' => 'required',
        // ] );
        // if ($request->hashFile('gambar')){
        //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
        // }
        // Barang::create($formFields);
        return redirect('admin/brands')
        ->with('success','Data Brands Berhasil Dibuat!');
    } catch (\Throwable $th){
        //throw $th
        return redirect('/admin/brands/create')
        ->with('eror', 'Data Brands Gagal Dibuat!')->withInput();
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
        return view('admin.brands.edit',[
            'brands_array'=> Brands::find($id)
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

        $brands = Brands::find($id);
        $brands->nama = $request->input('nama');
        $brands->deskripsi = $request->input('deskripsi');
        $brands->icon = $request->input('icon');

        if ($request->hasFile('icon')){
            $brands->icon = $request->file('icon')->store('icon_brands', 'public');        
        }

        try{
            $brands->save();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/brands')
            ->with('success','Data Brands Berhasil DiUpdate!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/brands/$id/edit')
            ->with('eror', 'Data Brands Gagal DiUpdate!')->withInput();
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

        $brands = Brands::find($id);

        try{
            $brands->delete();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/brands')
            ->with('success','Data Brands Berhasil Dihapus!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/brands')
            ->with('eror', 'Data Brands Gagal Dihapus!')->withInput();
        }  
    }
}
