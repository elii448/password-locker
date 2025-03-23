<?php

namespace App\Filament\Resources\CredentialsResource\Pages;

use App\Filament\Resources\CredentialsResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateCredentials extends CreateRecord
{
    protected static string $resource = CredentialsResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data["user_id"] = auth()->id();

        return $data;
    }
}
