use openidconnect::core::CoreAuthenticationFlow;
use openidconnect::{CsrfToken, Nonce, Scope};
use tide::{Request, StatusCode};

use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

use super::OidcLoginData;

/// Route to log in to an account.
pub async fn get(mut req: Request<State>) -> tide::Result {
    //? Is the user logged in ?
    if req.is_authenticated() {
        return Ok(utils::response::error(
            StatusCode::Unauthorized,
            "please log out first before logging back in",
        ));
    }

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

    let data = OidcLoginData { csrf_token, nonce };
    req.session_mut().insert("oidc.login", &data)?;

    Ok(utils::response::redirect302(auth_url.as_str()))
}
