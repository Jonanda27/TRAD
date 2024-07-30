<?php

namespace App\Http\Middleware;

use Closure;
Use Illuminate\Http\Request;
Use Illuminate\Support\Facades\Auth;


class isAdmin
{
   public function handle(Request $request, Closure $next)
    {
        // dd(Auth::user());
        if (!Auth::id() || Auth::user()->role != 'admin') {
            return redirect("/login");
        }
        return $next($request);
    }
}