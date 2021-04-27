use json::json;
use tide::{Request, StatusCode};

use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

pub async fn get(req: Request<State>) -> tide::Result {
    match req.get_user() {
        Some(user) => Ok(utils::response::json(&json!({
            "user_id": user.id,
            "email": user.email,
            "name": user.name,
            "using_google": user.google_uid.is_some(),
        }))),
        None => Ok(utils::response::error(
            StatusCode::Unauthorized,
            "you are not currently logged in",
        )),
    }
}
