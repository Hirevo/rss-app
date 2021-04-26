use diesel::prelude::*;
use tide::{Request, StatusCode};

use crate::db::models::Article;
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

pub async fn get_all(req: Request<State>) -> tide::Result {
    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    let articles: Vec<Article> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(subscriptions::table)
                    .inner_join(articles::table)
                    .select(articles::all_columns)
                    .filter(subscriptions::user_id.eq(user_id))
                    .load(conn)
            }
        })
        .await?;

    Ok(utils::response::json(&articles))
}

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

    let article: Vec<Article> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(articles::table)
                    .inner_join(subscriptions::table)
                    .select(articles::all_columns)
                    .filter(subscriptions::user_id.eq(user_id))
                    .filter(subscriptions::feed_id.eq(feed_id))
                    .load(conn)
            }
        })
        .await?;

    Ok(utils::response::json(&article))
}
