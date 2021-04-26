use std::num::NonZeroU32;
use std::time::Duration;

use diesel::dsl as sql;
use diesel::prelude::*;
use ring::digest as hasher;
use ring::pbkdf2;
use ring::rand::{SecureRandom, SystemRandom};
use serde::{Deserialize, Serialize};
use tide::{Request, Response, StatusCode};

use crate::db::models::{Salt, User};
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

/// Request body for this route.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RequestBody {
    /// The account's email.
    pub email: String,
    /// The account's displayable name.
    pub name: String,
    /// The account's password.
    pub password: String,
}

/// Route to register a new account.
pub async fn post(mut req: Request<State>) -> tide::Result {
    let state = req.state().clone();
    let repo = &state.repo;

    //? Is the author already logged in ?
    if req.is_authenticated() {
        return Ok(utils::response::error(
            StatusCode::Unauthorized,
            "please log out first to register as a new user",
        ));
    }

    //? Parse request body.
    let body: RequestBody = req.body_json().await?;

    let transaction = repo.transaction(move |conn| {
        //? Does the user already exist ?
        let already_exists = sql::select(sql::exists(
            users::table.filter(users::email.eq(body.email.as_str())),
        ))
        .get_result(conn)?;
        if already_exists {
            return Ok(utils::response::error(
                StatusCode::Forbidden,
                "a user already exists for this email.",
            ));
        }

        //? Generate the user's authentication salt.
        let decoded_generated_salt = {
            let mut data = [0u8; 16];
            let rng = SystemRandom::new();
            rng.fill(&mut data).unwrap();
            hasher::digest(&hasher::SHA512, data.as_ref())
        };

        //? Derive the hashed password data with PBKDF2 (100_000 rounds).
        let encoded_derived_hash = {
            let mut out = [0u8; hasher::SHA512_OUTPUT_LEN];
            let iteration_count = unsafe { NonZeroU32::new_unchecked(100_000) };
            pbkdf2::derive(
                pbkdf2::PBKDF2_HMAC_SHA512,
                iteration_count,
                decoded_generated_salt.as_ref(),
                body.password.as_ref(),
                &mut out,
            );
            hex::encode(out.as_ref())
        };

        //? Insert the new author data.
        let user = User {
            id: utils::generate_id(),
            email: body.email,
            name: body.name,
            passwd: Some(encoded_derived_hash),
            google_uid: None,
        };
        diesel::insert_into(users::table)
            .values(&user)
            .execute(conn)?;

        //? Store the user's newly-generated authentication salt.
        let encoded_generated_salt = hex::encode(decoded_generated_salt.as_ref());
        let salt = Salt {
            user_id: user.id.clone(),
            salt: encoded_generated_salt,
        };
        diesel::insert_into(salts::table)
            .values(&salt)
            .execute(conn)?;

        let expiry = Duration::from_secs(2_592_000);

        req.session_mut().expire_in(expiry);
        req.session_mut()
            .insert(utils::auth::USER_ID_KEY, &user.id)?;

        Ok(Response::new(200))
    });

    transaction.await
}
