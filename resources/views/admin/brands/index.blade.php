@extends('layouts.admin')
@section('content')
<div class="container-fluid pt-4 px-4">
    <div>
        <div class="bg-secondary rounded h-100 p-4">
            <h6 class="mb-4">Kelola Brands</h6>
            <a href="/admin/brands/create">
                <button type="button" class="btn btn-primary m-2">Add</button>
            </a>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Id</th>
                        <th scope="col">Nama</th>
                        <th scope="col">Deskripsi</th>
                        <th scope="col">icon</th>
                        <th scope="col" class="tect-center" colspan="2">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($brands_array as $item)
                    <tr>
                        <th scope="row">1</th>
                        <td>{{$item->nama}}</td>
                        <td>{{$item->deskripsi}}</td>
                        <td>
                            @if ( $item->icon )
                            <img class="icon" style="height: 150px;" src="{{asset('storage/'.$item->icon)}}">
                            @endif
                        </td>

                        <div>
                            <td class="text-center">
                                <button class="border-0 bg-transparent">
                                    <a href="/admin/brands/{{ $item->id }}/edit">
                                        <i class="fas fa-edit text-primary"></i>
                                    </a>
                                </button>
                            </td>
                            <td class="text-center">
                                <form action="/admin/brands/{{ $item->id }}" method="POST">
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
            <div class="p-3 mx-5 pagination_index">
                {{$brands_array->links('pagination::bootstrap-5')}}
            </div>
        </div>
    </div>
</div>
@endsection