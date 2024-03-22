use sea_orm_migration::prelude::*;

#[derive(DeriveIden)]
enum Track {
    Table,
    Id,
    Title,
    AlbumId,
    ArtistId,
    Duration,
    FilePath,
    PictureId,
    MountPoint,
    CreatedAt,
}

#[derive(DeriveIden)]
enum Album {
    Table,
    Id,
    Name,
    ArtistId,
    CreatedAt,
}

#[derive(DeriveIden)]
enum Artist {
    Table,
    Id,
    Name,
    CreatedAt,
}

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Album::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Album::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Album::Name).string().not_null())
                    .col(ColumnDef::new(Album::ArtistId).integer().null())
                    .col(
                        ColumnDef::new(Album::CreatedAt)
                            .timestamp()
                            .default(Expr::current_timestamp())
                            .not_null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .create_table(
                Table::create()
                    .table(Artist::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Artist::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Artist::Name).string().not_null().unique_key())
                    .col(
                        ColumnDef::new(Artist::CreatedAt)
                            .timestamp()
                            .default(Expr::current_timestamp())
                            .not_null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .create_table(
                Table::create()
                    .table(Track::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Track::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Track::Title).string())
                    .col(ColumnDef::new(Track::AlbumId).integer().null())
                    .col(ColumnDef::new(Track::ArtistId).integer().null())
                    .col(ColumnDef::new(Track::Duration).integer().not_null())
                    .col(ColumnDef::new(Track::FilePath).string().not_null())
                    .col(ColumnDef::new(Track::PictureId).string().null())
                    .col(ColumnDef::new(Track::MountPoint).string().not_null())
                    .col(
                        ColumnDef::new(Track::CreatedAt)
                            .timestamp()
                            .default(Expr::current_timestamp()),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_track_album")
                            .from(Track::Table, Track::AlbumId)
                            .to(Album::Table, Album::Id),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_track_artist")
                            .from(Track::Table, Track::ArtistId)
                            .to(Artist::Table, Artist::Id),
                    )
                    .to_owned(),
            )
            .await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Track::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Album::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Artist::Table).to_owned())
            .await?;
        Ok(())
    }
}
