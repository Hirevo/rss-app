use openidconnect::{CsrfToken, Nonce};
use serde::{Deserialize, Serialize};

/// Account login endpoint (eg. "/account/login").
pub mod login;
/// Account logout endpoint (eg. "/account/logout").
pub mod logout;
/// Account registration endpoint (eg. "/account/register").
pub mod register;
pub mod google;
pub mod callback;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OidcLoginData {
    pub csrf_token: CsrfToken,
    pub nonce: Nonce,
}
