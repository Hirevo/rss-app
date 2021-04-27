use diesel::prelude::*;
use once_cell::sync::Lazy;
use regex::Regex;
use tide::utils::async_trait;
use tide::{Middleware, Next, Request};

use crate::db::models::{Token, User};
use crate::db::schema::*;
use crate::State;

/// Session cookie's name.
pub static COOKIE_NAME: &'static str = "session";

pub static USER_ID_KEY: &'static str = "user.id";

pub static AUTHORIZATION_VALUE_PATTERN: Lazy<Regex> =
    Lazy::new(|| Regex::new(r#"^Bearer (.*)$"#).unwrap());

/// The authentication middleware for `alexandrie`.
///
/// What it does:
///   - extracts the token from the session cookie.
///   - tries to match it with an author's session in the database.
///   - exposes an [`Author`] struct if successful.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub struct AuthMiddleware;

impl AuthMiddleware {
    /// Creates a new instance of the middleware.
    pub fn new() -> AuthMiddleware {
        AuthMiddleware {}
    }
}

#[async_trait]
impl Middleware<State> for AuthMiddleware {
    async fn handle(&self, mut req: Request<State>, next: Next<'_, State>) -> tide::Result {
        let maybe_token = req
            .header("authorization")
            .and_then(|value| AUTHORIZATION_VALUE_PATTERN.captures(value.as_str()))
            .and_then(|captures| captures.get(1))
            .map(|capture| capture.as_str().to_string());

        if let Some(token) = maybe_token {
            let query = req.state().repo.run(move |conn| {
                //? Get the session matching the user-provided token.
                users::table
                    .inner_join(tokens::table)
                    .select((users::all_columns, tokens::all_columns))
                    .filter(tokens::token.eq(token.as_str()))
                    .first::<(User, Token)>(conn)
                    .optional()
            });

            if let Some((user, token)) = query.await? {
                req.set_ext(user);
                req.set_ext(token);
            }
        }

        let response = next.run(req).await;

        Ok(response)
    }
}

/// A trait to extend `Context` with authentication-related helper methods.
pub trait AuthExt {
    /// Get the currently-authenticated [`Author`] (returns `None` if not authenticated).
    fn get_user(&self) -> Option<User>;

    /// Is the user currently authenticated?
    fn is_authenticated(&self) -> bool {
        self.get_user().is_some()
    }

    fn get_token(&self) -> Option<Token>;
}

impl AuthExt for Request<State> {
    fn get_user(&self) -> Option<User> {
        self.ext::<User>().cloned()
    }

    fn is_authenticated(&self) -> bool {
        self.ext::<User>().is_some()
    }

    fn get_token(&self) -> Option<Token> {
        self.ext::<Token>().cloned()
    }
}
