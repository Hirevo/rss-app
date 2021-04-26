use openidconnect::core::{CoreClient, CoreProviderMetadata};
use openidconnect::{ClientId, ClientSecret, IssuerUrl, RedirectUrl, TokenUrl};
use serde::{Deserialize, Serialize};

/// Database configuration (`[database]` section).
pub mod database;

/// Frontend configuration (`[frontend]` section).
#[cfg(feature = "frontend")]
pub mod frontend;

use crate::Repo;

use self::database::DatabaseConfig;

pub type HttpClient = reqwest::Client;

/// The application configuration struct.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Config {
    /// General instance configuration options.
    pub general: GeneralConfig,
    /// The database configuration.
    pub database: DatabaseConfig,
    /// Google-related configuration.
    pub google: GoogleConfig,
    /// The session-handling configuration.
    pub sessions: SessionsConfig,
}

/// The general configuration options struct.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct GeneralConfig {
    /// The address to bind the server on.
    pub bind_address: String,
}

/// The Google-related configuration options struct.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct GoogleConfig {
    /// Google OAuth2 client ID.
    pub client_id: String,
    /// Google OAuth2 client secret.
    pub client_secret: String,
}

/// The session-handling configuration struct.
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct SessionsConfig {
    /// The name of the session's cookie.
    pub cookie_name: String,
    /// The secret to use to sign cookies with.
    pub secret: String,
}

/// The application state, created from [Config].
pub struct State {
    /// The current database connection pool.
    pub repo: Repo,
    pub oidc_client: CoreClient,
    pub http_client: HttpClient,
}

impl From<Config> for State {
    fn from(config: Config) -> State {
        let issuer = IssuerUrl::new("https://accounts.google.com".into()).unwrap();
        let provider_metadata =
            CoreProviderMetadata::discover(&issuer, openidconnect::reqwest::http_client)
                .unwrap()
                .set_token_endpoint(Some(
                    TokenUrl::new("https://www.googleapis.com/oauth2/v4/token".into()).unwrap(),
                ));

        let oidc_client = CoreClient::from_provider_metadata(
            provider_metadata,
            ClientId::new(config.google.client_id),
            Some(ClientSecret::new(config.google.client_secret)),
        )
        .set_redirect_uri(
            RedirectUrl::new("https://rss.polomack.eu/auth/callback".into()).unwrap(),
        );

        let http_client = reqwest::Client::new();

        State {
            repo: Repo::new(&config.database),
            oidc_client,
            http_client,
        }
    }
}
