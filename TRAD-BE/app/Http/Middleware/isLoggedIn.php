<?php

namespace App\Http\Middleware;

use Closure;
Use Illuminate\Http\Request;
Use Illuminate\Support\Facades\Auth;

class isLoggedIn
{
   public function handle(Request $request, Closure $next)

    {
        if (!Auth::id()) {
            return redirect('/');
        }

        return $next($request);
    }
}
