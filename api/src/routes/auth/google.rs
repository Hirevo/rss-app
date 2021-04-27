use openidconnect::core::CoreAuthenticationFlow;
use openidconnect::{CsrfToken, Nonce, Scope};
use serde::{Deserialize, Serialize};
use tide::{Request, StatusCode};
use url::Url;

use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

use super::OidcLoginData;

/// Query params for this route.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct QueryParams {
    /// The URL to redirect to with a token.
    pub redirect_url: Url,
}

/// Route to log in to an account.
pub async fn get(mut req: Request<State>) -> tide::Result {
    //? Is the user logged in ?
    if req.is_authenticated() {
        return Ok(utils::response::error(
            StatusCode::Unauthorized,
            "please log out first before logging back in",
        ));
    }

    //? Parse query params.
    let query: QueryParams = req.query()?;

    let (auth_url, csrf_token, nonce) = req
        .state()
        .oidc_client
        .authorize_url(
            CoreAuthenticationFlow::AuthorizationCode,
            CsrfToken::new_random,
            Nonce::new_random,
        )
        .add_scope(Scope::new("email".into()))
        .add_scope(Scope::new("profile".into()))
        .url();

    let data = OidcLoginData {
        csrf_token,
        nonce,
        redirect_url: query.redirect_url,
    };
    req.session_mut().insert("oidc.login", &data)?;

    Ok(utils::response::redirect302(auth_url.as_str()))
}
