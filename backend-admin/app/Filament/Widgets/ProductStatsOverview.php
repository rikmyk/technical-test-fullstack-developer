<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Carbon\Carbon;

class ProductStatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalProducts = Product::count();
        $activeProducts = Product::where('price', '>', 0)->count();
        $avgPrice = Product::avg('price') ?? 0;
        $recentProducts = Product::where('created_at', '>=', Carbon::now()->subDay())->count();

        return [
            Stat::make('Total Products', $totalProducts)
                ->description('Total products in database')
                ->descriptionIcon('heroicon-m-cube')
                ->color('primary'),
            Stat::make('Active Products', $activeProducts)
                ->description('Products with price > Rp 0')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),
            Stat::make('Average Product Price', 'Rp ' . number_format($avgPrice, 0, ',', '.'))
                ->description('Average price of all items')
                ->descriptionIcon('heroicon-m-presentation-chart-line')
                ->color('primary'),
            Stat::make('Recently Added (24h)', $recentProducts)
                ->description('Products created in the last 24h')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
        ];
    }
}
