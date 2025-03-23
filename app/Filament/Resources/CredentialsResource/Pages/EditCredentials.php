<?php

namespace App\Filament\Resources\CredentialsResource\Pages;

use App\Filament\Resources\CredentialsResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCredentials extends EditRecord
{
    protected static string $resource = CredentialsResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
