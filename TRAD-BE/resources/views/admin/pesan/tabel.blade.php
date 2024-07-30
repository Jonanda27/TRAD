@extends('layouts.admin')
@section('content')
<!-- Table Start -->
<div class="container-fluid pt-4 px-4">
    <div class="row g-4">

        <div class="col-12">
            <div class="bg-secondary rounded h-100 p-4">
                <h6 class="mb-4">Kelola Pesan</h6>
                <a href="/admin/kelola-pesan/form">
                    <button type="button" class="btn btn-primary m-2">Add</button>
                </a>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th scope="col">Id</th>
                                <th scope="col">Nama</th>
                                <th scope="col">Email</th>
                                <th scope="col">Subject</th>
                                <th scope="col">Pesan</th>
                                <th scope="col">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($pesan_array as $item)
                            <tr>
                                <th scope="row">1</th>
                                <td>{{$item->nama}}</td>
                                <td>{{$item->email}}</td>
                                <td>{{$item->subject}}</td>
                                <td>{{$item->pesan}}</td>
                                <form action="/admin/pesan/{{ $item->id }}" method="POST">
                                    <td> @csrf
                                        @method("DELETE")
                                        <button class="btn btn-transparent btn-xs" tooltip-placement="top"
                                            tooltip="Remove"
                                            onclick="return confirm('Are you sure want to delete ?')"><em
                                                class="fa fa-times fa fa-white"></em></button>
                                    </td>
                                </form>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Table End -->
@endsection