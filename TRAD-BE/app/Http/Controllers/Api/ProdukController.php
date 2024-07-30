<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Produk;
use App\Models\FotoProduk;

class ProdukController extends Controller
{
    public function index(Request $request)
    {
        $products = Produk::with(['kategori', 'fotoProduk'])->get();

        $productList = $products->map(function ($product) {
            return [
                'idProduk' => $product->idProduk,
                'idToko' => $product->idToko,
                'namaProduk' => $product->namaProduk,
                'fotoProduk' => $product->fotoProduk->pluck('fotoProduk'), // Retrieve multiple photos
                'kategori' => $product->kategori->pluck('namaKategori'), // Retrieve categories
                'harga' => $product->harga,
                'rating' => 4.5,
                'voucher' => $product->voucher,
                'terjual' => 50,
                'statusProduk' => 'Available',
                'sortBy' => 'name',
                'sortOrder' => 'asc'
            ];
        });

        return response()->json($productList);
    }

    public function store(Request $request)
    {
        $formFields = $request->validate([
            'idToko' => 'required|exists:toko,idToko',
            'fotoProduk.*' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'namaProduk' => 'required|string|max:255',
            'harga' => 'required|numeric',
            'bagiHasil' => 'nullable|numeric',
            'voucher' => 'nullable|numeric',
            'kodeProduk' => 'nullable|string|max:50',
            'hashtag' => 'nullable|string|max:255',
            'deskripsiProduk' => 'nullable|string',
            'kategori' => 'required|array',
            'kategori.*' => 'exists:kategori,id'
        ]);

        $produk = Produk::create($formFields);
        $produk->kategori()->sync($request->kategori);

        if ($request->hasFile('fotoProduk')) {
            foreach ($request->file('fotoProduk') as $image) {
                $imageBase64 = base64_encode(file_get_contents($image->getPathName()));
                FotoProduk::create([
                    'idProduk' => $produk->idProduk,
                    'fotoProduk' => $imageBase64
                ]);
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil ditambahkan',
            'code' => 201,
            'data' => $produk->load('fotoProduk')
        ], 201);
    }

    public function update(Request $request, $idProduk)
    {
        $produk = Produk::where('idProduk', $idProduk)->first();

        if (!$produk) {
            return response()->json([
                'status' => 'error',
                'message' => 'Produk tidak ditemukan',
                'code' => 404
            ], 404);
        }

        $formFields = $request->validate([
            'idToko' => 'required|exists:toko,idToko',
            'fotoProduk.*' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'namaProduk' => 'required|string|max:255',
            'harga' => 'required|numeric',
            'bagiHasil' => 'nullable|numeric',
            'voucher' => 'nullable|numeric',
            'kodeProduk' => 'nullable|string|max:50',
            'hashtag' => 'nullable|string|max:255',
            'deskripsiProduk' => 'nullable|string',
            'kategori' => 'required|array',
            'kategori.*' => 'exists:kategori,id'
        ]);

        $produk->update($formFields);
        $produk->kategori()->sync($request->kategori);

        if ($request->hasFile('fotoProduk')) {
            FotoProduk::where('idProduk', $idProduk)->delete(); // Delete old photos
            foreach ($request->file('fotoProduk') as $image) {
                $imageBase64 = base64_encode(file_get_contents($image->getPathName()));
                FotoProduk::create([
                    'idProduk' => $produk->idProduk,
                    'fotoProduk' => $imageBase64
                ]);
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil diubah',
            'code' => 200,
            'data' => $produk->load('fotoProduk')
        ], 200);
    }

    // Method to delete a product by idProduk
    public function deleteProduk($idProduk)
    {
        $produk = Produk::where('idProduk', $idProduk)->first();

        if (!$produk) {
            return response()->json([
                'status' => 'error',
                'message' => 'Produk tidak ditemukan',
                'code' => 404
            ], 404);
        }

        $deletedData = [
            'idProduk' => $produk->idProduk,
            'idToko' => $produk->idToko,
            'fotoProduk' => $produk->fotoProduk,
            'namaProduk' => $produk->namaProduk,
            'harga' => $produk->harga,
            'bagiHasil' => $produk->bagiHasil,
            'voucher' => $produk->voucher,
            'kodeProduk' => $produk->kodeProduk,
            'kategori' => $produk->kategori,
            'hashtag' => $produk->hashtag,
            'deskripsiProduk' => $produk->deskripsiProduk,
            'statusProduk' => 'Deleted'
        ];

        $produk->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil dihapus',
            'code' => 200,
            'data' => $deletedData
        ], 200);
    }

    // Method to filter products by sortBy parameter
    public function filter(Request $request)
    {
        // Validate request parameters
        $request->validate([
            // 'idToko' => 'required|integer',
            'sortBy' => 'required|string|in:rating,harga,voucher'
        ]);
        
        // Retrieve and sort products based on sortBy parameter
        $sortBy = $request->query('sortBy');
        $products = Produk::orderBy($sortBy, 'desc')->get();

        // Transform the data if necessary
        $productList = $products->map(function ($product) {
            return [
                'idProduk' => $product->idProduk,
                'idToko' => $product->idToko, // Include idToko
                'namaProduk' => $product->namaProduk,
                'harga' => $product->harga,
                'rating' => $product->rating, // Assuming rating field exists
                'voucher' => $product->voucher,
                'terjual' => $product->terjual, // Assuming terjual field exists
                'statusProduk' => 'Tersedia', // Default value or dynamic based on your requirements
                'sortBy' => request()->query('sortBy'),
                'sortOrder' => 'desc'
            ];
        });

        return response()->json($productList);
    }

    // Method to search products by search parameter
    public function search(Request $request)
    {
        // Validate request parameters
        $request->validate([
            // 'id' => 'required|integer',
            'search' => 'required|string'
        ]);

        // Retrieve products based on search parameter
        $search = $request->query('search');
        $products = Produk::where('namaProduk', 'like', '%' . $search . '%')->get();

        // Transform the data if necessary
        $productList = $products->map(function ($product) {
            return [
                'idProduk' => $product->idProduk,
                'idToko' => $product->idToko, // Include idToko
                'namaProduk' => $product->namaProduk,
                'harga' => $product->harga,
                'rating' => $product->rating, // Assuming rating field exists
                'voucher' => $product->voucher,
                'terjual' => $product->terjual, // Assuming terjual field exists
                'statusProduk' => 'Tersedia', // Default value or dynamic based on your requirements
                'sortBy' => 'Makanan', // Example value
                'sortOrder' => $product->namaProduk
            ];
        });

        return response()->json($productList);
    }

    public function searchAndFilter(Request $request)
    {
        // Validasi request parameter
        $request->validate([
            'namaProduk' => 'nullable|string',
            'kategori' => 'nullable|array',
            'kategori.*' => 'string',
            'rating' => 'nullable|integer|between:1,5',
        ]);

        // Ambil parameter dari request
        $namaProduk = $request->input('namaProduk');
        $kategori = $request->input('kategori');
        $rating = $request->input('rating');

        // Query produk
        $query = Produk::with(['kategori', 'fotoProduk']);

        if ($namaProduk) {
            $query->where('namaProduk', 'like', '%' . $namaProduk . '%');
        }

        if ($kategori) {
            $query->whereHas('kategori', function ($q) use ($kategori) {
                $q->whereIn('namaKategori', $kategori);
            });
        }

        if ($rating) {
            $query->where('rating', '>=', $rating)->where('rating', '<', $rating + 1);
        }

        $products = $query->get();

        $productList = $products->map(function ($product) {
            return [
                'idProduk' => $product->idProduk,
                'idToko' => $product->idToko,
                'namaProduk' => $product->namaProduk,
                'fotoProduk' => $product->fotoProduk->pluck('fotoProduk'),
                'kategori' => $product->kategori->pluck('namaKategori'),
                'harga' => $product->harga,
                'rating' => $product->rating,
                'voucher' => $product->voucher,
                'terjual' => 50,
                'statusProduk' => 'Available',
            ];
        });

        return response()->json($productList);
    }
}
