use diesel::prelude::*;
use tide::{Request, Response, StatusCode};

use crate::db::models::Feed;
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

pub async fn get(req: Request<State>) -> tide::Result {
    let feed_id = req.param("feed-id")?.to_string();

    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    let feed: Feed = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(subscriptions::table)
                    .select(feeds::all_columns)
                    .filter(subscriptions::user_id.eq(user_id))
                    .filter(subscriptions::feed_id.eq(feed_id))
                    .first(conn)
            }
        })
        .await?;

    Ok(utils::response::json(&feed))
}

pub async fn delete(req: Request<State>) -> tide::Result {
    let feed_id = req.param("feed-id")?.to_string();

    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    req.state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                diesel::delete(
                    subscriptions::table
                        .filter(subscriptions::user_id.eq(user_id))
                        .filter(subscriptions::feed_id.eq(feed_id)),
                )
                .execute(conn)
            }
        })
        .await?;

    return Ok(Response::new(200));
}
