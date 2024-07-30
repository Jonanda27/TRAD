@extends('layouts.admin')
@section('content')
<div class="container-fluid pt-4 px-4">
    <div>
        <div class="bg-secondary rounded h-100 p-4">
            <div style="width:400px">
                <h6 class="mb-4">Kelola Slide Show</h6>
                <form class="d-none d-md-flex" method="GET" action="">
                    <input type="search" value="{{$search}}" name="search" onsearch="this.form.submit()"
                        placeholder="Search" class="form-control bg-dark border-0" />
                </form>
            </div>
            <a href="/admin/slideshow/create">
                <button type="button" class="btn btn-primary m-2">Add</button>
            </a>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Id</th>
                        <th scope="col">Judul</th>
                        <th scope="col">Deskripsi</th>
                        <th scope="col">Kategori</th>
                        <th scope="col">Gambar</th>
                        <th scope="col" class="tect-center" colspan="2">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($slide_show_array as $item)
                    <tr>
                        <th scope="row"> {{$loop -> index+1 }}</th>
                        <td>{{$item->judul}}</td>
                        <td>{{$item->deskripsi}}</td>
                        <td>{{$item->nama_kategori_barang}}</td>
                        <td>
                            @if ( $item->gambar )
                            <img class="gambar" style="height: 150px;" src="{{asset('storage/'.$item->gambar)}}">
                            @endif
                        </td>

                        <div>
                            <td class="text-center">
                                <button class="border-0 bg-transparent">
                                    <a href="/admin/slideshow/{{ $item->id }}/edit">
                                        <i class="fas fa-edit text-primary"></i>
                                    </a>
                                </button>
                            </td>
                            <td class="text-center">
                                <form action="/admin/slideshow/{{ $item->id }}" method="POST">
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