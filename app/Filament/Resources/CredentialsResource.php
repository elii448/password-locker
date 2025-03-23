<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CredentialsResource\Pages;
use App\Filament\Resources\CredentialsResource\RelationManagers;
use App\Filament\Resources\CredentialsResource\RelationManagers\UserRelationManager;
use App\Models\Credentials;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Forms;
use Filament\Forms\Components\Fieldset;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\HtmlString;

class CredentialsResource extends Resource
{
    protected static ?string $model = Credentials::class;

    protected static ?string $navigationIcon = "heroicon-o-rectangle-stack";

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make("platform"),
                TextInput::make("username"),
                TextInput::make("email"),
                TextInput::make("password")
                    ->password(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(function (Builder $query) {
                $query->where('user_id', Auth::id());
            })
            ->columns([
                TextColumn::make("platform")
                    ->searchable(),
                TextColumn::make("username")
                    ->searchable(),
                TextColumn::make("email")
                    ->searchable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make("copy_password")
                    ->icon("heroicon-m-clipboard")
                    ->label("")
                    ->tooltip("Copy password")
                    ->action(function ($record, $livewire) {
                        $livewire->js("await navigator.clipboard.writeText('{$record->password}');");
                        Notification::make()
                            ->title('Password copied to clipboard')
                            ->success()
                            ->send();
                    })
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            UserRelationManager::class
        ];
    }

    public static function getPages(): array
    {
        return [
            "index" => Pages\ListCredentials::route("/"),
            "create" => Pages\CreateCredentials::route("/create"),
            "edit" => Pages\EditCredentials::route("/{record}/edit"),
        ];
    }
}
