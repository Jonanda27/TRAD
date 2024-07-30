<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
Use App\Models\Pesan;
Use Auth;


class PesanController extends Controller
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
    $pesan_array = Pesan::all();
        
        return view('admin.pesan.tabel',[
        'pesan_array'=> Pesan::index($search)->paginate($limit),
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
        return view ('admin.pesan.create');
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

        $pesan = new Pesan;
        $pesan->nama = $request->input('nama');
        $pesan->email = $request->input('email');
        $pesan->subject = $request->input('subject');
        $pesan->pesan = $request->input('pesan');

        // php artisan storage:link

        // dd($request->all());
        try{
            $pesan->save();
        // $formFields = $request->validate([
        //     'nama' => 'required',
        //     'harga' => 'required',
        //     'deskripsi' => 'required',
        // ] );
        // if ($request->hashFile('gambar')){
        //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
        // }
        // Barang::create($formFields);
        return redirect('/contact')
        ->with('success','Pesan Berhasil Terkirim!');
    } catch (\Throwable $th){
        //throw $th
        return redirect('/contact')
        ->with('eror', 'Pesan Gagal Terkirim!')->withInput();
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

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */


    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $currentUser = Auth::User();

        $pesan = Pesan::find($id);

        try{
            $pesan->delete();
            // $formFields = $request->validate([
            //     'nama' => 'required',
            //     'harga' => 'required',
            //     'deskripsi' => 'required',
            // ] );
            // if ($request->hashFile('gambar')){
            //     $formFields['gambar'] = $request->file('gambar')->store('foto','public');
            // }
            // Barang::create($formFields);
            return redirect('/admin/pesan')
            ->with('success','Data Pesan Berhasil Dihapus!');
        } catch (\Throwable $th){
            //throw $th
            return redirect('/admin/pesan')
            ->with('eror', 'Data Pesan Gagal Dihapus!')->withInput();
        }  
    }
}