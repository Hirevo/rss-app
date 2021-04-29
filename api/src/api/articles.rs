use diesel::prelude::*;
use tide::{Request, StatusCode};

use crate::db::models::Article;
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

use super::ArticleWithReadMarker;

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

    let articles: Vec<(Article, Option<String>)> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(subscriptions::table)
                    .inner_join(articles::table)
                    .left_outer_join(
                        articles_read::table.on(articles_read::article_id
                            .eq(articles::id)
                            .and(articles_read::user_id.eq(subscriptions::user_id))),
                    )
                    .select((articles::all_columns, articles_read::user_id.nullable()))
                    .filter(subscriptions::user_id.eq(&user_id))
                    .load(conn)
            }
        })
        .await?;

    let articles: Vec<_> = articles
        .into_iter()
        .map(|(article, read)| ArticleWithReadMarker {
            id: article.id,
            feed_id: article.feed_id,
            title: article.title,
            url: article.url,
            html_content: article.html_content,
            marked_as_read: read.is_some(),
        })
        .collect();

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

    let articles: Vec<(Article, Option<String>)> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(subscriptions::table)
                    .inner_join(articles::table)
                    .left_outer_join(
                        articles_read::table.on(articles_read::article_id
                            .eq(articles::id)
                            .and(articles_read::user_id.eq(subscriptions::user_id))),
                    )
                    .select((articles::all_columns, articles_read::user_id.nullable()))
                    .filter(subscriptions::user_id.eq(&user_id))
                    .filter(subscriptions::feed_id.eq(&feed_id))
                    .load(conn)
            }
        })
        .await?;

    let articles: Vec<_> = articles
        .into_iter()
        .map(|(article, read)| ArticleWithReadMarker {
            id: article.id,
            feed_id: article.feed_id,
            title: article.title,
            url: article.url,
            html_content: article.html_content,
            marked_as_read: read.is_some(),
        })
        .collect();

    Ok(utils::response::json(&articles))
}
