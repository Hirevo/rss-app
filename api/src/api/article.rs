use diesel::prelude::*;
use tide::{Request, StatusCode};

use crate::db::models::Article;
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

pub async fn get(req: Request<State>) -> tide::Result {
    let article_id = req.param("article-id")?.to_string();

    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    let article: Article = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(articles::table)
                    .inner_join(subscriptions::table)
                    .select(articles::all_columns)
                    .filter(articles::id.eq(article_id))
                    .filter(subscriptions::user_id.eq(user_id))
                    .filter(subscriptions::feed_id.eq(articles::feed_id))
                    .first(conn)
            }
        })
        .await?;

    Ok(utils::response::json(&article))
}
