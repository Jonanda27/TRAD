@extends('layouts.admin')
@section('content')
<div class="container-fluid pt-4 px-4">
    <div>
        <div class="bg-secondary rounded h-100 p-4">
            <form action="/admin/pesan" enctype="multipart/form-data" method="POST">
                @csrf
                <h6 class="mb-4">Kelola Pesan</h6>
                <div class="mb-3">
                    <label for="start-date" class="form-label">Start Date</label>
                    <input type="date" name="tanggal_mulai" class="form-control custom-datepicker" id="start-date">
                </div>
                <div class="form-floating mb-3">
                    <input type="email" class="form-control" id="floatingInput" placeholder="name@example.com">

                    <label for="floatingInput">Email address</label>
                </div>
                <div class="form-floating mb-3">
                    <input type="password" class="form-control" id="floatingPassword" placeholder="Password">
                    <label for="floatingPassword">Password</label>
                </div>
                <div class="form-floating mb-3">
                    <select class="form-select" id="floatingSelect" aria-label="Floating label select example">
                        <option selected>Open this select menu</option>
                        <option value="1">One</option>
                        <option value="2">Two</option>
                        <option value="3">Three</option>
                    </select>
                    <label for="floatingSelect">Works with selects</label>
                </div>
                <div class="form-floating">
                    <textarea class="form-control" placeholder="Leave a comment here" id="floatingTextarea"
                        style="height: 150px;"></textarea>
                    <label for="floatingTextarea">Comments</label>
                </div>
                <button type="submit" class="btn btn-primary m-2">Submit</button>
            </form>
        </div>
    </div>
</div>
@endsection