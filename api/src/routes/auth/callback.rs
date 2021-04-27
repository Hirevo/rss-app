use chrono::{Duration, Utc};
use diesel::prelude::*;
use openidconnect::reqwest::async_http_client;
use openidconnect::{AsyncCodeTokenRequest, AuthorizationCode, TokenResponse};
use serde::{Deserialize, Serialize};
use tide::{Request, Response, StatusCode};

use crate::db::models::{Token, User};
use crate::db::schema::*;
use crate::db::DATETIME_FORMAT;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

use super::OidcLoginData;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct CallbackQueryData {
    code: String,
    state: String,
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

    let mut data: OidcLoginData = match req.session().get("oidc.login") {
        Some(data) => data,
        None => {
            return Ok(utils::response::error(
                StatusCode::BadRequest,
                "not currently within an OAuth flow.",
            ));
        }
    };
    req.session_mut().remove("oidc.login");

    let query: CallbackQueryData = req.query()?;

    if query.state.as_str() != data.csrf_token.secret() {
        return Ok(utils::response::error(
            StatusCode::BadRequest,
            "invalid ID token.",
        ));
    }

    let code = AuthorizationCode::new(query.code);
    let token_response = req
        .state()
        .oidc_client
        .exchange_code(code)
        .add_extra_param("access_type", "offline")
        .request_async(async_http_client)
        .await
        .unwrap();

    let id_token = match token_response.id_token() {
        Some(token) => token,
        None => {
            return Ok(utils::response::error(
                StatusCode::BadRequest,
                "invalid ID token.",
            ));
        }
    };
    let claims = {
        let verifier = req.state().oidc_client.id_token_verifier();
        id_token.claims(&verifier, &data.nonce).unwrap()
    };

    let user = (|| {
        log::debug!("claims = {:?}", claims);
        let id = claims.subject().to_string();
        let email = claims.email()?.to_string();
        let name = claims.name()?.get(None)?.to_string();
        Some(User {
            id: utils::generate_id(),
            email,
            name,
            passwd: None,
            google_uid: Some(id),
        })
    })();

    let user = match user {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::BadRequest,
                "invalid user data.",
            ));
        }
    };

    let token = req
        .state()
        .repo
        .transaction(move |conn| -> tide::Result<_> {
            let found: Option<User> = users::table
                .filter(users::google_uid.eq(&user.google_uid))
                .first(conn)
                .optional()?;

            let user = match found {
                Some(user) => user,
                None => {
                    diesel::insert_into(users::table)
                        .values(&user)
                        .execute(conn)?;

                    user
                }
            };

            let token = Token {
                token: utils::generate_id(),
                expiry: (Utc::now() + Duration::seconds(2_592_000))
                    .format(DATETIME_FORMAT)
                    .to_string(), // 30 days
                user_id: user.id.clone(),
            };

            diesel::insert_into(tokens::table)
                .values(&token)
                .execute(conn)?;

            Ok(token)
        })
        .await?;

    data.redirect_url
        .query_pairs_mut()
        .append_pair("token", token.token.as_str())
        .finish();
    Ok(Response::builder(303)
        .header("location", data.redirect_url.into_string())
        .build())
}
