<?php

namespace App\Http\Controllers;

Use App\Models\User;
use Illuminate\Http\Request;
Use Illuminate\Support\Str;
Use Illuminate\Support\Facades\Auth;
Use Illuminate\Support\Facades\Hash;
Use Illuminate\Support\Facades\Mail;
Use Illuminate\Support\Session\Session;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    public function login(Request $request)
    {
        return view('login');
    }

    public function registrasi(Request $request)
    {
        return view('register');
    }

    public function storeRegular(Request $request)
    {
        try{
            $formFields = $request->validate([
                'nama' => ['required'],
                'no_hp' => ['required'],
                'alamat' => ['required'],
                'email' => ['required'],
                'password' => ['required']
            ]);

            $formFields['password'] = bcrypt($formFields['password']);
            $formFields['nama'] = Str::lower($formFields['nama']);
            $formFields['role'] = 'Reguler';
            $formFields['email'] = Str::lower($formFields['email']);

            if (User::create($formFields)) {

                return redirect('/login');
            }
        } catch (\Throwable $th) {
            dd($th);
            return redirect('/registrasi')->withInput();
        }
    }

    public function authenticate (Request $request)
    {
        try{
            $user= User::where('email', $request->email)->first();

            if(!$user){
                return redirect('/login')->with('error','Log In Gagal. Email atau Password salah.')->withInput();
            }

            if (!Hash::check($request->password, $user->password)){
                return redirect ('/login')->withInput();
            }
            $formFields = $request->validate([
                'email' => ['required'],
                'password' => ['required']
            ]);

            auth()->attempt($formFields);
            $request->session()->regenerate();
            return redirect('/admin/barang')->with('success','Log in Berhasil. Selamat datang');
        } catch (\Throwable $th){
            dd($th);
            return redirect('/login')->with('error','Log in gagal. Silahkan coba kembali.')->withInput();
        }
    }

        public function logout(Request $request)
        {
            try {
                auth()->logout();
                $request->session()->invalidate();
                return redirect('/login')->with('info','Log Out Berhasil. Terimakasih atas Kunjungan Anda.');
            }catch (\Throwable $th){
                dd($th);
                return redirect('/')->with('error','Log Out gagal. Silahkan coba kembali.');
            }
        }   

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
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
        //
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
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}