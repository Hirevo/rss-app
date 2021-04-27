use openidconnect::{CsrfToken, Nonce};
use serde::{Deserialize, Serialize};
use url::Url;

pub mod callback;
pub mod google;
/// Account login endpoint (eg. "/account/login").
pub mod login;
/// Account logout endpoint (eg. "/account/logout").
pub mod logout;
/// Account registration endpoint (eg. "/account/register").
pub mod register;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OidcLoginData {
    pub csrf_token: CsrfToken,
    pub nonce: Nonce,
    pub redirect_url: Url,
}
