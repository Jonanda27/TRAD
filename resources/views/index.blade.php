@extends('layouts.main')
@section('content')
<!-- Start Banner Hero -->
<div id="template-mo-zay-hero-carousel" class="carousel slide" data-bs-ride="carousel">
    <ol class="carousel-indicators">
        <li data-bs-target="#template-mo-zay-hero-carousel" data-bs-slide-to="0" class="active"></li>
        <li data-bs-target="#template-mo-zay-hero-carousel" data-bs-slide-to="1"></li>
        <li data-bs-target="#template-mo-zay-hero-carousel" data-bs-slide-to="2"></li>
    </ol>
    <div class="carousel-inner">
        <div class="carousel-item active">
            <div class="container">
                <div class="row p-5">
                    @foreach($slideshow_array as $slideshow)
                    <div class="mx-auto col-md-8 col-lg-6 order-lg-last">
                        <img class="img-fluid" src="{{asset('storage/'.$slideshow->gambar)}}" alt="">
                    </div>
                    <div class="col-lg-6 mb-0 d-flex align-items-center">
                        <div class="text-align-left align-self-center">
                            <h1 class="h1 text-success"><b>Sport Shop</b> eCommerce</h1>
                            <h3 class="h2">{{ $slideshow->judul}}</h3>
                            <p>
                                {{ $slideshow->deskripsi}}
                            </p>
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
        </div>
        <div class="carousel-item">
            <div class="container">
            </div>
        </div>
        <div class="carousel-item">
            <div class="container">

            </div>
        </div>
    </div>
    <a class="carousel-control-prev text-decoration-none w-auto ps-3" href="#template-mo-zay-hero-carousel"
        role="button" data-bs-slide="prev">
        <i class="fas fa-chevron-left"></i>
    </a>
    <a class="carousel-control-next text-decoration-none w-auto pe-3" href="#template-mo-zay-hero-carousel"
        role="button" data-bs-slide="next">
        <i class="fas fa-chevron-right"></i>
    </a>
</div>
<!-- End Banner Hero -->


<!-- Start Categories of The Month -->
<section class="container py-5">
    <div class="row text-center pt-3">
        <div class="col-lg-6 m-auto">
            <h1 class="h1">Kategori Barang</h1>
            <p>
                Sport Shop menyediakan perlengkapan olahraga yang lebih premium untuk berbagai jenis olahraga. Sport
                Shop juga lebih lengkap daripada toko olahraga lainnya. Jadi tunggu apa lagi?? Belanja sekarang !
            </p>
        </div>
    </div>
    <div class="row">
        @foreach($kategori_array as $kategori)
        <div class="col-12 col-md-4 p-5 mt-3">
            <a href="#"><img src="{{asset('storage/'.$kategori->icon)}}" class="rounded-circle img-fluid border"></a>
            <h5 class="text-center mt-3 mb-3">{{ $kategori->nama }}</h5>
            <p class="text-center"><a class="btn btn-success">Go Shop</a></p>
        </div>
        @endforeach
    </div>
</section>
<!-- End Categories of The Month -->


<!-- Start Featured Product -->
<section class="bg-light">
    <div class="container py-5">
        <div class="row text-center py-3">
            <div class="col-lg-6 m-auto">
                <h1 class="h1">Produk Unggulan</h1>
                <p>

                    Reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
                    Excepteur sint occaecat cupidatat non proident.
                </p>
            </div>
        </div>
        <div class="row">
            @foreach($barang_array as $barang)
            <div class="col-12 col-md-4 mb-4">
                <div class="card h-100">
                    <a href="shop-single.html">
                        <img src="{{asset('storage/'.$barang->foto)}}" class="card-img-top" alt="...">
                    </a>
                    <div class="card-body">
                        <ul class="list-unstyled d-flex justify-content-between">
                            <li>
                                <i class="text-warning fa fa-star"></i>
                                <i class="text-warning fa fa-star"></i>
                                <i class="text-warning fa fa-star"></i>
                                <i class="text-muted fa fa-star"></i>
                                <i class="text-muted fa fa-star"></i>
                            </li>
                            <li class="text-muted text-right">Rp.{{ $barang->harga }},-</li>
                        </ul>
                        <a href="shop-single.html" class="h2 text-decoration-none text-dark">{{ $barang->nama}}</a>
                        <p class="card-text">
                            {{ $barang->deskripsi }}
                        </p>
                        <p class="text-muted">Reviews (24)</p>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
    </div>
</section>
<!-- End Featured Product -->
@endsection