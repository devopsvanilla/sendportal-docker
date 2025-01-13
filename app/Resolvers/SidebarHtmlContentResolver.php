<?php
#TODO DevOps - Inclui itens personalizados no menu
namespace App\Resolvers;

use Sendportal\Base\Contracts\HtmlContentResolver;

class SidebarHtmlContentResolver implements HtmlContentResolver
{
    public function resolve()
    {
        return '<li><a href="/custom-link">Custom Menu Item</a></li>';
    }
}
