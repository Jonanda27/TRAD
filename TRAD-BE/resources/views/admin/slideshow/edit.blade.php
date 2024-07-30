@extends('layouts.admin')
@section('content')
<!-- Form Start -->
<div class="container-fluid pt-4 px-4">
    <div class="row g-4">
        <div class="col-sm-12 col-xl-6">
            <div class="bg-secondary rounded h-100 p-4">
                <form action="{{ route('slide_show.update', $slide_show->id) }}" enctype="multipart/form-data"
                    method="POST">
                    @csrf
                    @method('PUT')
                    <h6 class="mb-4">Edit Slide Show</h6>
                    <div class="form-floating mb-3">
                        <input type="text" name="judul" class="form-control" id="name" value='{{$slide_show->judul}}'>

                        <label for="judul">Judul</label>
                    </div>

                    <div class="mb-3">
                        <label for="deskripsi" class="form-label">Deskripsi</label>
                        <textarea name="deskripsi" class="form-control" rows="4" class="form-control"
                            id="deskripsi">{{$slide_show->deskripsi}}</textarea>
                    </div>

                    <div class="form-floating mb-3">
                        <select class="form-select" name="id_kategori_barang" id="gender"
                            aria-label="Floating label select example">
                            @foreach($slide_show as $slide_show_category)
                            <option value="{{$slide_show_category->id}}"
                                {{ $slide_show->id_kategori_barang == $slide_show_category->id ? 'selected' :'' }}>
                                {{ $slide_show_category->nama }}</option>
                            @endforeach
                        </select>
                    </div>

                    <div class="form-floating mb-3">
                        <label for="gambar">Gambar</label>
                        <input type="file" class="custom-file-input" name="gambar" accept="image/*" onchange=""
                            value="{{old('gambar')}}" id="gambar">
                    </div>

                    <button type="submit" class="btn btn-primary">Submit</button>
                    <a href="/admin/slideshow">
                        <button type="button" class="btn btn-primary m-2">Back</button>
                    </a>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- Form End -->
@endsection