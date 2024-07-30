@extends('layouts.admin')
@section('content')
<div class="container-fluid pt-4 px-4">
    <div>
        <div class="bg-secondary rounded h-100 p-4">
            <div style="width:400px">
                <h6 class="mb-4">Kelola Barang</h6>
                <form class="d-none d-md-flex" method="GET" action="">
                    <input type="search" value="{{$search}}" name="search" onsearch="this.form.submit()"
                        placeholder="Search" class="form-control bg-dark border-0" />
                </form>
            </div>
            <a href="/admin/barang/create">
                <button type="button" class="btn btn-primary m-2">Add</button>
            </a>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Id</th>
                        <th scope="col">Nama</th>
                        <th scope="col">Harga</th>
                        <th scope="col">Stock</th>
                        <th scope="col">Deskripsi</th>
                        <th scope="col">Kategori</th>
                        <th scope="col">Gender</th>
                        <th scope="col">Ukuran</th>
                        <th scope="col">Foto</th>
                        <th scope="col">Bintang</th>
                        <th scope="col" class="tect-center" colspan="2">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($barang_array as $item)
                    <tr>
                        <th scope="row"> {{$loop -> index+1 }}</th>
                        <td>{{$item->nama}}</td>
                        <td>{{$item->harga}}</td>
                        <td>{{$item->stock}}</td>
                        <td>{{$item->deskripsi}}</td>
                        <td>{{$item->nama_kategori_barang}}</td>
                        <td>{{$item->gender}}</td>
                        <td>{{$item->ukuran}}</td>

                        <td>
                            @if ( $item->foto )
                            <img class="foto" style="height: 150px;" src="{{asset('storage/'.$item->foto)}}">
                            @endif
                        </td>
                        <td>{{$item->bintang}}</td>

                        <div>
                            <td class="text-center">
                                <button class="border-0 bg-transparent">
                                    <a href="/admin/barang/{{ $item->id }}/edit">
                                        <i class="fas fa-edit text-primary"></i>
                                    </a>
                                </button>
                            </td>
                            <td class="text-center">
                                <form action="/admin/barang/{{ $item->id }}" method="POST">
                                    @csrf
                                    @method("DELETE")
                                    <button class="btn btn-transparent btn-xs" tooltip-placement="top" tooltip="Remove"
                                        onclick="return confirm('Are you sure want to delete ?')"><em
                                            class="fa fa-times fa fa-white"></em></button>
                                </form>
                            </td>
                        </div>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection