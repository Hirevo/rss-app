use diesel::prelude::*;
use tide::{Request, Response, StatusCode};

use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

/// Route to log in to an account.
pub async fn post(req: Request<State>) -> tide::Result {
    let token = match req.get_token() {
        Some(token) => token,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    req.state()
        .repo
        .run(move |conn| diesel::delete(tokens::table.find(&token.token)).execute(conn))
        .await?;

    Ok(Response::new(200))
}
