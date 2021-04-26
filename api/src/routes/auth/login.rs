use std::num::NonZeroU32;
use std::time::Duration;

use diesel::prelude::*;
use ring::pbkdf2;
use serde::{Deserialize, Serialize};
use tide::{Request, Response, StatusCode};

use crate::db::schema::*;
use crate::utils;
use crate::State;
use crate::utils::auth::AuthExt;

/// Request body for this route.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RequestBody {
    /// The account's email.
    pub email: String,
    /// The account's password.
    pub password: String,
}

/// Route to log in to an account.
pub async fn post(mut req: Request<State>) -> tide::Result {
    let state = req.state().clone();
    let repo = &state.repo;

    //? Is the user logged in ?
    if req.is_authenticated() {
        return Ok(utils::response::error(
            StatusCode::Unauthorized,
            "please log out first before logging back in",
        ));
    }

    //? Parse request body.
    let body: RequestBody = req.body_json().await?;

    let transaction = repo.transaction(move |conn| {
        //? Get the users' salt and expected hash.
        let results = salts::table
            .inner_join(users::table)
            .select((users::id, salts::salt, users::passwd))
            .filter(users::email.eq(body.email.as_str()))
            .first::<(String, String, Option<String>)>(conn)
            .optional()?;

        //? Does the user exist?
        let (user_id, encoded_salt, encoded_expected_hash) = match results {
            Some(results) => results,
            None => {
                return Ok(utils::response::error(
                    StatusCode::Forbidden,
                    "invalid email/password combination.",
                ));
            }
        };

        let encoded_expected_hash = match encoded_expected_hash {
            Some(encoded_expected_hash) => encoded_expected_hash,
            None => {
                return Ok(utils::response::error(
                    StatusCode::Forbidden,
                    "invalid email/password combination.",
                ));
            }
        };

        //? Decode hex-encoded hashes.
        let decode_results = hex::decode(encoded_salt.as_str())
            .and_then(|fst| hex::decode(encoded_expected_hash.as_str()).map(move |snd| (fst, snd)));

        let (decoded_salt, decoded_expected_hash) = match decode_results {
            Ok(results) => results,
            Err(_) => {
                return Ok(utils::response::error(
                    StatusCode::InternalServerError,
                    "an author already exists for this email.",
                ));
            }
        };

        //? Verify client password against the expected hash (through PBKDF2).
        let password_match = {
            let iteration_count = unsafe { NonZeroU32::new_unchecked(100_000) };
            let outcome = pbkdf2::verify(
                pbkdf2::PBKDF2_HMAC_SHA512,
                iteration_count,
                decoded_salt.as_slice(),
                body.password.as_ref(),
                decoded_expected_hash.as_slice(),
            );
            outcome.is_ok()
        };

        if !password_match {
            return Ok(utils::response::error(
                StatusCode::Forbidden,
                "invalid email/password combination.",
            ));
        }

        // let expiry = match form.remember.as_deref() {
        //     Some("on") => Duration::from_secs(2_592_000), // 30 days
        //     _ => Duration::from_secs(86_400),             // 1 day / 24 hours
        // };

        let expiry = Duration::from_secs(2_592_000);

        req.session_mut().expire_in(expiry);
        req.session_mut().insert(utils::auth::USER_ID_KEY, &user_id)?;

        Ok(Response::new(200))
    });

    transaction.await
}
