use diesel::prelude::*;
use serde::{Deserialize, Serialize};
use tide::{Request, Response, StatusCode};

use crate::db::models::{Article, ArticleRead};
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

use super::ArticleWithReadMarker;

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

    let (article, read): (Article, Option<String>) = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(articles::table)
                    .inner_join(subscriptions::table)
                    .left_outer_join(
                        articles_read::table.on(articles_read::article_id
                            .eq(articles::id)
                            .and(articles_read::user_id.eq(subscriptions::user_id))),
                    )
                    .select((articles::all_columns, articles_read::user_id.nullable()))
                    .filter(articles::id.eq(article_id))
                    .filter(subscriptions::user_id.eq(user_id))
                    .filter(subscriptions::feed_id.eq(articles::feed_id))
                    .first(conn)
            }
        })
        .await?;

    let article = ArticleWithReadMarker {
        id: article.id,
        feed_id: article.feed_id,
        title: article.title,
        url: article.url,
        html_content: article.html_content,
        marked_as_read: read.is_some(),
    };

    Ok(utils::response::json(&article))
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RequestBody {
    pub read: bool,
}

pub async fn post(mut req: Request<State>) -> tide::Result {
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

    let has_json_body = req
        .header("content-type")
        .map_or(false, |value| value.as_str() == "application/json");
    let mark_as_read = if has_json_body {
        let body: RequestBody = req.body_json().await?;
        body.read
    } else {
        true
    };

    req.state()
        .repo
        .transaction({
            let user_id = user.id.clone();
            move |conn| {
                //? This request will fail if user is not subscribed to the involved feed.
                let _: String = feeds::table
                    .inner_join(articles::table)
                    .inner_join(subscriptions::table)
                    .select(articles::id)
                    .filter(articles::id.eq(&article_id))
                    .filter(subscriptions::user_id.eq(&user_id))
                    .filter(subscriptions::feed_id.eq(articles::feed_id))
                    .first(conn)?;

                if mark_as_read {
                    diesel::insert_or_ignore_into(articles_read::table)
                        .values(ArticleRead {
                            user_id,
                            article_id,
                        })
                        .execute(conn)?;
                } else {
                    diesel::delete(
                        articles_read::table
                            .filter(articles_read::user_id.eq(user_id))
                            .filter(articles_read::article_id.eq(article_id)),
                    )
                    .execute(conn)?;
                }

                Ok::<_, tide::Error>(())
            }
        })
        .await?;

    Ok(Response::builder(200).build())
}
