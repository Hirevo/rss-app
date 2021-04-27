use tide::{Request, Response, StatusCode};

use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

/// Route to log in to an account.
pub async fn post(mut req: Request<State>) -> tide::Result {
    //? Is the user logged in ?
    if !req.is_authenticated() {
        return Ok(utils::response::error(
            StatusCode::Unauthorized,
            "you are not currently logged in",
        ));
    }

    req.session_mut().remove(utils::auth::USER_ID_KEY);
    Ok(Response::new(200))
}
