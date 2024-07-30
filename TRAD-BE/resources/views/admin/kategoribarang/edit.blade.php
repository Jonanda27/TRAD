@extends('layouts.admin')
@section('content')
<!-- Form Start -->
<div class="container-fluid pt-4 px-4">
    <div class="row g-4">
        <div class="col-sm-12 col-xl-6">
            <div class="bg-secondary rounded h-100 p-4">
                <form action="{{ route('kategoribarang.update', $kategori_barang_array->id) }}"
                    enctype="multipart/form-data" method="POST">
                    @csrf
                    @method('PUT')
                    <h6 class="mb-4">Edit Kategori Barang</h6>
                    <div class="form-floating mb-3">
                        <input type="text" name="nama" class="form-control" id="nama"
                            value='{{$kategori_barang_array->nama}}'>

                        <label for="nama">Nama</label>
                    </div>

                    <div class="form-floating mb-3">
                        <label for="icon">Icon</label>
                        <input type="file" class="custom-file-input" name="icon" accept="image/*" onchange=""
                            value="{{old('icon')}}" id="icon">
                    </div>

                    <!-- <div class="form-floating mb-3">
                        <input type="text" name="foto" class="form-control" id="foto">
                        <label for="foto">Foto</label>
                    </div> -->


                    <button type="submit" class="btn btn-primary">Submit</button>
                    <a href="/admin/kategoribarang">
                        <button type="button" class="btn btn-primary m-2">Back</button>
                    </a>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- Form End -->
@endsection