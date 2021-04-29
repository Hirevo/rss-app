#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;

use std::sync::Arc;

use async_std::fs;

use color_eyre::eyre::Report;
use tide::http::cookies::SameSite;
use tide::http::headers::HeaderValue;
use tide::sessions::SessionMiddleware;
use tide::utils::After;
use tide::{Response, Server};

/// API endpoints definitions.
pub mod api;
/// Configuration and internal state type definitions.
pub mod config;
/// Database abstractions module.
pub mod db;
/// Logs initialisation.
pub mod logs;
/// API endpoints definitions.
pub mod routes;
/// Various utilities and helpers.
pub mod utils;

use crate::config::Config;
use crate::utils::auth::AuthMiddleware;
use crate::utils::cors::CorsMiddleware;
use crate::utils::request_log::RequestLogger;
use crate::utils::sessions::SqlStore;

/// The instantiated [`crate::db::Repo`] type alias.
pub type Repo = db::Repo<db::Connection>;

/// The application state type used for the web server.
pub type State = Arc<config::State>;

/// The application error type used for the web server.
pub type Error = Report;

embed_migrations!("./migrations");

fn api_routes(state: State) -> Server<State> {
    let mut app = tide::with_state(state);

    app.with(After(|res: Response| async {
        if let Some(err) = res.error() {
            log::error!("error when handling request: {}", err);
        }
        Ok(res)
    }));

    log::info!("mounting '/api/v1/account/me'");
    app.at("/account/me").get(api::account::me::get);

    log::info!("mounting '/api/v1/feeds'");
    app.at("/feeds").get(api::feeds::get).put(api::feeds::put);
    log::info!("mounting '/api/v1/categories'");
    app.at("/categories").get(api::categories::get_all);
    log::info!("mounting '/api/v1/category/:category-name'");
    app.at("/category/:category-name").get(api::categories::get);
    log::info!("mounting '/api/v1/articles'");
    app.at("/articles").get(api::articles::get_all);
    log::info!("mounting '/api/v1/articles/:feed-id'");
    app.at("/articles/:feed-id").get(api::articles::get);

    log::info!("mounting '/api/v1/feed/:feed-id'");
    app.at("/feed/:feed-id")
        .get(api::feed::get)
        .delete(api::feed::delete);
    log::info!("mounting '/api/v1/article/:article-id'");
    app.at("/article/:article-id")
        .get(api::article::get)
        .post(api::article::post);

    app
}

#[async_std::main]
async fn main() -> Result<(), Error> {
    color_eyre::install()?;
    logs::init();

    let contents = fs::read("config.toml").await?;
    let config: Config = toml::from_slice(contents.as_slice())?;
    let addr = config.general.bind_address.clone();
    let sessions_config = config.sessions.clone();

    let state: Arc<config::State> = Arc::new(config.into());

    let store = SqlStore::new(state.repo.clone());

    log::info!("running database migrations");
    #[rustfmt::skip]
    state.repo.run(|conn| embedded_migrations::run(conn)).await
        .expect("migration execution error");

    let mut app = tide::with_state(Arc::clone(&state));

    log::info!("setting up request logger middleware");
    app.with(RequestLogger::new());
    log::info!("setting up CORS middleware");
    app.with(
        CorsMiddleware::new().methods(
            "GET, POST, PUT, DELETE, OPTIONS"
                .parse::<HeaderValue>()
                .unwrap(),
        ),
    );
    log::info!("setting up session middleware");
    app.with(
        SessionMiddleware::new(store, sessions_config.secret.as_bytes())
            .with_cookie_name(sessions_config.cookie_name.as_str())
            .with_same_site_policy(SameSite::Lax),
    );
    log::info!("setting up auth middleware");
    app.with(AuthMiddleware::new());

    log::info!("mounting '/auth/login'");
    app.at("/auth/login").post(routes::auth::login::post);
    log::info!("mounting '/auth/logout'");
    app.at("/auth/logout").post(routes::auth::logout::post);
    log::info!("mounting '/auth/register'");
    app.at("/auth/register").post(routes::auth::register::post);
    log::info!("mounting '/auth/google'");
    app.at("/auth/google").get(routes::auth::google::get);
    log::info!("mounting '/auth/callback'");
    app.at("/auth/callback").get(routes::auth::callback::get);

    app.at("/api/v1").nest(api_routes(state));

    log::info!("listening on '{0}'", addr);
    app.listen(addr).await?;

    Ok(())
}
