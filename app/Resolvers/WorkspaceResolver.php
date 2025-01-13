<?php
#TODO DevOps - Criação de Tenants
declare(strict_types=1);

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Sendportal\Base\Facades\Sendportal;

class AppServiceProvider extends ServiceProvider
{
    // …
    public function boot(): void
    {
        Sendportal::setCurrentWorkspaceIdResolver(function () {
            return 1;
        });
    }
}