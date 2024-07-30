@extends('layouts.admin')
@section('content')
<!-- Form Start -->
<div class="container-fluid pt-4 px-4">
    <div class="row g-4">
        <div class="col-sm-12 col-xl-6">
            <div class="bg-secondary rounded h-100 p-4">
                <form action="/admin/barang" enctype="multipart/form-data" method="POST">
                    @csrf

                    <h6 class="mb-4">Kelola Barang</h6>
                    <div class="form-floating mb-3">
                        <input type="text" name="nama" class="form-control" id="name">
                        <label for="nama">Nama</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="number" name="harga" class="form-control" id="harga">
                        <label for="harga">Harga</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="number" name="stock" class="form-control" id="stock">
                        <label for="stock">Stock</label>
                    </div>

                    <div class="mb-3">
                        <label for="deskripsi" class="form-label">Deskripsi</label>
                        <textarea name="deskripsi" class="form-control" rows="4" class="form-control"
                            id="deskripsi"></textarea>
                    </div>

                    <div class="form-floating mb-3">
                        <select class="form-select" name="id_kategori_barang" id="id_kategori_barang"
                            aria-label="Floating label select example">

                            @foreach($barang_categories as $barang_category)
                            <option value="{{$barang_category->id}}">
                                {{ $barang_category->nama }}</option>
                            @endforeach
                        </select>
                        <label for="id_kategori_barang">Kategori Barang</label>
                    </div>

                    <div class="form-floating mb-3">
                        <select class="form-select" name="gender" id="gender"
                            aria-label="Floating label select example">
                            <option value="1">Male</option>
                            <option value="2">Female</option>
                        </select>
                        <label for="gender">Gender</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="text" name="ukuran" class="form-control" id="ukuran">
                        <label for="ukuran">Ukuran</label>
                    </div>

                    <div class="form-floating mb-3">
                        <label for="foto">Foto</label>
                        <input type="file" class="custom-file-input" name="foto" accept="image/*" onchange=""
                            value="{{old('foto')}}" id="foto">
                    </div>

                    <div class="form-floating mb-3">
                        <select class="form-select" name="bintang" id="bintang"
                            aria-label="Floating label select example">
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                            <option value="5">5</option>
                        </select>
                        <label for="bintang">Bintang</label>
                    </div>

                    <button type="submit" class="btn btn-primary">Submit</button>

                    <a href="/admin/barang">
                        <button type="button" class="btn btn-primary m-2">Back</button>
                    </a>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- Form End -->
@endsection