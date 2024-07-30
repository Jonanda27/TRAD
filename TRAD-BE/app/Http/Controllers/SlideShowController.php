<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\SlideShow;
Use App\Models\KategoriBarang;

Use Auth;


class SlideShowController extends Controller
{
    public function __construct()
    {
        // $this->middleware('isAdmin');
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
    $slide_show_array = SlideShow::all();
        
        return view('admin.slideshow.index',[
        'slide_show_array'=> SlideShow::index($search)->paginate($limit),
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
        return view ('admin.slideshow.create',[
        'slide_show_categories'=> KategoriBarang::all()
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

        $slide_show = new SlideShow;
        $slide_show->judul = $request->input('judul');
        $slide_show->deskripsi = $request->input('deskripsi');
        $slide_show->id_kategori_barang = $request->input('id_kategori_barang');
        $slide_show->gambar = $request->input('gambar');
        if ($request->hasFile('gambar')){
            $slide_show->gambar = $request->file('gambar')->store('gambar_slide_show', 'public');        
        }
        // dd($request->all());
        try{
            $slide_show->save();
        // $formFields = $request->validate([
        //     'nama' => 'required',
        //     'harga' => 'required',
        //     'deskripsi' => 'required',
        // ] );
        // if ($request->hashFile('gambar')){
        //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
        // }
        // Barang::create($formFields);
        return redirect('admin/slideshow')
        ->with('success','Data Slide Show Berhasil Dibuat!');
    } catch (\Throwable $th){
        //throw $th
        dd($th);
        return redirect('/admin/slideshow/create')
        ->with('eror', 'Data Slide Show Gagal Dibuat!')->withInput();
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
        return view('admin.slideshow.edit',[
            'slide_show_categories'=> KategoriBarang::all(),
            'slide_show'=> SlideShow::find($id)
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

        $slide_show = SlideShow::find($id);
        $slide_show->judul = $request->input('judul');
        $slide_show->deskripsi = $request->input('deskripsi');
        $slide_show->id_kategori_slide_show = $request->input('id_kategori_slide_show');
        $slide_show->gambar = $request->input('gambar');

        if ($request->hasFile('gambar')){
            $slide_show->foto = $request->file('gambar')->store('gambar_slide_show', 'public');        
        }

        try{
            $slide_show->save();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/slideshow')
            ->with('success','Data Slide Show Berhasil DiUpdate!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/slideshow/$id/edit')
            ->with('eror', 'Data Slide Show Gagal DiUpdate!')->withInput();
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

        $slide_show = SlideShow::find($id);

        try{
            $slide_show->delete();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('admin/slideshow')
            ->with('success','Data Slide Show Berhasil Dihapus!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/slideshow')
            ->with('eror', 'Data SlideShow Gagal Dihapus!')->withInput();
        }  
    }
}